class Stok {
  late String? barcode;
  late String? assetName;
  late String? category;
  late String? cabang;
  late String? stokIn;
  late String? stokOut;
  late String? good;
  late String? bad;
  late String? cretedAt;

  Stok(
      {this.barcode,
      this.assetName,
      this.category,
      this.cabang,
      this.stokIn,
      this.stokOut,
      this.good,
      this.bad,
      this.cretedAt});

  Stok.fromJson(Map<String, dynamic> json) {
    barcode = json['barcode'];
    cabang = json['cabang'];
    assetName = json['asset_name'];
    category = json['category_name']??'';
    stokIn = json['in'];
    stokOut = json['out']??'0';
    good = json['good_stat']??'0';
    bad = json['bad_stat']??'0';
  }
}
