class TransactionModel {
  String saleId;
  String customerId;
  String totalItems;
  String subtotal;
  String dueAmount;
  String duePaymentDate;
  String disc;
  String discActual;
  String vat;
  String totalPayable;
  String paymentMethod;
  String tableId;
  String tokenNumber;
  String saleDate;
  String dateTime;
  String saleTime;
  String userId;
  String companyId;
  String outletId;
  String delStatus;
  List<ItemsTransaction> items;

  TransactionModel(
      {this.saleId,
      this.customerId,
      this.totalItems,
      this.subtotal,
      this.dueAmount,
      this.duePaymentDate,
      this.disc,
      this.discActual,
      this.vat,
      this.totalPayable,
      this.paymentMethod,
      this.tableId,
      this.tokenNumber,
      this.saleDate,
      this.dateTime,
      this.saleTime,
      this.userId,
      this.companyId,
      this.outletId,
      this.delStatus,
      this.items});

  TransactionModel.fromJson(Map<String, dynamic> json) {
    saleId = json['sale-id'];
    customerId = json['customer-id'];
    totalItems = json['total-items'];
    subtotal = json['subtotal'];
    dueAmount = json['due-amount'];
    duePaymentDate = json['due-payment-date'];
    disc = json['disc'];
    discActual = json['disc-actual'];
    vat = json['vat'];
    totalPayable = json['total-payable'];
    paymentMethod = json['payment-method'];
    tableId = json['table-id'];
    tokenNumber = json['token-number'];
    saleDate = json['sale-date'];
    dateTime = json['date-time'];
    saleTime = json['sale-time'];
    userId = json['user-id'];
    companyId = json['company-id'];
    outletId = json['outlet-id'];
    delStatus = json['del-status'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) {
        print('item v');
        print(v);
        items.add(new ItemsTransaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sale-id'] = this.saleId;
    data['customer-id'] = this.customerId;
    data['total-items'] = this.totalItems;
    data['subtotal'] = this.subtotal;
    data['due-amount'] = this.dueAmount;
    data['due-payment-date'] = this.duePaymentDate;
    data['disc'] = this.disc;
    data['disc-actual'] = this.discActual;
    data['vat'] = this.vat;
    data['total-payable'] = this.totalPayable;
    data['payment-method'] = this.paymentMethod;
    data['table-id'] = this.tableId;
    data['token-number'] = this.tokenNumber;
    data['sale-date'] = this.saleDate;
    data['date-time'] = this.dateTime;
    data['sale-time'] = this.saleTime;
    data['user-id'] = this.userId;
    data['company-id'] = this.companyId;
    data['outlet-id'] = this.outletId;
    data['del-status'] = this.delStatus;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemsTransaction {
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

  ItemsTransaction(
      {this.foodMenuId,
      this.menuName,
      this.price,
      this.qty,
      this.discountAmount,
      this.total,
      this.salesId,
      this.userId,
      this.outletId,
      this.delStatus});

  ItemsTransaction.fromJson(Map<String, dynamic> json) {
    foodMenuId = json['food-menu-id'];
    menuName = json['menu-name'];
    price = json['price'];
    qty = json['qty'];
    discountAmount = json['discount-amount'];
    total = json['total'];
    salesId = json['sales-id'];
    userId = json['user-id'];
    outletId = json['outlet-id'];
    delStatus = json['del-status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['food-menu-id'] = this.foodMenuId;
    data['menu-name'] = this.menuName;
    data['price'] = this.price;
    data['qty'] = this.qty;
    data['discount-amount'] = this.discountAmount;
    data['total'] = this.total;
    data['sales-id'] = this.salesId;
    data['user-id'] = this.userId;
    data['outlet-id'] = this.outletId;
    data['del-status'] = this.delStatus;
    return data;
  }
}
