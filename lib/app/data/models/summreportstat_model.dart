class SummReportStat {
  final String pending;
  final String fu;
  final String onprgs;
  final String done;
  final String resch;

  SummReportStat({
    required this.pending,
    required this.fu,
    required this.onprgs,
    required this.done,
    required this.resch,
  });

  factory SummReportStat.fromJson(Map<String, dynamic> json) {
   return SummReportStat(
      pending: json['pending'],
      fu: json['fu'],
      onprgs: json['onprgs'],
      done: json['done'],
      resch: json['resch'],
    );
  }
}
