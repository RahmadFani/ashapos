import 'dart:async';
import 'dart:convert';

import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/transaction.dart';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  StreamSubscription subscription;

  ConnectivityCubit() : super(ConnectivityState.init()) {
    subscription?.cancel();
    subscription = Connectivity().onConnectivityChanged.listen(connectivity);
  }

  void connectivity(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      emit(state.changed(ConnectivityStatus.offline));
    } else {
      transactionPush();
      emit(state.changed(ConnectivityStatus.online));
    }
    print('connectivity result : ' + result.toString());
  }

  void transactionPush() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> transaction = pref.getStringList('transactions_offline') ?? [];
    List<String> transactionRemove = [];
    print('Transaction OFFLINE LENGTH : ${transaction.length}');
    if (transaction.length > 0) {
      await Future.forEach(transaction, (String trans) async {
        final json = jsonDecode(trans);
        TransactionModel data = TransactionModel.fromJson(json);
        Map<String, String> body = {
          'customer-id': data.customerId,
          'total-items': data.totalItems,
          'subtotal': data.subtotal,
          'due-amount': "",
          'due-payment-date': "",
          'disc': data.disc,
          'disc-actual': data.discActual,
          'vat': data.vat, // Belum Selesai / API kurang join.
          'total-payable': data.totalPayable,
          'payment-method': data.paymentMethod,
          'table-id': data.tableId,
          'token-number': data.tokenNumber,
          'sale-date': data.saleDate,
          'date-time': data.dateTime,
          'sale-time': data.saleTime,
          'user-id': data.userId,
          'company-id': data.companyId,
          'outlet-id': data.outletId,
          'del-status': "Live"
        };
        try {
          final resAddSales =
              await http.post(Uri.parse(Api.url + 'add-sales.php'), body: body);

          print(resAddSales.body);
          String id = jsonDecode(resAddSales.body)['id'];

          await Future.forEach(data.items, (ItemsTransaction element) async {
            final res = await http
                .post(Uri.parse(Api.url + 'add-sales-details.php'), body: {
              'food-menu-id': element.foodMenuId,
              'menu-name': element.menuName,
              'price': element.price,
              'qty': element.qty.toString(),
              'discount-amount': element.discountAmount,
              'total': element.total.toString(),
              'sales-id': id,
              'user-id': element.userId,
              'outlet-id': element.outletId,
              'del-status': 'Live'
            });
            print(res.body);
          });

          await http.post(Uri.parse(Api.url + 'get-sales-details.php'),
              body: {'id': id});

          transactionRemove.add(trans);
        } catch (e) {
          print("ERROR : " + e.toString());
        }
      });
      final transactionModif = transaction.where((e) {
        return !transactionRemove.contains(e);
      }).toList();
      pref.setStringList('transactions_offline', transactionModif);
    }
  }
}
