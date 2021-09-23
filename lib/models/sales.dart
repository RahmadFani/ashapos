
class SalesModel {
  String id;
  String customerId;
  String saleNo;
  String totalItems;
  String subTotal;
  String paidAmount;
  String dueAmount;
  String duePaymentDate;
  String disc;
  String discActual;
  String vat;
  String totalPayable;
  String paymentMethodId;
  String tableId;
  String tokenNo;
  String saleDate;
  String dateTime;
  String saleTime;
  String userId;
  String companyId;
  String outletId;
  String delStatus;

  SalesModel(
      {this.id,
      this.customerId,
      this.saleNo,
      this.totalItems,
      this.subTotal,
      this.paidAmount,
      this.dueAmount,
      this.duePaymentDate,
      this.disc,
      this.discActual,
      this.vat,
      this.totalPayable,
      this.paymentMethodId,
      this.tableId,
      this.tokenNo,
      this.saleDate,
      this.dateTime,
      this.saleTime,
      this.userId,
      this.companyId,
      this.outletId,
      this.delStatus});

  SalesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    saleNo = json['sale_no'];
    totalItems = json['total_items'];
    subTotal = json['sub_total'];
    paidAmount = json['paid_amount'];
    dueAmount = json['due_amount'];
    duePaymentDate = json['due_payment_date'];
    disc = json['disc'];
    discActual = json['disc_actual'];
    vat = json['vat'];
    totalPayable = json['total_payable'];
    paymentMethodId = json['payment_method_id'];
    tableId = json['table_id'];
    tokenNo = json['token_no'];
    saleDate = json['sale_date'];
    dateTime = json['date_time'];
    saleTime = json['sale_time'];
    userId = json['user_id'];
    companyId = json['company_id'];
    outletId = json['outlet_id'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['sale_no'] = this.saleNo;
    data['total_items'] = this.totalItems;
    data['sub_total'] = this.subTotal;
    data['paid_amount'] = this.paidAmount;
    data['due_amount'] = this.dueAmount;
    data['due_payment_date'] = this.duePaymentDate;
    data['disc'] = this.disc;
    data['disc_actual'] = this.discActual;
    data['vat'] = this.vat;
    data['total_payable'] = this.totalPayable;
    data['payment_method_id'] = this.paymentMethodId;
    data['table_id'] = this.tableId;
    data['token_no'] = this.tokenNo;
    data['sale_date'] = this.saleDate;
    data['date_time'] = this.dateTime;
    data['sale_time'] = this.saleTime;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['outlet_id'] = this.outletId;
    data['del_status'] = this.delStatus;
    return data;
  }
}