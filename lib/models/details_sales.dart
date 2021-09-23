class DetailSalesModel {
  String id;
  String foodMenuId;
  String menuName;
  String price;
  String qty;
  String discountAmount;
  String total;
  String salesId;
  String userId;
  String outletId;
  String delStatus;

  DetailSalesModel(
      {this.id,
      this.foodMenuId,
      this.menuName,
      this.price,
      this.qty,
      this.discountAmount,
      this.total,
      this.salesId,
      this.userId,
      this.outletId,
      this.delStatus});

  DetailSalesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    foodMenuId = json['food_menu_id'];
    menuName = json['menu_name'];
    price = json['price'];
    qty = json['qty'];
    discountAmount = json['discount_amount'];
    total = json['total'];
    salesId = json['sales_id'];
    userId = json['user_id'];
    outletId = json['outlet_id'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['food_menu_id'] = this.foodMenuId;
    data['menu_name'] = this.menuName;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['discount_amount'] = this.discountAmount;
    data['total'] = this.total;
    data['sales_id'] = this.salesId;
    data['user_id'] = this.userId;
    data['outlet_id'] = this.outletId;
    data['del_status'] = this.delStatus;
    return data;
  }
}
