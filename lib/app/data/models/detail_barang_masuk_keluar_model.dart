class DetailBarangMasukKeluar {
  late String? idStokIn;
  late String? assetCode;
  late String? assetName;
  late String? group;
  late String? qtyTotal;
  late String? qtyIn;
  late String? qtyOut;
  late String? good;
  late String? bad;
  late String? status;

  DetailBarangMasukKeluar(
      {this.idStokIn,
      this.assetCode,
      this.assetName,
      this.group,
      this.qtyTotal,
      this.qtyIn,
      this.qtyOut,
      this.good,
      this.bad,
      this.status,
      });

  DetailBarangMasukKeluar.fromJson(Map<String, dynamic> json) {
    idStokIn = json['id_stok_in'];
    assetCode = json['asset_code'];
    assetName = json['asset_name'];
    group = json['group'];
    qtyTotal = json['total'];
    qtyIn = json['qty_in'];
    qtyOut = json['qty_out'];
    good = json['qty_good'];
    bad = json['qty_bad'];
    status = json['status'];
  }
}
