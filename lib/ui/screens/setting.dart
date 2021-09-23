import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => SettingPage());
  }

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    initStatus();
  }

  void initStatus() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  bool connected = false;
  List availableBluetoothDevices = new List.empty();

  Future<void> getBluetooth() async {
    final List bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });

    if (bluetooths.length == 0)
      ScaffoldMessenger.of(_scaffold.currentContext).showSnackBar(SnackBar(
        content: Text('Tidak Ada Devices..'),
      ));
  }

  Future<void> setConnect(String mac) async {
    try {
      initStatus();
      final String result = await BluetoothThermalPrinter.connect(mac);
      print("state conneected $result");
      if (result == "true") {
        setState(() {
          connected = true;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> printTicket() async {
    String isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text(
          'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
      bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
          styles: PosStyles(codeTable: 'CP1252'));
      bytes += generator.text('Special 2: blåbærgrød',
          styles: PosStyles(codeTable: 'CP1252'));

      bytes += generator.text('Bold text', styles: PosStyles(bold: true));
      bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
      bytes += generator.text('Underlined text',
          styles: PosStyles(underline: true), linesAfter: 1);
      bytes +=
          generator.text('Align left', styles: PosStyles(align: PosAlign.left));
      bytes += generator.text('Align center',
          styles: PosStyles(align: PosAlign.center));
      bytes += generator.text('Align right',
          styles: PosStyles(align: PosAlign.right), linesAfter: 1);

      bytes += generator.row([
        PosColumn(
          text: 'col3',
          width: 3,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col6',
          width: 6,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col3',
          width: 3,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
      ]);

      bytes += generator.text('Text size 200%',
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));

      // Print image:

      // Print image using an alternative (obsolette) command
      // bytes += generator.imageRaster(image);

      // Print barcode
      final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
      bytes += generator.barcode(Barcode.upcA(barData));

      // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
      // ticket.text(
      //   'hello ! 中文字 # world @ éphémère &',
      //   styles: PosStyles(codeTable: PosCodeTable.westEur),
      //   containsChinese: true,
      // );

      bytes += generator.qrcode('text');

      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {}
  }

  Future<void> printGraphics() async {}

  Future<Generator> getGraphicsTicket() async {
    CapabilityProfile profile = await CapabilityProfile.load();
    final Generator ticket = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    ticket.qrcode('example.com');

    ticket.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    ticket.barcode(Barcode.upcA(barData));

    ticket.cut();

    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text('Setting'),
        actions: [
          connected
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      connected = false;
                    });
                  },
                  child: Text(
                    'Disconected',
                    style: TextStyle(color: Colors.white),
                  ))
              : SizedBox.shrink()
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !connected
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Search Paired Bluetooth"),
                      OutlinedButton(
                        onPressed: () {
                          this.getBluetooth();
                        },
                        child: Text("Search"),
                      ),
                      Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: availableBluetoothDevices.length > 0
                              ? availableBluetoothDevices.length
                              : 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String select =
                                    availableBluetoothDevices[index];
                                prefs.setString('bluetooth_connect', select);

                                List list = select.split("#");
                                //String name = list[0];
                                String mac = list[1];
                                setConnect(mac);
                              },
                              title:
                                  Text('${availableBluetoothDevices[index]}'),
                              subtitle: Text("Click to connect"),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            OutlinedButton(
              onPressed: connected ? printTicket : null,
              child: Text("Test Print"),
            ),
          ],
        ),
      ),
    );
  }
}
