class Stok {
  late String? barcode;
  late String? assetName;
  late String? assetImg;
  late String? category;
  late String? group;
  late String? kodeCabang;
  late String? namaCabang;
  late String? stokIn;
  late String? adjIn;
  late String? stokOut;
  late String? adjOut;
  late String? total;
  late String? neww;
  late String? sec;
  late String? bad;
  late String? createdBy;

  Stok({
    this.barcode,
    this.assetName,
    this.assetImg,
    this.category,
    this.group,
    this.kodeCabang,
    this.namaCabang,
    this.stokIn,
    this.adjIn,
    this.stokOut,
    this.adjOut,
    this.total,
    this.neww,
    this.sec,
    this.bad,
    this.createdBy,
  });

  Stok.fromJson(Map<String, dynamic> json) {
    barcode = json['barcode'];
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    assetName = json['asset_name'];
    assetImg = json['image'];
    group = json['group'];
    category = json['category_name'] ?? '';
    stokIn = json['in'] ?? '0';
    adjIn = json['adj_in'] ?? '0';
    stokOut = json['out'] ?? '0';
    adjOut = json['adj_out'] ?? '0';
    total = json['total'] ?? '0';
    neww = json['new_stat'] ?? '0';
    sec = json['sec_stat'] ?? '0';
    bad = json['bad_stat'] ?? '0';
    createdBy = json['created_by'];
  }
}
