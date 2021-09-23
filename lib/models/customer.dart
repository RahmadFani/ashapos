class CustomerModel {
  String id;
  String name;
  String phone;
  String email;
  String address;
  String areaId;
  String userId;
  String companyId;
  String outletId;
  String delStatus;

  CustomerModel(
      {this.id,
      this.name,
      this.phone,
      this.email,
      this.address,
      this.areaId,
      this.userId,
      this.companyId,
      this.outletId,
      this.delStatus});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    areaId = json['area_id'];
    userId = json['user_id'];
    companyId = json['company_id'];
    outletId = json['outlet_id'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['address'] = this.address;
    data['area_id'] = this.areaId;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['outlet_id'] = this.outletId;
    data['del_status'] = this.delStatus;
    return data;
  }
}
