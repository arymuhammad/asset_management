import 'package:get/get.dart';

class DetailBarangMasukKeluar {
  late String? idStokIn;
  late String? assetCode;
  late String? assetName;
  late String? group;
  late String? soh;
  late String qtyTotal;
  RxString qtyIn;
  RxString qtyOut;
  RxString neww;
  RxString sec;
  RxString bad;
  late String? status;
  late String? createdAt;

  DetailBarangMasukKeluar({
    this.idStokIn,
    this.assetCode,
    this.assetName,
    this.group,
    this.soh,
    required this.qtyTotal,
    String? qtyIn,
    String? qtyOut,
    String? neww,
    String? sec,
    String? bad,
    this.status,
    this.createdAt,
  }) : qtyIn = (qtyIn ?? '').obs,
       qtyOut = (qtyOut ?? '').obs,
       neww = (neww ?? '').obs,
       sec = (sec ?? '').obs,
       bad = (bad ?? '').obs;

  DetailBarangMasukKeluar.fromJson(Map<String, dynamic> json)
    : idStokIn = (json['id_stok_in'] ?? '').toString(),
      assetCode = (json['asset_code'] ?? '').toString(),
      assetName = (json['asset_name'] ?? '').toString(),
      group = (json['group'] ?? '').toString(),
      soh = (json['soh'] ?? '').toString(),
      qtyTotal = (json['qty_total'] ?? '').toString(),
      qtyIn = (json['qty_in'] ?? '').toString().obs,
      qtyOut = (json['qty_out'] ?? '').toString().obs,
      neww = (json['qty_new'] ?? '').toString().obs,
      sec = (json['qty_sec'] ?? '').toString().obs,
      bad = (json['qty_bad'] ?? '').toString().obs,
      status = (json['status'] ?? '').toString(),
      createdAt = (json['created_at'] ?? '').toString();
}
