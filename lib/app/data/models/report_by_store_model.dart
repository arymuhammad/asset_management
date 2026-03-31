class ReportByStore {
  late String? kodeCabang;
  late String? namaCabang;
  late String? totalReport;
  late String? totalDone;
  late String? totalFu;
  late String? totalOnPrgs;
  late String? totalResche;
  late String? totalPending;

  ReportByStore({
    this.kodeCabang,
    this.namaCabang,
    this.totalReport,
    this.totalDone,
    this.totalFu,
    this.totalOnPrgs,
    this.totalResche,
    this.totalPending,
  });

  ReportByStore.fromJson(Map<String, dynamic> json) {
    kodeCabang = json['kode_cabang'];
    namaCabang = json['nama_cabang'];
    totalReport = json['total_report'];
    totalDone = json['total_done'];
    totalFu = json['total_fu'];
    totalOnPrgs = json['total_on_prgs'];
    totalResche = json['total_re_sche'];
    totalPending = json['total_pending'];
  }
}
