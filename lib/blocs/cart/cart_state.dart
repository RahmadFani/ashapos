part of 'cart_cubit.dart';

class CartState {
  const CartState._({this.carts, this.onselect});

  CartState.empty() : this._(carts: List.empty(), onselect: null);

  CartState({this.carts, this.onselect});

  CartState copyWith(
      {List<CartItems> addingCarts, CartItems select, bool unselect}) {
    return CartState(
        carts: addingCarts ?? this.carts,
        onselect: unselect == true ? null : select ?? this.onselect);
  }

  int get totalDisc => this.carts.length == 0
      ? 0
      : this
          .carts
          .map((e) => e.totalDisc)
          .reduce((value, element) => value + element);

  int get totalPpn => this.carts.length == 0
      ? 0
      : this
          .carts
          .map((e) => e.ppn)
          .reduce((value, element) => value + element);

  int get totalHarga => this.carts.length == 0
      ? 0
      : this
          .carts
          .map((e) => (e.total))
          .reduce((value, element) => value + element);
  int get totalHargaWithDisc => this.carts.length == 0
      ? 0
      : this
          .carts
          .map((e) => (e.totalWithDisc))
          .reduce((value, element) => value + element);

  final List<CartItems> carts;
  final CartItems onselect;
}

class CartItems {
  /// Creates a new CartItems list.
  ///
  /// @param [item_model, qty => default 0, custom_price => default 0, discount => default 0, discountType => default Rp],
  ///
  /// Example ...
  /// CartItems(item_model, qty, custom_price, discount, discountType)
  ///
  CartItems(this.itemModel,
      [this.qty = 0,
      this.customPrice = 0,
      this.discount = 0,
      this.discountType = 'Rp']);

  /// item model
  FoodModel itemModel;

  /// qty
  int qty;

  /// custom price
  int customPrice;

  /// discount
  int discount;

  /// discount type
  String discountType;

  ///
  /// Perhitungan Total With Disc
  ///
  double get price => customPrice == 0
      ? double.parse(itemModel.salePrice)
      : double.parse(customPrice.toString());
  int get total => (price * qty).round();
  int get ppn => itemModel.vatId == '1' ? ((10 / 100) * total).round() : 0;
  int get totalWithDisc => discountType == 'Rp'
      ? total - discount
      : (total - (discount / 100) * total).round();
  int get totalDisc =>
      discountType == 'Rp' ? discount : ((discount / 100) * total).round();
}
