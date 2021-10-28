import 'dart:convert';
import 'dart:math';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/blocs/cart/cart_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/blocs/sales/sales_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/customer.dart';
import 'package:ashapos/models/details_sales.dart';
import 'package:ashapos/models/sales.dart';
import 'package:ashapos/models/table.dart';
import 'package:ashapos/models/transaction.dart';
import 'package:ashapos/ui/screens/cart/search_meja.dart';
import 'package:ashapos/ui/screens/cart/search_pelanggan.dart';
import 'package:ashapos/ui/screens/home.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  static Route route() => MaterialPageRoute(builder: (_) => CartPage());

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  CustomerModel customer;
  TableModel table;

  NumberFormat f =
      NumberFormat.currency(symbol: '', locale: 'id', decimalDigits: 0);

  void _searchPelanggan() async {
    CustomerModel result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => SearchPelanggan()));
    setState(() {
      customer = result;
    });
  }

  void _searchMeja() async {
    TableModel result =
        await showDialog(context: context, builder: (_) => SearchMeja());
    setState(() {
      table = result;
    });
  }

  String get namaPelanggan => customer == null ? '' : customer.name;
  String get namaTable => table == null ? '' : table.name;

  @override
  Widget build(BuildContext context) {
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    return Scaffold(
      key: _scaffold,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('CHECKOUT'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (_, state) => Stack(
          children: [
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 140.0, left: 10, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cari Pelanggan : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: _searchPelanggan,
                      child: Container(
                        color: Colors.grey.shade300,
                        height: 45,
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                              child: Text(
                                namaPelanggan,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )),
                            Icon(Icons.more_vert_outlined)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Cari Meja : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: _searchMeja,
                      child: Container(
                        color: Colors.grey.shade300,
                        height: 45,
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                              child: Text(
                                namaTable,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )),
                            Icon(Icons.more_vert_outlined)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: state.carts.length,
                            itemBuilder: (_, index) {
                              CartItems cart = state.carts[index];
                              return Container(
                                height: 85,
                                child: Card(
                                  elevation: 4,
                                  child: ListTile(
                                    title: Text(cart.itemModel.name),
                                    subtitle: Text('Qty: ${cart.qty}'),
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    ItemCartEdit(item: cart));
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            BlocProvider.of<CartCubit>(context)
                                                .removeItem(cart.itemModel);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 140,
                child: PhysicalModel(
                  color: Colors.black,
                  elevation: 15,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Rp.${state.totalHargaWithDisc + ((int.parse(user.vat) / 100) * state.totalHargaWithDisc).round()}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                          Container(
                            height: 50,
                            width: double.infinity,
                            child: Row(
                              children: [
                                // SizedBox(
                                //   height: double.infinity,
                                //   child: ElevatedButton(
                                //     style: ButtonStyle(
                                //         backgroundColor:
                                //             MaterialStateProperty.all(
                                //                 Colors.white),
                                //         elevation:
                                //             MaterialStateProperty.all(3)),
                                //     onPressed: () {},
                                //     child: Text(
                                //       'Bayar nanti',
                                //       style: TextStyle(color: Colors.black),
                                //     ),
                                //   ),
                                // ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                SizedBox(
                                  height: double.infinity,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          elevation:
                                              MaterialStateProperty.all(3)),
                                      onPressed: () async {
                                        UserModel user = BlocProvider.of<
                                                AuthenticationCubit>(context)
                                            .state
                                            .user;
                                        int userVat =
                                            ((int.parse(user.vat) / 100) *
                                                    state.totalHargaWithDisc)
                                                .round();
                                        final result =
                                            await showModalBottomSheet(
                                                context: context,
                                                builder: (ctx) {
                                                  return Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('CHECKOUT',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Expanded(
                                                              child: Container(
                                                            width:
                                                                double.infinity,
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .zero,
                                                              child: ListView
                                                                  .builder(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10),
                                                                      itemCount: state
                                                                          .carts
                                                                          .length,
                                                                      itemBuilder:
                                                                          (_, index) {
                                                                        CartItems
                                                                            item =
                                                                            state.carts[index];
                                                                        return Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text('- ${item.itemModel.name} (x${item.qty})'),
                                                                            Text('${f.format(item.total)}')
                                                                          ],
                                                                        );
                                                                      }),
                                                            ),
                                                          )),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text('Subtotal'),
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                width: 120,
                                                                child: Text(
                                                                    '${f.format(state.totalHarga)}'),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text('Dikson'),
                                                              Container(
                                                                width: 120,
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                    '${f.format(state.totalDisc)}'),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                  'Pajak (${user.vat}%)'),
                                                              Container(
                                                                width: 120,
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                    '${f.format(userVat)}'),
                                                              )
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text('Total '),
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                width: 120,
                                                                child: Text(
                                                                    '${f.format(state.totalHargaWithDisc + userVat)}'),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          SizedBox(
                                                            height: 50,
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                ElevatedButton(
                                                              style: ButtonStyle(
                                                                  elevation:
                                                                      MaterialStateProperty
                                                                          .all(
                                                                              3)),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context,
                                                                    'bayar');
                                                              },
                                                              child: Text(
                                                                  'Lanjut ke pembayaran'),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });

                                        if (result is String &&
                                            result == 'bayar') {
                                          openDialogPay(state);
                                        }
                                      },
                                      child: Text('Detail',
                                          style:
                                              TextStyle(color: Colors.black))),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          elevation:
                                              MaterialStateProperty.all(3)),
                                      onPressed: () => openDialogPay(state),
                                      child: Text('Bayar Sekarang'),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void openDialogPay(CartState cart) async {
    if (cart.carts.length == 0) {
      ScaffoldMessenger.of(_scaffold.currentContext).showSnackBar(SnackBar(
        content: Text('Silahkan pilih item sebelum bayar.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    CartPayDialogResponse result = await showDialog(
        context: context,
        builder: (_) => CartPayDialog(
              cart: cart,
            ));
    if (result == null) return;
    final isSuccess = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ProsesPembayaranDialog(
              cart: cart,
              cartPayDialogResponse: result,
              table: table,
              customer: customer,
            ));
    if (isSuccess == null) return;
    if (isSuccess == 'success') {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    }
  }
}

/*
 * Proses Pembayaran Widget ----------------------------------------------------------------------------------->
 */
class ProsesPembayaranDialog extends StatefulWidget {
  final CartState cart;
  final CartPayDialogResponse cartPayDialogResponse;
  final CustomerModel customer;
  final TableModel table;

  const ProsesPembayaranDialog(
      {Key key,
      @required this.cart,
      @required this.cartPayDialogResponse,
      @required this.customer,
      @required this.table})
      : super(key: key);

  @override
  _ProsesPembayaranDialogState createState() => _ProsesPembayaranDialogState();
}

class _ProsesPembayaranDialogState extends State<ProsesPembayaranDialog> {
  bool loading = true;
  bool hasError = false;
  SalesModel sale;
  List<DetailSalesModel> details = List.empty();

  @override
  void initState() {
    super.initState();
    initPembayaran();
  }

  void initPembayaran() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    CartState cart = widget.cart;
    CartPayDialogResponse cartForm = widget.cartPayDialogResponse;
    CustomerModel customer = widget.customer;
    TableModel table = widget.table;

    int extraDiscount = int.parse(cartForm.diskon);

    final DateTime time = DateTime.now();
    int userVat =
        ((int.parse(user.vat) / 100) * cart.totalHargaWithDisc).round();

    final connectivity = BlocProvider.of<ConnectivityCubit>(context).state;

    Map<String, String> body = {
      'customer-id': customer != null ? customer.id : '1',
      'total-items': cart.carts.length.toString(),
      'subtotal': cart.totalHarga.toString(),
      'paid-amount': cartForm.paidAmount,
      'due-amount': (int.parse(cartForm.paidAmount) -
              (cart.totalHarga - cart.totalDisc - extraDiscount + userVat))
          .toString(),
      'due-payment-date': "",
      'disc': extraDiscount.toString(),
      'disc-actual': (cart.totalDisc + extraDiscount).toString(),
      'vat': userVat.toString(), // Belum Selesai / API kurang join.
      'total-payable':
          (cart.totalHarga - cart.totalDisc - extraDiscount + userVat)
              .toString(),
      'payment-method': cartForm.methodPembayaranId,
      'table-id': table != null ? table.id : '0',
      'token-number': cartForm.noToken,
      'sale-date': '${time.year}-${time.month}-${time.day}',
      'date-time': time.toString(),
      'sale-time': time.hour.toString(),
      'user-id': user.id,
      'company-id': user.companyId,
      'outlet-id': user.outletId,
      'del-status': "Live"
    };

    if (connectivity.isoffline) {
      String saleIdOffline =
          "OFFLINE-${Random().nextInt(9000) + 1000}-${time.year}-${time.month}-${time.day}-${time.hour.toString()}";
      Map<String, dynamic> bodyOffline = {
        'sale-id': saleIdOffline,
        'customer-id': customer != null ? customer.id : '1',
        'total-items': cart.carts.length.toString(),
        'subtotal': cart.totalHarga.toString(),
        'paid-amount': cartForm.paidAmount,
        'due-amount': (int.parse(cartForm.paidAmount) -
                (cart.totalHarga - cart.totalDisc - extraDiscount + userVat))
            .toString(),
        'due-payment-date': "",
        'disc': extraDiscount.toString(),
        'disc-actual': (cart.totalDisc + extraDiscount).toString(),
        'vat': userVat.toString(), // Belum Selesai / API kurang join.
        'total-payable':
            (cart.totalHarga - cart.totalDisc - extraDiscount + userVat)
                .toString(),
        'payment-method': cartForm.methodPembayaranId,
        'table-id': table != null ? table.id : '0',
        'token-number': cartForm.noToken,
        'sale-date': '${time.year}-${time.month}-${time.day}',
        'date-time': time.toString(),
        'sale-time': time.hour.toString(),
        'user-id': user.id,
        'company-id': user.companyId,
        'outlet-id': user.outletId,
        'del-status': "Live"
      };
      List<Map<String, String>> body2 = [];

      /// Detail Cart
      await Future.forEach(cart.carts, (CartItems element) async {
        Map<String, String> map = {
          'food-menu-id': element.itemModel.id,
          'menu-name': element.itemModel.name,
          'price': element.itemModel.salePrice,
          'qty': element.qty.toString(),
          'discount-amount': element.discount.toString(),
          'total': element.total.toString(),
          'sales-id': saleIdOffline,
          'user-id': user.id,
          'outlet-id': user.outletId,
          'del-status': 'Live'
        };
        body2.add(map);
      });
      bodyOffline['items'] = body2;

      ///EndDetailCard
      ///
      List<String> listTransaksiOffline =
          pref.getStringList('transactions_offline') ?? [];
      String encode = jsonEncode(bodyOffline);
      listTransaksiOffline.add(encode);

      /// adding offline
      pref.setStringList('transactions_offline', listTransaksiOffline);

      TransactionModel data = TransactionModel.fromJson(bodyOffline);
      List<DetailSalesModel> detailsSales = [];
      await Future.forEach(data.items, (ItemsTransaction element) {
        detailsSales.add(DetailSalesModel(
            id: "",
            foodMenuId: element.foodMenuId,
            menuName: element.menuName,
            price: element.price,
            qty: element.qty,
            discountAmount: element.discountAmount,
            total: element.total,
            salesId: element.salesId,
            outletId: element.outletId,
            delStatus: element.delStatus));
      });

      setState(() {
        sale = SalesModel(
            id: "",
            dateTime: data.dateTime,
            duePaymentDate: data.paymentMethod,
            disc: data.disc,
            discActual: data.discActual,
            vat: data.vat,
            customerId: data.customerId,
            saleNo: data.saleId,
            totalItems: data.totalItems,
            subTotal: data.subtotal,
            paidAmount: data.paidAmount,
            dueAmount: data.dueAmount,
            totalPayable: data.totalPayable,
            paymentMethodId: data.paymentMethod,
            tableId: data.tableId,
            tokenNo: data.tokenNumber,
            saleDate: data.saleDate,
            saleTime: data.saleTime,
            userId: data.userId,
            companyId: data.companyId,
            outletId: data.outletId,
            delStatus: data.delStatus);
        details = detailsSales;
        loading = false;
      });
      BlocProvider.of<CartCubit>(context).emptyCart();
      return;
    }

    try {
      final resAddSales =
          await http.post(Uri.parse(Api.url + 'add-sales.php'), body: body);

      print(resAddSales.body);
      String id = jsonDecode(resAddSales.body)['id'];

      setState(() {
        sale = SalesModel.fromJson(jsonDecode(resAddSales.body));
      });

      await Future.forEach(cart.carts, (CartItems element) async {
        final res = await http
            .post(Uri.parse(Api.url + 'add-sales-details.php'), body: {
          'food-menu-id': element.itemModel.id,
          'menu-name': element.itemModel.name,
          'price': element.itemModel.salePrice,
          'qty': element.qty.toString(),
          'discount-amount': element.discount.toString(),
          'total': element.total.toString(),
          'sales-id': id,
          'user-id': user.id,
          'outlet-id': user.outletId,
          'del-status': 'Live'
        });
        print(res.body);
      });

      final result2 = await http
          .post(Uri.parse(Api.url + 'get-sales-details.php'), body: {'id': id});

      List json = jsonDecode(result2.body);
      List<DetailSalesModel> det =
          json.map((e) => DetailSalesModel.fromJson(e)).toList();
      setState(() {
        details = det;
      });

      BlocProvider.of<CartCubit>(context).emptyCart();
      BlocProvider.of<SalesCubit>(context).refreshSales();
    } catch (e) {
      print('Error $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CartPayDialogLoading()
        : hasError
            ? CartPayDialogError()
            : DetailSales(
                item: sale,
                details: details,
              );
  }
}

/*
 *
 * Item Edit ------------------------------------------------------------------------------------------ 
 * 
 */
class ItemCartEdit extends StatefulWidget {
  final CartItems item;

  const ItemCartEdit({Key key, this.item}) : super(key: key);

  @override
  _ItemCartEditState createState() => _ItemCartEditState();
}

class _ItemCartEditState extends State<ItemCartEdit> {
  int qty = 0;

  String disctype = 'Rp';
  TextEditingController disc = TextEditingController();
  TextEditingController customprice = TextEditingController();

  double get price => customprice.text == ''
      ? 0
      : double.parse(customprice.text) == 0
          ? double.parse(widget.item.itemModel.salePrice)
          : double.parse(customprice.text);
  int get total => (price * qty).round();
  int get discount => disc.text == '' ? 0 : int.parse(disc.text);
  int get discItem =>
      disctype == 'Rp' ? discount : ((discount / 100) * total).round();
  int get totalWithDisc => disctype == 'Rp'
      ? total - discount
      : (total - (discount / 100) * total).round();

  int get ppn =>
      widget.item.itemModel.vatId == "1" ? ((10 / 100) * total).round() : 0;

  NumberFormat f =
      NumberFormat.currency(symbol: 'Rp ', locale: 'id', decimalDigits: 0);

  @override
  void initState() {
    super.initState();

    disc = TextEditingController(text: widget.item.discount.toString());
    customprice =
        TextEditingController(text: widget.item.customPrice.toString());

    setState(() {
      qty = widget.item.qty;
      disctype = widget.item.discountType;
    });
  }

  void removeQty() {
    if (qty == 0) return;
    setState(() {
      qty--;
    });
  }

  void addQty() {
    setState(() {
      qty++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Menu'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.item.itemModel.name}'),
          SizedBox(
            height: 10,
          ),
          Text(
            'Harga :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 45,
            color: Colors.white,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Rp.${widget.item.itemModel.salePrice}')),
          ),
          Text(
            'Custom Harga :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 45,
            color: Colors.grey.shade300,
            child: Center(
              child: TextField(
                controller: customprice,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) {
                  setState(() {});
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Qty :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: qty > 1 ? removeQty : null,
                ),
                IconButton(
                    icon: Text('$qty',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20)),
                    onPressed: null),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addQty,
                ),
              ],
            ),
          ),
          Text(
            'Dskon :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            child: Center(
              child: DropdownButton<String>(
                value: disctype,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                onChanged: (String newValue) {
                  setState(() {
                    disctype = newValue;
                  });
                },
                items: <String>['Rp', '%']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            height: 45,
            color: Colors.grey.shade300,
            child: Center(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (text) {
                  setState(() {});
                },
                controller: disc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('Subtotal : '), Text('${f.format(total)}')],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('Diskon : '), Text('${f.format(discItem)}')],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('Total : '), Text('${f.format(totalWithDisc)}')],
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Tutup')),
        TextButton(
            onPressed: () {
              BlocProvider.of<CartCubit>(context).editingCartItem(
                  widget.item.itemModel,
                  qty,
                  price.round(),
                  discount,
                  disctype);
              Navigator.pop(context);
            },
            child: Text('Simpan'))
      ],
    );
  }
}

/*
 * Dialog Pemabayaran And Response --------------------------------------------------------------------------------->
 */

class CartPayDialogResponse {
  String date;
  String noToken;
  String diskon;
  String paidAmount;
  String methodPembayaranId;

  CartPayDialogResponse(
      {this.date,
      this.noToken,
      this.diskon,
      this.methodPembayaranId,
      this.paidAmount});
}

class CartPayDialog extends StatefulWidget {
  final CartState cart;

  const CartPayDialog({Key key, this.cart}) : super(key: key);

  @override
  _CartPayDialogState createState() => _CartPayDialogState();
}

class _CartPayDialogState extends State<CartPayDialog> {
  String datepick = '';
  String dropdownValue = 'Tunai';
  @override
  void initState() {
    super.initState();
    initDatePick();
  }

  initDatePick() {
    DateTime date = DateTime.now();
    setState(() {
      datepick = '${date.year}-${date.month}-${date.day}';
    });
  }

  int get methodPembayaranId => dropdownValue == 'Kartu' ? 1 : 2;
  int noToken = 0;
  int paidAmount = 0;
  int diskon = 0;

  void clickBayar(int bayar) async {
    if (methodPembayaranId == 1) {
      paidAmount = bayar;
    } else {
      if ((paidAmount - diskon) < bayar) {
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Text(
                      'Jumlah bayar kurang dari total yang perlu dibayar.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Oke"),
                    ),
                  ],
                ));
        return;
      }
    }
    print('METHOD: ' + methodPembayaranId.toString());
    CartPayDialogResponse res = new CartPayDialogResponse(
        noToken: noToken.toString(),
        diskon: diskon.toString(),
        date: datepick,
        paidAmount: paidAmount.toString(),
        methodPembayaranId: methodPembayaranId.toString());
    Navigator.pop(context, res);
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    return AlertDialog(
      scrollable: true,
      title: Text('Pembayaran'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diskon :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            color: Colors.grey.shade300,
            child: Center(
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    diskon = text.isEmpty ? 0 : int.parse(text);
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: InputBorder.none, focusedBorder: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Tanggal Penjualan :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () async {
              DateTime date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2090),
              );
              print(date);
              setState(() {
                datepick = '${date.year}-${date.month}-${date.day}';
              });
            },
            child: Container(
                height: 50,
                color: Colors.grey.shade300,
                width: double.infinity,
                child: Align(
                    alignment: Alignment.centerLeft, child: Text(datepick))),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Total yang dibayar :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rp.${(widget.cart.totalHargaWithDisc + ((int.parse(user.vat) / 100) * widget.cart.totalHargaWithDisc) - diskon).round()}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Jenis pembayaran :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            color: Colors.grey.shade300,
            child: Center(
              child: DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                items: <String>[
                  'Tunai',
                  'Kartu',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Jumlah Bayar :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            color: Colors.grey.shade300,
            child: Center(
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    paidAmount = text.isEmpty ? 0 : int.parse(text);
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: InputBorder.none, focusedBorder: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No Token :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 50,
            color: Colors.grey.shade300,
            child: Center(
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    noToken = text.isEmpty ? 0 : int.parse(text);
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: InputBorder.none, focusedBorder: InputBorder.none),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              child: Text('Bayar'),
              onPressed: () => clickBayar((widget.cart.totalHargaWithDisc +
                  ((int.parse(user.vat) / 100) * widget.cart.totalHargaWithDisc)
                      .round())),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.black),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}

/*
 * Dialog Loading ------------------------------------------------------------------------------------
 */
class CartPayDialogLoading extends StatefulWidget {
  @override
  _CartPayDialogLoadingState createState() => _CartPayDialogLoadingState();
}

class _CartPayDialogLoadingState extends State<CartPayDialogLoading> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(
            width: 20,
          ),
          Text('Loading...')
        ],
      ),
    );
  }
}

/*
 * Dialog Success ------------------------------------------------------------------------------------- 
 */
class CartPayDialogSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Berhasil'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, 'success');
            },
            child: Text('Tutup'))
      ],
    );
  }
}

/*
 * Dialog Error ------------------------------------------------------------------------------------- 
 */
class CartPayDialogError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gagal'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Tutup'))
      ],
    );
  }
}
