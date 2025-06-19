class RequestModel {
  late String? id;
  late String? branch;
  late String? desc;
  late String? date;
  late String? createdBy;


  RequestModel({
    this.id,
    this.branch,
    this.desc,
    this.date,
    this.createdBy,
  });
  RequestModel.fromJson(Map<String, dynamic> json) {
    id = json['request_id'] ?? '';
    branch = json['cabang'] ?? '';
    desc = json['desc'] ?? '';
    date = json['date'] ?? '';
    createdBy = json['created_by'] ?? '';
  }
}