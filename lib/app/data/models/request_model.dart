class RequestModel {
  late String? id;
  late String? group;
  late String? branchCode;
  late String? branch;
  late String? category;
  late String? categoryName;
  late String? desc;
  late String? date;
  late String? createdBy;

  RequestModel({
    this.id,
    this.group,
    this.branchCode,
    this.branch,
    this.category,
    this.categoryName,
    this.desc,
    this.date,
    this.createdBy,
  });
  RequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    group = json['group'] ?? '';
    branchCode = json['branch'] ?? '';
    branch = json['nama_cabang'] ?? '';
    category = json['category'] ?? '';
    categoryName = json['category_name'] ?? '';
    desc = json['desc'] ?? '';
    date = json['date'] ?? '';
    createdBy = json['created_by'] ?? '';
  }
}
