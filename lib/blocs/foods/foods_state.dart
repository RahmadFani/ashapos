part of 'foods_cubit.dart';

class FoodsState extends Equatable {
  const FoodsState._({this.foods, this.status = FoodsStateStatus.initial});

  FoodsState.init() : this._(foods: List.empty());

  FoodsState.success({@required List<FoodModel> foods})
      : this._(foods: foods, status: FoodsStateStatus.success);

  FoodsState.failed()
      : this._(status: FoodsStateStatus.failed, foods: List.empty());

  bool get isinitial => status == FoodsStateStatus.initial;
  bool get issuccess => status == FoodsStateStatus.success;
  bool get isfailed => status == FoodsStateStatus.failed;

  final List<FoodModel> foods;

  final FoodsStateStatus status;

  @override
  List<Object> get props => [foods, status];
}

enum FoodsStateStatus { initial, success, failed }
