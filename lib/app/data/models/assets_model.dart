class AssetsModel {
  late String? id;
  late String? branchCode;
  late String? assetName;
  late String? assetsCode;
  late String? image;
  late String? category;
  late String? price;
  late String? satuan;
  late String? stock;
  late String? stockIn;
  late String? stockOut;
  late String? kelompok;

  AssetsModel(
      {this.id,
      this.branchCode,
      this.assetName,
      this.image,
      this.assetsCode,
      this.category,
      this.price,
      this.satuan,
      this.stock,
      this.stockIn,
      this.stockOut,
      this.kelompok});

  AssetsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchCode = json['branch_code']??'';
    assetName = json['asset_name'];
    assetsCode = json['asset_code'];  
    image = json['image']??'';  
    category = json['category_name']??'';
    price = json['price'];
    satuan = json['unit']??'';
    stock = json['stok_awal']??'';
    stockIn = json['in']??'';
    stockOut = json['out']??'';
    kelompok = json['group']??'';
  }
}
