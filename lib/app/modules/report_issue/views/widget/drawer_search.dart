import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/report_issue/controllers/report_issue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/models/login_model.dart';

class DrawerSearch extends StatelessWidget {
  DrawerSearch({
    super.key,
    this.userData,
    required this.branch,
    required this.isHO,
  });
  final reportC = Get.find<ReportIssueController>();
  final Data? userData;
  final String branch;
  final bool isHO;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search data report', style: titleTextStyle),
            const Divider(),
            CsTextField(
              // readOnly: false,
              controller: reportC.searchController,
              label: 'Search Data',
              onChanged: (val) {
                reportC.filterDataReport(val);
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                reportC.dataSource.notifyListeners();
              },
            ),
            const SizedBox(height: 10),
            Text('Select status report', style: titleTextStyle),
            const Divider(),
            SizedBox(
              width: 300, // lebar container lebih luas
              height: 100, // tinggi agar grid tidak infinite
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 kolom
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3, // nisbah lebar:tinggi button
                ),
                itemCount: reportC.listStatus.length,
                itemBuilder: (context, index) {
                  var stats = reportC.listStatus[index];
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(5),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.itemsBackground,
                      ),
                      onPressed: () {
                        Get.back();
                        loadingDialog('Refresh data', '');
                        Future.delayed(const Duration(seconds: 1), () {
                          reportC.searchController.clear();
                          reportC.filterDataReport('');
                          reportC.getReportBySts(
                            stats == "PENDING" ? '' : stats,
                            isHO ? branch : userData!.kodeCabang!,
                          );
                          Get.back();
                        });
                      },
                      child: Text(
                        stats == "" ? 'PENDING' : stats,
                        style: const TextStyle(
                          color: AppColors.contentColorWhite,
                        ),
                      ),
                    ),
                  );
                },
                shrinkWrap: true, // membuat grid sesuai isi
                physics:
                    const NeverScrollableScrollPhysics(), // agar tidak scroll sendiri
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CsElevatedButton(
                color: AppColors.itemsBackground,
                fontsize: 14,
                label: 'Reset',
                onPressed: () async {
                  Get.back();
                  loadingDialog('Refresh data', '');
                  Future.delayed(const Duration(seconds: 1), () async {
                    reportC.searchController.clear();
                    reportC.statusSelected.value = "";
                    reportC.filterDataReport('');
                    await reportC.getReport(userData!.kodeCabang);
                    Get.back();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
