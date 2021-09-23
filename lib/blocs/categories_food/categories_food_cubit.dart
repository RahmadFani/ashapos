import 'dart:convert';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/helpers/api.dart';
import 'package:ashapos/models/categories_food.dart';
import 'package:authentication_repository/authentication_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'categories_food_state.dart';

class CategoriesFoodCubit extends Cubit<CategoriesFoodState> {
  final AuthenticationCubit authenticationCubit;
  final ConnectivityCubit connectivityCubit;
  CategoriesFoodCubit(
      {@required this.authenticationCubit, @required this.connectivityCubit})
      : super(CategoriesFoodState.init());

  void initCategoriesFood() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final connectivityState = connectivityCubit.state;

    if (connectivityState.isoffline) {
      final data = pref.getString('offline_categories_food') ?? null;
      if (data != null) {
        List listJson = jsonDecode(data);
        List<CategoriesFoodModel> categories =
            listJson.map((e) => CategoriesFoodModel.fromJson(e)).toList();
        emit(CategoriesFoodState.success(listCategory: categories));
      } else {
        emit(CategoriesFoodState.failed());
      }
      return;
    }

    try {
      UserModel user = authenticationCubit.state.user;

      final result = await http.post(
          Uri.parse(Api.url + 'get-food-categories.php'),
          body: {'outlet-id': user.outletId});

      pref.setString('offline_categories_food', result.body);
      List listJson = jsonDecode(result.body);

      List<CategoriesFoodModel> categories =
          listJson.map((e) => CategoriesFoodModel.fromJson(e)).toList();
      emit(CategoriesFoodState.success(listCategory: categories));
    } catch (e) {
      getCategoriesFoodLocal();
    }
  }

  void getCategoriesFoodLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final data = pref.getString('offline_categories_food') ?? null;
    if (data != null) {
      List listJson = jsonDecode(data);
      List<CategoriesFoodModel> categories =
          listJson.map((e) => CategoriesFoodModel.fromJson(e)).toList();
      emit(CategoriesFoodState.success(listCategory: categories));
    } else {
      emit(CategoriesFoodState.failed());
    }
  }
}
