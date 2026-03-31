class AdjModel {
  late String? id;
  late String? branchCode;
  late String? branchName;
  late String? desc;
  late String? qty;
  late String? stat;
  late String? date;
  late String? createdBy;

  AdjModel({
    this.id,
    this.branchCode,
    this.branchName,
    this.desc,
    this.qty,
    this.stat,
    this.date,
    this.createdBy,
  });

  AdjModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    branchCode = json['branch_code'];
    branchName = json['branch_name'];
    desc = json['desc'];
    qty = json['qty_amount'];
    stat = json['status'];
    date = json['date'];
    createdBy = json['created_by'];
  }
}
