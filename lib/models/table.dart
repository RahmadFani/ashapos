class TableModel {
  String id;
  String name;
  String sitCapacity;
  String position;
  String description;
  String userId;
  String outletId;
  String companyId;
  String delStatus;

  TableModel(
      {this.id,
      this.name,
      this.sitCapacity,
      this.position,
      this.description,
      this.userId,
      this.outletId,
      this.companyId,
      this.delStatus});

  TableModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sitCapacity = json['sit_capacity'];
    position = json['position'];
    description = json['description'];
    userId = json['user_id'];
    outletId = json['outlet_id'];
    companyId = json['company_id'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['sit_capacity'] = this.sitCapacity;
    data['position'] = this.position;
    data['description'] = this.description;
    data['user_id'] = this.userId;
    data['outlet_id'] = this.outletId;
    data['company_id'] = this.companyId;
    data['del_status'] = this.delStatus;
    return data;
  }
}
