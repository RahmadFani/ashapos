import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/utils.dart';
import 'package:image/image.dart' as img;

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/blocs/sales/sales_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/details_sales.dart';
import 'package:ashapos/models/sales.dart';
import 'package:ashapos/ui/screens/drawer.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    BlocProvider.of<SalesCubit>(context).refreshSales();
  }

  DateTime dateSave;

  void _onLoading(SalesFilter filter) async {
    print(filter);
    if (filter == SalesFilter.none) {
      BlocProvider.of<SalesCubit>(context).getDataSales();
      return;
    }
    BlocProvider.of<SalesCubit>(context)
        .getSalesFromDate(date: dateSave, nextpage: true);
  }

  void _selectDateSales() async {
    DateTime now = DateTime.now();
    DateTime selectdate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 50));
    print(selectdate);
    if (selectdate == null) return;
    setState(() {
      dateSave = selectdate;
    });
    BlocProvider.of<SalesCubit>(context).getSalesFromDate(date: selectdate);
  }

  @override
  void initState() {
    super.initState();

    initBluetootSaving();
  }

  void initBluetootSaving() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String bluetooth = prefs.getString('bluetooth_connect') ?? null;

    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;

    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
    } else {
      if (bluetooth != null) {
        if (bluetooths.contains(bluetooth)) {
          List list = bluetooth.split("#");
          String macaddress = list[1];
          final String result =
              await BluetoothThermalPrinter.connect(macaddress);
          print("Printer connected $result");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerPage(),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            }),
        actions: [
          IconButton(icon: Icon(Icons.date_range), onPressed: _selectDateSales)
        ],
        title: Text('ETAM BERSINAR'),
      ),
      body: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: (ctx, state) {
          print('connectivity : ' + state.result.toString());
        },
        child: BlocConsumer<SalesCubit, SalesState>(
          listener: (_, state) {
            _refreshController.refreshCompleted();
            _refreshController.loadComplete();
          },
          builder: (_, state) => state.isinitial
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Stack(
                  children: [
                    SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: state.lastpage ? false : true,
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: () => _onLoading(state.filter),
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: state.sales.length,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          itemBuilder: (_, index) {
                            return SalesCard(item: state.sales[index]);
                          }),
                    ),
                    if (state.isloading)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black.withOpacity(.5),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}

class SalesCard extends StatefulWidget {
  final SalesModel item;

  const SalesCard({Key key, this.item}) : super(key: key);

  @override
  _SalesCardState createState() => _SalesCardState();
}

class _SalesCardState extends State<SalesCard> {
  bool isopen = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    return InkWell(
      onTap: () {
        setState(() {
          isopen = !isopen;
        });
      },
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nota.${user.outletId}.${widget.item.saleNo}'),
                isopen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal : ${widget.item.dateTime}'),
                          Text('Pelanggan : ${widget.item.customerId}'),
                          Text('Cara Bayar: ${widget.item.paymentMethodId}')
                        ],
                      )
                    : SizedBox.shrink(),
                Text('Rp. ${widget.item.totalPayable}'),
                isopen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Future.delayed(Duration(seconds: 10));
                                  List<DetailSalesModel> details = List.empty();
                                  try {
                                    final result = await http.post(
                                        Uri.parse(
                                            Api.url + 'get-sales-details.php'),
                                        body: {'id': widget.item.id});

                                    List json = jsonDecode(result.body);
                                    details = json
                                        .map(
                                            (e) => DetailSalesModel.fromJson(e))
                                        .toList();
                                  } catch (e) {}

                                  showDialog(
                                      context: context,
                                      builder: (_) => DetailSales(
                                          item: widget.item, details: details));
                                },
                                child: Text('Detail')),
                            SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  final delete = await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            content: Text(
                                                'Apakah anda yakin ingin hapus data ini ?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Tidak')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text('Iya')),
                                            ],
                                          ));

                                  if (delete == null) return;
                                  if (delete) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      final result = await http.post(
                                          Uri.parse(
                                              Api.url + 'delete-sales.php'),
                                          body: {'id': widget.item.id});

                                      if (result.statusCode == 200) {
                                        BlocProvider.of<SalesCubit>(context)
                                            .refreshSales();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Item Berhasil di hapus')));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Item gagal di hapus'),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('Terjadi kesalahan.'),
                                              behavior:
                                                  SnackBarBehavior.floating));
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } finally {}
                                  }
                                },
                                child: Text('Hapus'))
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailSales extends StatelessWidget {
  final SalesModel item;
  final List<DetailSalesModel> details;

  const DetailSales({Key key, this.item, this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    NumberFormat f =
        NumberFormat.currency(symbol: 'Rp ', locale: 'id', decimalDigits: 0);

    return AlertDialog(
      scrollable: true,
      title: Text('ETAM BERSINAR'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tanggal: ${item.dateTime}'),
          Text('Nota.${user.outletId}.${item.saleNo}'),
          Divider(
            thickness: 2,
          ),
          ...List.generate(
              details.length,
              (index) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            '${details[index].menuName} x${details[index].qty}',
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${f.format(double.parse(details[index].total))}')
                    ],
                  )),
          Divider(
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sub Total'),
              Text('${f.format(double.parse(item.subTotal))}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diskon'),
              Text('${f.format(double.parse(item.discActual))}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pajak'),
              Text('${f.format(double.parse(item.vat))}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total'),
              Text('${f.format(double.parse(item.totalPayable))}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terima'),
              Text('${f.format(double.parse(item.paidAmount ?? '0'))}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kembali'),
              Text('${f.format(double.parse(item.dueAmount ?? '0'))}')
            ],
          ),
          // Image.file(File(
          //     '/data/user/0/com.barqun.bersinar/app_flutter/images/logo_outlet_etam_bersinar_bontang.png')),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Terima Kasih'),
            ],
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, 'success');
            },
            child: Text('Tutup')),
        TextButton(
            onPressed: () async {
              String isConnected =
                  await BluetoothThermalPrinter.connectionStatus;
              if (isConnected == "true") {
                List<int> bytes = await printGetBytes(context);
                final result = await BluetoothThermalPrinter.writeBytes(bytes);
                print("Print $result");
              } else {
                final prefs = await SharedPreferences.getInstance();
                print('Logo Outlet');
                print(prefs.get('logo_outlet') ?? 'tidak ada path outlet');
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          content: Text('Belum terhubung dengan printer.'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'success');
                                },
                                child: Text('Tutup'))
                          ],
                        ));
              }
            },
            child: Text('Cetak'))
      ],
    );
  }

  Future<List<int>> printGetBytes(context) async {
    try {
      NumberFormat f =
          NumberFormat.currency(symbol: 'Rp ', locale: 'id', decimalDigits: 0);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];
      UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;

      final prefs = await SharedPreferences.getInstance();
      final String logoPath = prefs.get('logo_outlet') ?? null;

      // Centered
      // bytes += generator.rawBytes([
      //   0x1B,
      //   0x61,
      //   0x31,
      // ]);

      // left
      //   bytes += generator.rawBytes([
      //   0x1B,
      //   0x61,
      //   0x30,
      // ]);

      if (logoPath != null) {
        img.Image image = decodeImageFile(logoPath);
        bytes += generator.imageRaster(image);
      }

      // final result = await http.post(
      //     Uri.parse(Api.url + 'get-sales-details.php'),
      //     body: {'id': item.id});

      // List json = jsonDecode(result.body);
      // List<DetailSalesModel> details =
      //     json.map((e) => DetailSalesModel.fromJson(e)).toList();

      bytes += generator.feed(1);
      bytes += generator.rawBytes([
        0x1B,
        0x61,
        0x31,
      ]);
      bytes += generator.text('${user.outletName}',
          styles: PosStyles(
              align: PosAlign.center, width: PosTextSize.size2, bold: true));

      // bytes += generator.text('ETAM BERSINAR',
      //     styles: PosStyles(align: PosAlign.center, width: PosTextSize.size2));
      bytes += generator.rawBytes([
        0x1B,
        0x61,
        0x31,
      ]);
      bytes += generator.text('By Etam Bersinar',
          styles: PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);

      if (user.address != null) {
        bytes += generator.rawBytes([
          0x1B,
          0x61,
          0x31,
        ]);
        bytes += generator.text('${user.address}',
            styles: PosStyles(
              align: PosAlign.center,
            ));
      }
      bytes += generator.rawBytes([
        0x1B,
        0x61,
        0x31,
      ]);
      bytes += generator.text('${user.phone}',
          styles: PosStyles(
            align: PosAlign.center,
          ));
      bytes += generator.rawBytes([
        0x1B,
        0x61,
        0x31,
      ]);
      bytes += generator.text('${user.emailAddress}',
          styles: PosStyles(
            align: PosAlign.center,
          ));
      bytes += generator.feed(1);
      // bytes += generator.rawBytes([
      //   0x1B,
      //   0x61,
      //   0x30,
      // ]);
      bytes += generator.text(
        'Nota.${user.outletId}.${item.saleNo}',
      );
      bytes += generator.text(
        'Tanggal ${item.dateTime}',
      );
      bytes += generator.hr();
      await Future.forEach(details, (DetailSalesModel data) {
        bytes += generator.row([
          PosColumn(
            text: '${data.menuName}',
            width: 12,
            styles: PosStyles(
              align: PosAlign.left,
            ),
          ),
        ]);
        bytes += generator.row([
          PosColumn(
            text: '${data.qty} x ${f.format(double.parse(data.price))}',
            width: 7,
            styles: PosStyles(
              align: PosAlign.left,
            ),
          ),
          PosColumn(
            text: '${f.format(double.parse(data.total))}',
            width: 5,
            styles: PosStyles(
              align: PosAlign.right,
            ),
          ),
        ]);
      });
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Subtotal:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.subTotal))}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Diskon:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.discActual))}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Pajak:',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.vat))}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Total:',
          width: 7,
          styles: PosStyles(
            bold: true,
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.totalPayable))}',
          width: 5,
          styles: PosStyles(
            bold: true,
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Terima:',
          width: 7,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.paidAmount ?? '0'))}',
          width: 5,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Kembali:',
          width: 7,
          styles: PosStyles(
            align: PosAlign.left,
          ),
        ),
        PosColumn(
          text: '${f.format(double.parse(item.dueAmount ?? '0'))}',
          width: 5,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.rawBytes([
        0x1B,
        0x61,
        0x31,
      ]);

      if (user.footer != null) {
        bytes += generator.text('${user.footer}',
            styles: PosStyles(
              align: PosAlign.center,
            ));
      }

      bytes += generator.cut();

      return bytes;
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text('Gagal saat mencoba print data.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'success');
                      },
                      child: Text('Tutup'))
                ],
              ));

      List<int> bytes = [];
      return bytes;
    }
  }
}
