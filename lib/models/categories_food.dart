class CategoriesFoodModel {
  String id;
  String categoryName;
  String description;
  String userId;
  String companyId;
  String outletId;
  String delStatus;

  CategoriesFoodModel(
      {this.id,
      this.categoryName,
      this.description,
      this.userId,
      this.companyId,
      this.outletId,
      this.delStatus});

  CategoriesFoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    description = json['description'];
    userId = json['user_id'];
    companyId = json['company_id'];
    outletId = json['outlet_id'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_name'] = this.categoryName;
    data['description'] = this.description;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['outlet_id'] = this.outletId;
    data['del_status'] = this.delStatus;
    return data;
  }
}
