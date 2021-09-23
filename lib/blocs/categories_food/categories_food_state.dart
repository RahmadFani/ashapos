part of 'categories_food_cubit.dart';

class CategoriesFoodState extends Equatable {
  const CategoriesFoodState(
      {this.status = CategoriesFoodStatus.initial, this.categories});
  const CategoriesFoodState._(
      {this.status = CategoriesFoodStatus.initial, this.categories});

  CategoriesFoodState.init() : this._(categories: List.empty());

  CategoriesFoodState.success({List<CategoriesFoodModel> listCategory})
      : this._(categories: listCategory, status: CategoriesFoodStatus.success);

  CategoriesFoodState.failed()
      : this._(
          categories: List.empty(),
          status: CategoriesFoodStatus.failed,
        );

  final CategoriesFoodStatus status;
  final List<CategoriesFoodModel> categories;

  bool get issuccess => status == CategoriesFoodStatus.success;
  bool get isfailed => status == CategoriesFoodStatus.failed;
  bool get isinitial => status == CategoriesFoodStatus.initial;

  @override
  List<Object> get props => [categories, status];
}

enum CategoriesFoodStatus { initial, success, failed }
