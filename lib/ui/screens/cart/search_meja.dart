import 'dart:convert';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class SearchMeja extends StatefulWidget {
  @override
  _SearchMejaState createState() => _SearchMejaState();
}

class _SearchMejaState extends State<SearchMeja> {
  String error;
  bool loading = true;
  List<TableModel> customers = [];
  List<TableModel> initialcustomers = [];

  @override
  void initState() {
    super.initState();
    searchingCustomer();
  }

  void searchingCustomer() async {
    try {
      final auth = BlocProvider.of<AuthenticationCubit>(context).state;
      final result =
          await http.post(Uri.parse(Api.url + 'get-tables.php'), body: {
        'outlet_id': auth.user.outletId,
        'user_id': auth.user.id,
        'company_id': auth.user.companyId
      });

      List jsonlist = jsonDecode(result.body);
      List<TableModel> list =
          jsonlist.map((e) => TableModel.fromJson(e)).toList();
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
    List<TableModel> list = initialcustomers
        .where((element) =>
            element.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
    setState(() {
      customers = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator.adaptive(),
                SizedBox(
                  width: 20,
                ),
                Text('Loading...')
              ],
            ),
          )
        : AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Meja'),
                TextField(
                  onChanged: searchWhereCustomer,
                  decoration: InputDecoration(labelText: 'Search'),
                )
              ],
            ),
            content: haserror
                ? Column(
                    children: [
                      Icon(Icons.info_outline),
                      Text('Terjadi Kesalahan.')
                    ],
                  )
                : Container(
                    child: customers.length == 0
                        ? Row(children: [
                            Text('Data Meja Kosong.'),
                          ])
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                ...List.generate(customers.length, (index) {
                                  TableModel customer = customers[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context, customer);
                                    },
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
                                  );
                                })
                              ],
                            ),
                          ),
                  ),
          );
  }
}
