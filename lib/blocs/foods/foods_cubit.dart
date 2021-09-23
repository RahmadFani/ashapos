import 'dart:convert';

import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/models/categories_food.dart';
import 'package:ashapos/models/food.dart';
import 'package:authentication_repository/helpers/api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'foods_state.dart';

class FoodsCubit extends Cubit<FoodsState> {
  final CategoriesFoodModel categoriesFoodModel;
  final ConnectivityCubit connectivityCubit;

  FoodsCubit(
      {@required this.categoriesFoodModel, @required this.connectivityCubit})
      : super(FoodsState.init());

  void initial() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final connectivityState = connectivityCubit.state;

    if (connectivityState.isoffline) {
      final data =
          pref.getString('offline_food_${categoriesFoodModel.id}') ?? null;
      if (data != null) {
        List listJson = jsonDecode(data);

        List<FoodModel> foods =
            listJson.map((e) => FoodModel.fromJson(e)).toList();

        emit(FoodsState.success(foods: foods));
      } else {
        emit(FoodsState.failed());
      }
      return;
    }

    try {
      final result = await http.post(Uri.parse(Api.url + 'get-foods.php'),
          body: {'category-id': categoriesFoodModel.id});

      pref.setString('offline_food_${categoriesFoodModel.id}', result.body);
      List listJson = jsonDecode(result.body);

      List<FoodModel> foods =
          listJson.map((e) => FoodModel.fromJson(e)).toList();

      emit(FoodsState.success(foods: foods));
    } catch (e) {
      getFoodsLocal();
    }
  }

  void getFoodsLocal() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final data =
        pref.getString('offline_food_${categoriesFoodModel.id}') ?? null;
    if (data != null) {
      List listJson = jsonDecode(data);

      List<FoodModel> foods =
          listJson.map((e) => FoodModel.fromJson(e)).toList();

      emit(FoodsState.success(foods: foods));
    } else {
      emit(FoodsState.failed());
    }
  }
}
