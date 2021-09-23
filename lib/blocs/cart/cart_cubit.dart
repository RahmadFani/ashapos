import 'package:ashapos/models/food.dart';
import 'package:bloc/bloc.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.empty());

  void emptyCart() {
    emit(CartState.empty());
  }

  ///
  /// Editing Cart Item
  ///
  /// [@type_param] => [class, int, int, int]
  /// [@param] => [item_model, qty, customprice, disc]
  ///
  void editingCartItem(FoodModel item,
      [int qty = 0,
      int customprice = 0,
      int disc = 0,
      String discType = 'Rp']) {
    List<CartItems> carts = state.carts.toList();
    CartItems test = carts
        .firstWhere((element) => element.itemModel.id == item.id, orElse: () {
      return CartItems(item, 0);
    });
    test.qty = qty;
    test.customPrice = customprice;
    test.discount = disc;
    test.discountType = discType;

    emit(state.copyWith(addingCarts: carts));
  }

  void addToCart(FoodModel item) {
    List<CartItems> carts = state.carts.toList();
    CartItems test = carts
        .firstWhere((element) => element.itemModel.id == item.id, orElse: () {
      return CartItems(item, 0);
    });
    if (test.qty == 0) {
      carts.add(test);
    }
    test.qty++;

    CartItems select = test;

    print(carts.length);

    emit(state.copyWith(select: select, addingCarts: carts));
  }

  void removeItem(FoodModel item) {
    List<CartItems> carts = state.carts.toList();
    CartItems test = carts.firstWhere(
        (element) => element.itemModel.id == item.id,
        orElse: () => CartItems(item, 0));

    carts.remove(test);

    emit(state.copyWith(addingCarts: carts));
  }

  void removeQtyItem(FoodModel item) {
    List<CartItems> carts = state.carts.toList();
    CartItems test = carts.firstWhere(
        (element) => element.itemModel.id == item.id,
        orElse: () => CartItems(item, 0));
    test.qty--;
    if (test.qty == 0) {
      carts.remove(test);
    }

    CartItems select = test;

    print(carts.length);

    emit(state.copyWith(select: select, addingCarts: carts));
  }

  void unselectitem() {
    emit(state.copyWith(unselect: true));
  }

  void itemSelect(FoodModel item) {
    print(state.carts.length);
    CartItems cartItems = state.carts.firstWhere(
        (element) => element.itemModel.id == item.id,
        orElse: () => CartItems(item, 0));
    emit(state.copyWith(select: cartItems));
  }
}
