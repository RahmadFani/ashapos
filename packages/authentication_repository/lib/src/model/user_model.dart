class UserModel {
  String id;
  String fullName;
  String phone;
  String emailAddress;
  String password;
  String role;
  String outletId;
  String companyId;
  String accountCreationDate;
  String lastLogin;
  String activeStatus;
  String delStatus;
  String outletName;
  String areaId;
  String address;
  String collectVat;
  String logo;
  String vatRegNo;
  String invoicePrint;
  String printSelect;
  String kotPrint;
  String startingDate;
  String nextExpiry;
  String userId;
  String namaWp;
  String alamatWp;
  String waktuBuka;
  String status;
  String nopd;
  String npwpd;
  String namaObjekUsaha;
  String alamatObjekUsaha;
  String kategoriUsahaId;
  String vat;
  String footer;

  UserModel(
      {this.id,
      this.fullName,
      this.phone,
      this.emailAddress,
      this.logo,
      this.password,
      this.role,
      this.outletId,
      this.companyId,
      this.accountCreationDate,
      this.lastLogin,
      this.activeStatus,
      this.delStatus,
      this.outletName,
      this.areaId,
      this.address,
      this.collectVat,
      this.vatRegNo,
      this.invoicePrint,
      this.printSelect,
      this.footer,
      this.kotPrint,
      this.startingDate,
      this.nextExpiry,
      this.userId,
      this.namaWp,
      this.alamatWp,
      this.waktuBuka,
      this.status,
      this.nopd,
      this.npwpd,
      this.namaObjekUsaha,
      this.alamatObjekUsaha,
      this.kategoriUsahaId,
      this.vat});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    phone = json['phone'];
    emailAddress = json['email_address'];
    password = json['password'];
    role = json['role'];
    footer = json['footer'];
    outletId = json['outlet_id'];
    companyId = json['company_id'];
    logo = json['logo'];
    accountCreationDate = json['account_creation_date'];
    lastLogin = json['last_login'];
    activeStatus = json['active_status'];
    delStatus = json['del_status'];
    outletName = json['outlet_name'];
    areaId = json['area_id'];
    address = json['address'];
    collectVat = json['collect_vat'];
    vatRegNo = json['vat_reg_no'];
    invoicePrint = json['invoice_print'];
    printSelect = json['print_select'];
    kotPrint = json['kot_print'];
    startingDate = json['starting_date'];
    nextExpiry = json['next_expiry'];
    userId = json['user_id'];
    namaWp = json['nama_wp'];
    alamatWp = json['alamat_wp'];
    waktuBuka = json['waktu_buka'];
    status = json['status'];
    nopd = json['nopd'];
    npwpd = json['npwpd'];
    namaObjekUsaha = json['nama_objek_usaha'];
    alamatObjekUsaha = json['alamat_objek_usaha'];
    kategoriUsahaId = json['kategori_usaha_id'];
    vat = json['vat_percentage'] ?? '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['full_name'] = this.fullName;
    data['phone'] = this.phone;
    data['email_address'] = this.emailAddress;
    data['password'] = this.password;
    data['role'] = this.role;
    data['outlet_id'] = this.outletId;
    data['company_id'] = this.companyId;
    data['account_creation_date'] = this.accountCreationDate;
    data['last_login'] = this.lastLogin;
    data['active_status'] = this.activeStatus;
    data['del_status'] = this.delStatus;
    data['outlet_name'] = this.outletName;
    data['area_id'] = this.areaId;
    data['address'] = this.address;
    data['collect_vat'] = this.collectVat;
    data['vat_reg_no'] = this.vatRegNo;
    data['invoice_print'] = this.invoicePrint;
    data['print_select'] = this.printSelect;
    data['kot_print'] = this.kotPrint;
    data['starting_date'] = this.startingDate;
    data['next_expiry'] = this.nextExpiry;
    data['user_id'] = this.userId;
    data['nama_wp'] = this.namaWp;
    data['alamat_wp'] = this.alamatWp;
    data['waktu_buka'] = this.waktuBuka;
    data['status'] = this.status;
    data['nopd'] = this.nopd;
    data['npwpd'] = this.npwpd;
    data['nama_objek_usaha'] = this.namaObjekUsaha;
    data['alamat_objek_usaha'] = this.alamatObjekUsaha;
    data['kategori_usaha_id'] = this.kategoriUsahaId;
    data['vat_percentage'] = this.vat;
    return data;
  }
}
