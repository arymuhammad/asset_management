class AssetsModel {
  late String? id;
  late String? branchCode;
  late String? assetName;
  late String? serialNo;
  late String? assetsCode;
  late String? image;
  late String? group;
  late String? categoryId;
  late String? categoryName;
  late String? purchaseDate;
  late String? price;
  late String? satuan;
  late String? stock;
  late String? stockIn;
  late String? stockOut;
  late String? kelompok;
  late String? total;

  AssetsModel(
      {this.id,
      this.branchCode,
      this.assetName,
      this.serialNo,
      this.image,
      this.assetsCode,
      this.group,
      this.categoryId,
      this.categoryName,
      this.purchaseDate,
      this.price,
      this.satuan,
      this.stock,
      this.stockIn,
      this.stockOut,
      this.kelompok,
      this.total,
      });

  AssetsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchCode = json['branch_code']??'';
    assetName = json['asset_name'];
    assetsCode = json['asset_code'];  
    serialNo = json['serial_number']??'';  
    image = json['image']??'';  
    group = json['group']??'';
    categoryId = json['cat_id']??'';
    categoryName = json['category_name']??'';
    purchaseDate = json['purchase_date'];
    price = json['price'];
    satuan = json['unit']??'';
    stock = json['stok_awal']??'';
    stockIn = json['in']??'';
    stockOut = json['out']??'';
    kelompok = json['group']??'';
    total = json['total']??'';
  }
}
