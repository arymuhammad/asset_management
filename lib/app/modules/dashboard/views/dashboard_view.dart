import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/models/report_by_store_model.dart';
import 'package:assets_management/app/modules/report_issue/controllers/report_issue_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/login_model.dart';
import '../../../data/models/summreportstat_model.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key, this.userData});
  final Data? userData;
  final dashC = Get.find<DashboardController>();
  final rptC = Get.put(ReportIssueController());

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'PENDING',
      'FOLLOW UP',
      'ON PROGRESS',
      'DONE',
      'RE SCHEDULE',
    ];

    final List<Map<String, dynamic>> icons = [
      {"icons": Icons.pending, "color": AppColors.contentColorYellow},
      {"icons": Icons.support_agent, "color": AppColors.contentColorBlue},
      {
        "icons": Icons.swap_vert_circle_rounded,
        "color": AppColors.contentColorPurple,
      },
      {
        "icons": Icons.check_circle_outlined,
        "color": AppColors.contentColorGreen,
      },
      {
        "icons": Icons.assignment_outlined,
        "color": AppColors.contentColorWhite,
      },
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        double maxCrossAxisExtent = 200; // maksimal lebar tiap item grid
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Summary Report Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    // childAspectRatio: 2, // lebar:tinggi (bisa disesuaikan)
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    return InkWell(
                      onTap: () {
                        loadingDialog('Memuat data', '');
                        Future.delayed(const Duration(seconds: 1), () async {
                          dashC.changePage(
                            [
                                  "19",
                                  "20",
                                  "21",
                                  "22",
                                  "24",
                                  "26",
                                  "35",
                                  "59",
                                  "78",
                                ].contains(userData?.level)
                                ? 4
                                : 7,
                          );
                          var s = "";
                          if (category == "FOLLOW UP") {
                            s = "FU";
                          } else if (category == "ON PROGRESS") {
                            s = "ON PRGS";
                          } else if (category == "DONE") {
                            s = "DONE";
                          } else if (category == "RE SCHEDULE") {
                            s = "RE SCHE";
                          } else {
                            s = "";
                          }
                          rptC.statusSelected.value = s;
                          await rptC.getReportBySts(
                            s,
                            userData!.kodeCabang != "HO000"
                                ? userData!.kodeCabang!
                                : '',
                          );
                          rptC.showDetail(
                            ReportByStore(
                              kodeCabang: '',
                              namaCabang: '',
                              totalDone: '',
                              totalFu: '',
                              totalOnPrgs: '',
                              totalPending: '',
                              totalReport: '',
                              totalResche: '',
                            ),
                          );
                          Get.back();
                        });
                      },
                      child: Card(
                        elevation: 8,
                        color: AppColors.contentColorWhite,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<SummReportStat>(
                                stream: dashC.getSummReportStat({
                                  "type": "summ_report_status",
                                  "div": userData!.levelUser!.split(' ')[0],
                                  "branch": userData!.kodeCabang,
                                  "level_id": userData!.level,
                                  "user_id": userData!.id,
                                }),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  }
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CupertinoActivityIndicator(),
                                    );
                                  }
                                  final datas = snapshot.data!;

                                  final List<Map<String, String>> items = [
                                    {'total': datas.pending},
                                    {'total': datas.fu},
                                    {'total': datas.onprgs},
                                    {'total': datas.done},
                                    {'total': datas.resch},
                                  ];

                                  return Column(
                                    children: [
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: AppColors.itemsBackground,
                                          // color: icons[index]['color']
                                        ),
                                        child: Icon(
                                          icons[index]['icons'],
                                          color: icons[index]['color'],
                                        ),
                                      ),
                                      Text(
                                        items[index]['total']!,
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w600,
                                          // color: Colors.blue[900],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Positioned.fill(
                                bottom: 0,
                                top: isWideScreen ? 130 : 100,
                                left: 0,
                                right: 0,
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    // color: Colors.blue[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
