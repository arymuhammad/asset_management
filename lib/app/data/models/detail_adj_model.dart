import 'package:get/get.dart';

class DetailAdjModel {
  late String? id;
  late String? assetCode;
  late String? assetName;
  RxString qtyNew;
  RxString qtySec;
  RxString qtyBad;
  RxString qtyAdj;
  late String? stat;
  late String? createdAt;
  late String? createdBy;

  DetailAdjModel({
    this.id,
    this.assetCode,
    this.assetName,
    String? qtyNew,
    String? qtySec,
    String? qtyBad,
    String? qtyAdj,
    this.stat,
    this.createdAt,
    this.createdBy,
  }) : qtyNew = (qtyNew ?? '').obs,
       qtySec = (qtySec ?? '').obs,
       qtyBad = (qtyBad ?? '').obs,
       qtyAdj = (qtyAdj ?? '').obs;

  DetailAdjModel.fromJson(Map<String, dynamic> json)
    : id = (json['id'] ?? '').toString(),
      assetCode = (json['asset_code'] ?? '').toString(),
      assetName = (json['asset_name'] ?? '').toString(),
      qtyNew = (json['qty_new'] ?? '').toString().obs,
      qtySec = (json['qty_sec'] ?? '').toString().obs,
      qtyBad = (json['qty_bad'] ?? '').toString().obs,
      qtyAdj = (json['qty_adj_in'] ?? json['qty_adj_out']).toString().obs,
      stat = (json['status'] ?? '').toString(),
      createdAt = (json['created_at'] ?? '').toString(),
      createdBy = (json['created_by'] ?? '').toString();
}
