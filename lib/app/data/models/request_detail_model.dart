class RequestDetailModel {
  late String? id;
  late String? assetCode;
  late String? assetName;
  late String? image;
  late String? qtyStock;
  late String? qtyReq;
  late String? unit;
  late String? price;

  RequestDetailModel({
    this.id,
    this.assetCode,
    this.assetName,
    this.image,
    this.qtyStock,
    this.qtyReq,
    this.unit,
    this.price,
  });
  RequestDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    assetCode = json['asset_code'] ?? '';
    assetName = json['asset_name'] ?? '';
    image = json['image'] ?? '';
    qtyStock = json['qty_stock'] ?? json['total'];
    qtyReq = json['qty_req'];
    unit = json['unit'] ?? '';
    price = json['price'] ?? '';
  }
}
