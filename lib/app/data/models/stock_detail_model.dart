class StockDetail {
  late String? id;
  late String? kodePengirim;
  late String? pengirim;
  late String? kodePenerima;
  late String? penerima;
  late String? cabang;
  late String? type;
  late String? assetCode;
  late String? assetName;
  late String? qtyIn;
  late String? qty;
  late String? createdAt;

  StockDetail({
    this.id,
    this.kodePengirim,
    this.pengirim,
    this.kodePenerima,
    this.penerima,
    this.cabang,
    this.type,
    this.assetCode,
    this.assetName,
    this.qtyIn,
    this.qty,
    this.createdAt,
  });

  StockDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kodePengirim = json['from'];
    pengirim = json['pengirim'];
    kodePenerima = json['to'];
    penerima = json['penerima'];
    cabang = json['pengirim'] ?? json['penerima'];
    assetCode = json['asset_code'];
    assetName = json['asset_name'];
    qtyIn = json['qty_in'];
    qty = json['qty_in'] ?? json['qty_out'];
    createdAt = json['created_at'];
  }
}
