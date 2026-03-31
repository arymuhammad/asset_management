import 'package:get/get.dart';

class SoDetailModel {
  late String? id;
  late String? branchCode;
  late String? assetCode;
  late String? assetName;
  RxString initStock;
  RxString qtyNew;
  RxString qtySec;
  RxString qtyBad;
  RxString diffQty;
  late String? stat;
  late String? createdAt;
  late String? createdBy;

  SoDetailModel({
    this.id,
    this.branchCode,
    this.assetCode,
    this.assetName,
    String? initStock,
    String? qtyNew,
    String? qtySec,
    String? qtyBad,
    String? diffQty,
    this.stat,
    this.createdAt,
    this.createdBy,
  }) : initStock = (initStock ?? '').obs,
       qtyNew = (qtyNew ?? '').obs,
       qtySec = (qtySec ?? '').obs,
       qtyBad = (qtyBad ?? '').obs,
       diffQty = (diffQty ?? '').obs;

  SoDetailModel.fromJson(Map<String, dynamic> json)
    : id = (json['id'] ?? '').toString(),
      branchCode = (json['branch_code'] ?? '').toString(),
      assetCode = (json['asset_code'] ?? '').toString(),
      assetName = (json['asset_name'] ?? '').toString(),
      initStock = (json['qty_init'] ?? '').toString().obs,
      qtyNew = (json['qty_new'] ?? '').toString().obs,
      qtySec = (json['qty_sec'] ?? '').toString().obs,
      qtyBad = (json['qty_bad'] ?? '').toString().obs,
      diffQty = (json['difference'] ?? '').toString().obs,
      stat = (json['status'] ?? '').toString(),
      createdAt = (json['created_at'] ?? '').toString(),
      createdBy = (json['created_by'] ?? '').toString();
}
