class RequestModel {
  late String? id;
  late String? branchCode;
  late String? branch;
  late String? category;
  late String? categoryName;
  late String? desc;
  late String? date;
  late String? createdBy;


  RequestModel({
    this.id,
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
    branchCode = json['branch'] ?? '';
    branch = json['nama_cabang'] ?? '';
    category = json['category'] ?? '';
    categoryName = json['category_name'] ?? '';
    desc = json['desc'] ?? '';
    date = json['date'] ?? '';
    createdBy = json['created_by'] ?? '';
  }
}