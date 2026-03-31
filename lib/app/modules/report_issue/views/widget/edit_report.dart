import 'dart:convert';

import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/shared/elevated_button.dart';
import '../../controllers/report_issue_controller.dart';
import 'datatable_report.dart';
import 'add_report.dart';

Future<dynamic> editReport(
  BuildContext context,
  String id,
  String? kodeCabang,
  String? penerima,
  // String? imageAf,
  String? priority,
  String? progress,
  String? status,
  String? issue,
  String? keterangan,
  String? report,
  String? uid,
  String? createdBy,
  Data? dataUser,
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
                    (isWideScreen ? 1.5 : 1.2),
                height: MediaQuery.of(context).size.height / 1,
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
                                    createdBy!,
                                  ),
                                ),
                                const SizedBox(width: 60),
                                Expanded(
                                  child: _buildReportColumn(
                                    isWideScreen,
                                    createdBy,
                                    status!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else // Layout untuk layar kecil
                        _buildFormColumn(context, id, isWideScreen, createdBy!),
                      // const SizedBox(height: 5),
                      if (!isWideScreen)
                        _buildReportColumn(isWideScreen, createdBy, status!),
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
                                        if (reportC.webImage2 != null) {
                                          reportC
                                              .detailDataReport[index]
                                              .imageAf = base64Encode(
                                            reportC.webImage2!,
                                          );
                                        }
                                        // Update hanya imageBf pada item yang ada
                                        reportC
                                            .detailDataReport[index]
                                            .priority =
                                            // reportC.priorSelected.isNotEmpty
                                            // ?
                                            reportC.priorSelected.value;
                                        // : priority;
                                        reportC
                                                .detailDataReport[index]
                                                .progress =
                                            reportC.progress.text.isNotEmpty
                                                ? reportC.progress.text
                                                : progress;
                                        reportC.detailDataReport[index].status =
                                            // reportC.statusSelected.isNotEmpty
                                            // ?
                                            reportC.statusSelected.value;
                                        // : status;
                                        reportC.detailDataReport[index].issue =
                                            // reportC.issue.text.isNotEmpty
                                            // ?
                                            reportC.issue.text;
                                        // : issue;
                                        reportC.detailDataReport[index].report =
                                            // reportC.reportTitle.text.isNotEmpty
                                            // ?
                                            reportC.reportTitle.text;
                                        // : report;
                                        reportC
                                                .detailDataReport[index]
                                                .keterangan =
                                            reportC.keterangan.text.isNotEmpty
                                                ? reportC.keterangan.text
                                                : keterangan;
                                        // reportC.webImage2 = null;
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
                            color: red,
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
                        height: 250,
                        child: DatatableReport(
                          reports: reportC.detailDataReport,
                          dataCell: const Icon(Icons.do_disturb),
                          cabang: penerima,
                          dataUser: dataUser,
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
                  color: red!,
                  onPressed: () {
                    promptDialog(
                      context,
                      'Warning',
                      'Anda yakin ingin menghapus semua data report ini?\n Semua data akang hilang  dan tidak dapat dikembalikan',
                      () => reportC.deleteReport(id, isWideScreen, penerima!),
                      isWideScreen,
                    );

                    // Get.back();
                  },
                  label: 'Hapus semua data',
                ),
                CsElevatedButton(
                  fontsize: 14,
                  color: Colors.blue,
                  onPressed: () {
                    reportC.updateReport(
                      isWideScreen,
                     kodeCabang!,
                    ); //update report
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
                        reportC.webImage2Map.clear();
                        reportC.webImage2 = null;
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

Widget _buildFormColumn(
  BuildContext context,
  String id,
  bool isWideScreen,
  String createdBy,
) {
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
      const SizedBox(height: 10),
      Row(
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
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
                onChanged:
                    reportC.isUpdate.value
                        ? (val) {
                          reportC.priorSelected.value = val ?? '';
                        }
                        : null,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            height: 30,
            child: CsTextField(
              enabled: reportC.isUpdate.value ? true : false,
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
      const SizedBox(height: 10),
      Row(
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
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
                onChanged:
                    reportC.isUpdate.value
                        ? (val) {
                          reportC.statusSelected.value = val ?? '';
                        }
                        : null,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Note',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: CsTextField(
              enabled: reportC.isUpdate.value ? true : false,
              controller: reportC.keterangan,
              label: 'Note',
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

Widget _buildReportColumn(bool isWideScreen, String createdBy, String status) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 95,
                  child: Text(
                    'Report',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: CsTextField(
              enabled: reportC.isUpdate.value ? true : false,
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
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isWideScreen ? true : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 95,
                  child: Text(
                    'Issue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: CsTextField(
              enabled: reportC.isUpdate.value ? true : false,
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
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible:
                status == "DONE" && reportC.isUpdate.value == true
                    ? true
                    : false,
            child: const Row(
              children: [
                SizedBox(
                  width: 95,
                  child: Text(
                    'Image After',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          Visibility(
            visible:
                status == "DONE" && reportC.isUpdate.value == true
                    ? true
                    : false,
            child: InkWell(
              onTap: () async {
                await reportC.pickAndUploadImageAfter();
                print('imageweb 2 ${reportC.webImage2 != null}');
              },
              child: ClipRRect(
                child: GetBuilder<ReportIssueController>(
                  builder: (c) {
                    final imageBytes = c.webImage2;
                    print('imageweb 2 ${reportC.webImage2 != null}');
                    if (imageBytes != null) {
                      // report.imageAf = base64Encode(imageBytes);
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        child: Image.memory(imageBytes, fit: BoxFit.contain),
                      );
                      // } else if (report.imageAf!.isNotEmpty) {
                      //   return SizedBox(
                      //     height: 50,
                      //     width: 50,
                      //     child: Image.network(
                      //       '${ServiceApi().baseUrl}${report.imageAf!}',
                      //       fit: BoxFit.contain,
                      //     ),
                      //   );
                    } else {
                      return Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt),
                            // Text(
                            //   '',
                            //   textAlign: TextAlign.center,
                            // ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 95,
            child: Text(
              'Created By',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 200,
            child: Text(
              createdBy
                  .split(',')
                  .map((e) => e.trim())
                  .toSet()
                  .toList()
                  .reversed
                  .join(',\n')
                  .capitalize!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ],
  );
}
