import 'dart:convert';
import 'dart:developer';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/sales.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final ConnectivityCubit connectivityCubit;
  final AuthenticationCubit authenticationCubit;
  SalesCubit(
      {@required this.authenticationCubit, @required this.connectivityCubit})
      : super(SalesState.init());

  void initSales() async {
    if (state.isinitial) {
      getDataSales(isinitial: true);
    }
  }

  void refreshSales() async {
    emit(state.replace(status: SalesStatus.refresh));
    SharedPreferences pref = await SharedPreferences.getInstance();
    final connectivityState = connectivityCubit.state;

    if (connectivityState.isoffline) {
      final data = pref.getString('offline_sales') ?? null;
      if (data != null) {
        List json = jsonDecode(data);
        List<SalesModel> sales =
            json.map((e) => SalesModel.fromJson(e)).toList();

        emit(SalesState.success(
            saleslist: sales, newcurrent: 0, lastpagedata: true));
      } else {
        emit(SalesState.success(
            saleslist: List.empty(), newcurrent: 0, lastpagedata: true));
      }
      return;
    }

    UserModel user = authenticationCubit.state.user;
    bool lastpage = false;
    List<SalesModel> sales = [];

    try {
      final result = await http.post(Uri.parse(Api.url + 'get-sales.php'),
          body: {'start': 0.toString(), 'outlet-id': user.outletId});
      pref.setString('offline_sales', result.body);
      List json = jsonDecode(result.body);
      if (json.length == 0) {
        lastpage = true;
      }
      json.forEach((element) {
        sales.add(SalesModel.fromJson(element));
      });

      emit(SalesState.success(
          saleslist: sales, newcurrent: 0, lastpagedata: lastpage));
    } catch (e) {
      emit(SalesState.success(
          saleslist: List.empty(), newcurrent: 0, lastpagedata: true));
    }
  }

  void getDataSales({isinitial = false}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final connectivityState = connectivityCubit.state;
    if (connectivityState.isoffline) {
      final data = pref.getString('offline_sales') ?? null;
      if (data != null) {
        List json = jsonDecode(data);
        List<SalesModel> sales =
            json.map((e) => SalesModel.fromJson(e)).toList();

        emit(SalesState.success(
            saleslist: sales, newcurrent: 0, lastpagedata: true));
      } else {
        emit(SalesState.success(
            saleslist: List.empty(), newcurrent: 0, lastpagedata: true));
      }
      return;
    }

    UserModel user = authenticationCubit.state.user;
    int current = state.current;
    if (!isinitial) current = current + 10;
    bool lastpage = false;
    List<SalesModel> sales = state.sales.toList();

    try {
      final result = await http.post(Uri.parse(Api.url + 'get-sales.php'),
          body: {'start': current.toString(), 'outlet-id': user.outletId});

      pref.setString('offline_sales', result.body);

      List json = jsonDecode(result.body);
      if (json.length == 0) {
        lastpage = true;
      }
      json.forEach((element) {
        sales.add(SalesModel.fromJson(element));
      });

      emit(SalesState.success(
          saleslist: sales, newcurrent: current, lastpagedata: lastpage));
    } catch (e) {
      print(e.toString());
      getSalesLocal();
    }
  }

  void getSalesFromDate({DateTime date, bool nextpage = false}) async {
    emit(state.replace(status: SalesStatus.loading));

    UserModel user = authenticationCubit.state.user;
    int current = state.current;
    bool lastpage = false;
    List<SalesModel> sales = state.sales.toList();

    if (state.filter == SalesFilter.none || nextpage == false) {
      current = 0;
      sales = [];
    } else {
      current = current + 10;
    }

    try {
      final result =
          await http.post(Uri.parse(Api.url + 'get-sales-by-date.php'), body: {
        'start': current.toString(),
        'outlet-id': user.outletId,
        'date': '${date.year}-${date.month}-${date.day}'
      });
      log(result.body);

      List json = jsonDecode(result.body);
      log(json.length.toString());
      if (json.length == 0) {
        lastpage = true;
      }
      json.forEach((element) {
        sales.add(SalesModel.fromJson(element));
      });

      emit(SalesState.success(
          saleslist: sales,
          newcurrent: current,
          lastpagedata: lastpage,
          filter: SalesFilter.fromdate));
    } catch (e) {
      emit(SalesState.success(
          saleslist: List.empty(), newcurrent: 0, lastpagedata: true));
    } finally {
      emit(state.replace(status: SalesStatus.success));
    }
  }

  void getSalesLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final data = pref.getString('offline_sales') ?? null;
    if (data != null) {
      List json = jsonDecode(data);
      List<SalesModel> sales = json.map((e) => SalesModel.fromJson(e)).toList();

      emit(SalesState.success(
          saleslist: sales, newcurrent: 0, lastpagedata: true));
    } else {
      emit(SalesState.success(
          saleslist: List.empty(), newcurrent: 0, lastpagedata: true));
    }
  }
}
