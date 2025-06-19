class Report {
  late String? id;
  late String? cabang;
  late String? report;
  late String? date;
  late String? imageBf;
  late String? imageAf;
  late String? priority;
  late String? status;
  late String? keterangan;
  late String? progress;
  late String? issue;
  late String? createdAt;
  late String? createdBy;
  late String? uid;

  Report({
    this.id,
    this.cabang,
    this.report,
    this.date,
    this.imageBf,
    this.imageAf,
    this.priority,
    this.status,
    this.keterangan,
    this.progress,
    this.issue,
    this.createdAt,
    this.createdBy,
    this.uid,
  });

  Report.fromJson(Map<String, dynamic> json) {
    id = json['id']??json['report_id']??'';
    cabang = json['cabang']??'';
    report = json['report_desc']??'';
    date = json['date']??'';
    imageBf = json['report_image']??'';
    priority = json['priority'] ?? '';
    status = json['status'] ?? '';
    keterangan = json['keterangan'] ?? '';
    progress = json['progress'] ?? '';
    issue = json['issue'] ?? '';
    createdAt = json['created_at'] ?? '';
    createdBy = json['created_by'] ?? '';
    uid = json['uid'] ?? '';
  }
}
