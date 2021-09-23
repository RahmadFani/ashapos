import 'dart:convert';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/customer.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class SearchPelanggan extends StatefulWidget {
  @override
  _SearchPelangganState createState() => _SearchPelangganState();
}

class _SearchPelangganState extends State<SearchPelanggan> {
  String error;
  bool loading = true;
  List<CustomerModel> customers = [];
  List<CustomerModel> initialcustomers = [];

  @override
  void initState() {
    super.initState();
    searchingCustomer();
  }

  void searchingCustomer() async {
    try {
      final auth = BlocProvider.of<AuthenticationCubit>(context).state;
      final result = await http.post(
          Uri.parse(Api.url + 'get-customers-by-outlet-id.php'),
          body: {'outlet-id': auth.user.outletId});

      List jsonlist = jsonDecode(result.body);
      List<CustomerModel> list =
          jsonlist.map((e) => CustomerModel.fromJson(e)).toList();
      setState(() {
        customers = list;
        initialcustomers = list;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  bool get haserror => error != null;

  void searchWhereCustomer(String text) {
    List<CustomerModel> list = initialcustomers
        .where((element) =>
            element.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
    setState(() {
      customers = list;
    });
  }

  void _addPelanggan() async {
    final data = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => FormAddPelanggan()));
    if (data is CustomerModel)
      setState(() {
        initialcustomers.add(data);
        customers = initialcustomers;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Pelanggan'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPelanggan,
        child: Icon(Icons.add),
      ),
      body: haserror
          ? SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline),
                  Text('Terjadi Kesalahan.')
                ],
              ),
            )
          : Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          onChanged: searchWhereCustomer,
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: OutlineInputBorder(),
                              labelText: 'Cari',
                              hintText: 'Masukan nama pelanggan.'),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: customers.length == 0
                        ? Center(
                            child: Text('Data Pelanggan Kosong.'),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                ...List.generate(customers.length, (index) {
                                  CustomerModel customer = customers[index];
                                  return Container(
                                    height: 80,
                                    child: Card(
                                      elevation: 5,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context, customer);
                                        },
                                        child: Center(
                                          child: ListTile(
                                            title: Text(
                                              customer.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            trailing: Text(
                                              'pilih',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class FormAddPelanggan extends StatefulWidget {
  @override
  _FormAddPelangganState createState() => _FormAddPelangganState();
}

class _FormAddPelangganState extends State<FormAddPelanggan> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  String nama = '';
  String email = '';
  String nomor = '';
  String alamat = '';

  bool loading = false;

  void _addingCustomer() async {
    if (nama.isEmpty) {
      ScaffoldMessenger.of(_scaffold.currentContext).showSnackBar(SnackBar(
        content: Text('Nama pelanggan wajib di isi'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() {
      loading = true;
    });
    UserModel user = BlocProvider.of<AuthenticationCubit>(context).state.user;
    try {
      final result =
          await http.post(Uri.parse(Api.url + 'add-customer.php'), body: {
        'email': email,
        'name': nama,
        'outlet-id': user.outletId,
        'company-id': user.companyId,
        'user-id': user.id,
        'address': alamat,
        'del-status': 'LIVE',
        'phone': nomor
      });
      if (result.statusCode == 200) {
        final json = jsonDecode(result.body);
        CustomerModel pelanggan = CustomerModel.fromJson(json);
        Navigator.pop(context, pelanggan);
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(_scaffold.currentContext).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Gagal menambah pelanggan'),
      ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _scaffold,
          appBar: AppBar(
            title: Text('Tambah Pelanggan'),
          ),
          body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            nama = text;
                          });
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Nama',
                            hintText: 'Masukan nama pelanggan'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            email = text;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Email',
                            hintText: 'Masukan email pelanggan'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            nomor = text;
                          });
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Nomor Telepon',
                            hintText: 'Masukan nomor telepon pelanggan'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        onChanged: (text) {
                          setState(() {
                            alamat = text;
                          });
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (text) {
                          _addingCustomer();
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Alamat',
                            hintText: 'Masukan alamat pelanggan'),
                      ),
                    ],
                  ))),
        ),
        Positioned(
            bottom: 0,
            height: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(15),
              child: ElevatedButton(
                  onPressed: loading ? null : _addingCustomer,
                  child: Text('Tambah Pelanggan')),
            )),
        if (loading)
          Container(
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(30),
                color: Colors.grey.shade300,
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          )
      ],
    );
  }
}
