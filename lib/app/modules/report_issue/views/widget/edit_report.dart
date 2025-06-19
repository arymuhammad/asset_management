import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/shared/elevated_button.dart';
import 'datatable_report.dart';
import 'add_report.dart';

Future<dynamic> editReport(
  BuildContext context,
  String id,
  String? penerima,
  String? priority,
  String? progress,
  String? status,
  String? issue,
  String? keterangan,
  String? report,
  String? uid,
) {
  reportC.priorSelected.value = priority ?? '';
  reportC.progress.text = progress ?? '';
  reportC.statusSelected.value = status ?? '';
  reportC.issue.text = issue ?? '';
  reportC.reportTitle.text = report ?? '';
  reportC.keterangan.text = keterangan ?? '';

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;
          return Obx(
            () => AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Text('Edit Report Store $penerima'),
              content: SizedBox(
                width:
                    MediaQuery.of(context).size.width /
                    (isWideScreen ? 2.2 : 1.2),
                height: MediaQuery.of(context).size.height / 1.5,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isWideScreen) // Layout untuk layar lebar
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFormColumn(
                                    context,
                                    id,
                                    isWideScreen,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildReportColumn(isWideScreen),
                                ),
                              ],
                            ),
                          ],
                        )
                      else // Layout untuk layar kecil
                        _buildFormColumn(context, id, isWideScreen),
                      const SizedBox(height: 10),
                      if (!isWideScreen) _buildReportColumn(isWideScreen),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CsElevatedButton(
                            color: Colors.blue,
                            fontsize: 14,
                            onPressed:
                                reportC.isUpdate.value
                                    ? () {
                                      // reportC.updateReport(id); //update report

                                      final isEdit =
                                          uid != null && uid.isNotEmpty;
                                      int index = -1;
                                      if (isEdit) {
                                        index = reportC.detailDataReport
                                            .indexWhere((r) => r.uid == uid);
                                      }
                                      if (index != -1) {
                                        // Update hanya imageBf pada item yang ada
                                        reportC
                                                .detailDataReport[index]
                                                .priority =
                                            reportC.priorSelected.isNotEmpty
                                                ? reportC.priorSelected.value
                                                : priority;
                                        reportC
                                                .detailDataReport[index]
                                                .progress =
                                            reportC.progress.text.isNotEmpty
                                                ? reportC.progress.text
                                                : progress;
                                        reportC.detailDataReport[index].status =
                                            reportC.statusSelected.isNotEmpty
                                                ? reportC.statusSelected.value
                                                : status;
                                        reportC.detailDataReport[index].issue =
                                            reportC.issue.text.isNotEmpty
                                                ? reportC.issue.text
                                                : issue;
                                        reportC.detailDataReport[index].report =
                                            reportC.reportTitle.text.isNotEmpty
                                                ? reportC.reportTitle.text
                                                : report;
                                        reportC.detailDataReport[index].keterangan =
                                            reportC.keterangan.text.isNotEmpty
                                                ? reportC.keterangan.text
                                                : keterangan;
                                        reportC.isUpdate.value = false;
                                        reportC.priorSelected.value = '';
                                        reportC.progress.clear();
                                        reportC.statusSelected.value = '';
                                        reportC.issue.clear();
                                        reportC.reportTitle.clear();
                                        reportC.keterangan.clear();
                                        reportC.update();
                                      }
                                    }
                                    : null,
                            label: 'Update',
                          ),
                          const SizedBox(width: 5),
                          CsElevatedButton(
                            color: red!,
                            fontsize: 14,
                            label: 'Cancel',
                            onPressed:
                                reportC.isUpdate.value
                                    ? () {
                                      reportC.isUpdate.value = false;
                                      reportC.priorSelected.value = '';
                                      reportC.progress.clear();
                                      reportC.statusSelected.value = '';
                                      reportC.issue.clear();
                                      reportC.reportTitle.clear();
                                      reportC.keterangan.clear();
                                      reportC.update();
                                    }
                                    : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: DatatableReport(
                          reports: reportC.detailDataReport,
                          dataCell: const Icon(Icons.do_disturb),
                          cabang: penerima,

                          // columns: const [
                          //   DataColumn2(label: Text('Priority')),
                          //   DataColumn2(label: Text('Progress')),
                          //   DataColumn2(label: Text('Status')),
                          //   DataColumn2(label: Text('Issue')),
                          // ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              actions: [
                CsElevatedButton(
                  fontsize: 14,
                  color: Colors.blue,
                  onPressed: () {
                    reportC.updateReport(id, isWideScreen); //update report
                    // Get.back();
                  },
                  label: 'Simpan',
                ),
                CsElevatedButton(
                  fontsize: 14,
                  color: Colors.red,
                  onPressed: () {
                    promptDialog(
                      context,
                      'KONFIRMASI',
                      'Anda yakin ingin membatalkan perubahan data?\nSemua data yang telah diubah tidak akan tersimpan',
                      () {
                        reportC.isUpdate.value = false;
                        Get.back();
                      },
                      isWideScreen,
                    );
                  },
                  label: 'Cancel',
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildFormColumn(BuildContext context, String id, bool isWideScreen) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Report ID',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(' : $id', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      Row(
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Priority',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 200,
            height: 30,
            child: Obx(
              () => CsDropDown(
                label: 'Select Priority',
                value:
                    reportC.priorSelected.isNotEmpty
                        ? reportC.priorSelected.value
                        : null,
                items:
                    reportC.listPriority
                        .map(
                          (data) =>
                              DropdownMenuItem(value: data, child: Text(data)),
                        )
                        .toList(),
                onChanged: (val) {
                  reportC.priorSelected.value = val ?? '';
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Progress',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 200,
            height: 30,
            child: CsTextField(
              controller: reportC.progress,
              // initialValue: reportC.progress.value,
              label: 'Progress',
              maxLines: 1,
              // onChanged: (val) {
              //   reportC.progress.text = val;
              // },
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 200,
            height: 30,
            child: Obx(
              () => CsDropDown(
                label: 'Select Status',
                value:
                    reportC.statusSelected.isNotEmpty
                        ? reportC.statusSelected.value
                        : null,
                items:
                    reportC.listStatus
                        .map(
                          (data) =>
                              DropdownMenuItem(value: data, child: Text(data)),
                        )
                        .toList(),
                onChanged: (val) {
                  reportC.statusSelected.value = val ?? '';
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Keterangan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 200,
            height: 30,
            child: CsTextField(
              controller: reportC.keterangan,
              label: 'Keterangan',
              maxLines: 2,
              onChanged: (val) {
                reportC.keterangan.text = val;
              },
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildReportColumn(bool isWideScreen) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 90,
            child: Text(
              'Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 200,
            child: CsTextField(
              controller: reportC.reportTitle,
              label: 'Report',
              // initialValue: reportC.reportTitle.text,
              maxLines: 3,
              // onChanged: (val) {
              //   reportC.reportTitle.text = val;
              // },
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 90,
            child: Text('Issue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 200,
            child: CsTextField(
              controller: reportC.issue,
              label: 'Issue',
              // initialValue: reportC.issue.value,
              maxLines: 2,
              // onChanged: (val) {
              //   reportC.issue.text = val;
              // },
            ),
          ),
        ],
      ),
    ],
  );
}
