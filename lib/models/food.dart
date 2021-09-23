class FoodModel {
  String id;
  String code;
  String name;
  String categoryId;
  String description;
  String salePrice;
  String vatId;
  String userId;
  String companyId;
  String outletId;
  String pcOriginalThumb;
  String pcMobileThumb;
  String pcTebThumb;
  String pcDesktopThumb;
  String delStatus;

  FoodModel(
      {this.id,
      this.code,
      this.name,
      this.categoryId,
      this.description,
      this.salePrice,
      this.vatId,
      this.userId,
      this.companyId,
      this.outletId,
      this.pcOriginalThumb,
      this.pcMobileThumb,
      this.pcTebThumb,
      this.pcDesktopThumb,
      this.delStatus});

  FoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    categoryId = json['category_id'];
    description = json['description'];
    salePrice = json['sale_price'];
    vatId = json['vat_id'];
    userId = json['user_id'];
    companyId = json['company_id'];
    outletId = json['outlet_id'];
    pcOriginalThumb = json['pc_original_thumb'];
    pcMobileThumb = json['pc_mobile_thumb'];
    pcTebThumb = json['pc_teb_thumb'];
    pcDesktopThumb = json['pc_desktop_thumb'];
    delStatus = json['del_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['category_id'] = this.categoryId;
    data['description'] = this.description;
    data['sale_price'] = this.salePrice;
    data['vat_id'] = this.vatId;
    data['user_id'] = this.userId;
    data['company_id'] = this.companyId;
    data['outlet_id'] = this.outletId;
    data['pc_original_thumb'] = this.pcOriginalThumb;
    data['pc_mobile_thumb'] = this.pcMobileThumb;
    data['pc_teb_thumb'] = this.pcTebThumb;
    data['pc_desktop_thumb'] = this.pcDesktopThumb;
    data['del_status'] = this.delStatus;
    return data;
  }
}