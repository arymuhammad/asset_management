class BarangKeluarMasuk {
  late String? id;
  late String? kodePengirim;
  late String? pengirim;
  late String? kodePenerima;
  late String? penerima;
  late String? to;
  late String? desc;
  late String? qtyAmount;
  late String? status;
  late String? createdBy;
  late String? createdAt;

  BarangKeluarMasuk(
      {this.id,
      this.kodePengirim,
      this.pengirim,
      this.penerima,
      this.kodePenerima,
      this.to,
      this.desc,
      this.qtyAmount,
      this.status,
      this.createdBy,
      this.createdAt,
      });
  BarangKeluarMasuk.fromJson(Map<String, dynamic> json) {
    id = json['id']??'';
    kodePengirim = json['from']??'';
    pengirim = json['pengirim']??'';
    kodePenerima = json['to']??'';
    penerima = json['penerima']??'';
    to = json['to']??'';
    desc = json['desc']??'';
    qtyAmount = json['qty_amount']??'';
    status = json['status']??'';
    createdBy = json['created_by']??'';
    createdAt = json['created_at']??'';
  }
}
