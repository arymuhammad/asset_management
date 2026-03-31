class SoModel {
  late String? id;
  late String? branchCode;
  late String? branchName;
  late String? desc;
  late String? initQty;
  late String? scannedQty;
  late String? diffQty;
  late String? stat;
  late String? createdAt;
  late String? createdBy;

  SoModel({
    this.id,
    this.branchCode,
    this.branchName,
    this.desc,
    this.initQty,
    this.scannedQty,
    this.diffQty,
    this.stat,
    this.createdAt,
    this.createdBy,
  });

  SoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchCode = json['branch_code'];
    branchName = json['nama_cabang'];
    desc = json['desc'];
    initQty = json['total_init_qty'];
    scannedQty = json['scanned_qty'];
    diffQty = json['diff_qty'];
    stat = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
  }
}
