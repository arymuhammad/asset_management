class RequestDetailModel {
  late String? id;
  late String? desc;
  late String? namaCabang;
  late String? assetCode;
  late String? assetName;
  late String? image;
  late String? qtyStock;
  late String? qtyReq;
  late String? unit;
  late String? price;
  late String? date;
  late String? createdBy;

  RequestDetailModel({
    this.id,
    this.desc,
    this.namaCabang,
    this.assetCode,
    this.assetName,
    this.image,
    this.qtyStock,
    this.qtyReq,
    this.unit,
    this.price,
    this.date,
    this.createdBy,
  });
  RequestDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['request_id'] ?? '';
    desc = json['desc'] ?? '';
    namaCabang = json['nama_cabang'] ?? '';
    assetCode = json['asset_code'] ?? '';
    assetName = json['asset_name'] ?? '';
    image = json['image'] ?? '';
    qtyStock = json['qty_stock'] ?? json['total'];
    qtyReq = json['qty_req'];
    unit = json['unit'] ?? '';
    price = json['price'] ?? '';
    date = json['date'] ?? '';
    createdBy = json['created_by'] ?? '';
  }
}
