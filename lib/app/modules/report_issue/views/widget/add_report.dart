import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/controllers/report_issue_controller.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/datatable_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/shared/elevated_button.dart';
import '../../../../data/shared/text_field.dart';

final reportC = Get.put(ReportIssueController());
addReport(
  BuildContext context,
  String? id,
  String? reportTitle,
  String? image1,
  String? image2,
  String? status,
  String? uid,
) {
  reportC.reportTitle.text = reportTitle ?? '';
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;
          Widget beforeImage = _buildImageColumn(
            label: '',
            onTap: () => reportC.pickAndUploadImage(),
            webImage: reportC.webImage,
            // imageUrl: image1!,
            isBefore: true,
          );

          // Widget afterImage = _buildImageColumn(
          //   label: 'AFTER',
          //   onTap: () => reportC.pickAndUploadImage2(),
          //   webImage: reportC.webImage2,
          //   // imageUrl: image2!,
          //   isBefore: false,
          // );
          return Obx(
            () => AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: const Text('Add Report'),
              content: Container(
                width:
                    MediaQuery.of(context).size.width /
                    (isWideScreen ? 2.2 : 1.2),
                height: MediaQuery.of(context).size.height / 1.5,
                decoration: const BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 90,
                                    child: Text('Report ID'),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: CsTextField(
                                      label: '',
                                      enabled: false,
                                      initialValue: reportC.idReport,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 90,
                                    child: Text('Date'),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: CsTextField(
                                      label: '',
                                      enabled: false,
                                      initialValue: reportC.dateNow,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 90,
                                    child: Text('Report'),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 60,
                                    child: CsTextField(
                                      maxLines: 5,
                                      label: 'Report Description',
                                      controller: reportC.reportTitle,
                                      // initialValue: reportC.reportTitle.text,
                                      onChanged: (val) {
                                        reportC.reportTitle.text = val;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 5),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Visibility(
                            visible: isWideScreen ? true : false,
                            child: Row(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisSize: MainAxisSize.max,
                              children: [
                                const SizedBox(
                                  width: 90,
                                  child: Text('Report Image'),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    beforeImage,
                                    const SizedBox(width: 10),
                                    CsElevatedButton(
                                      color: Colors.blue,
                                      fontsize: 14,
                                      label:
                                          reportC.isEdit.value == false
                                              ? 'Add'
                                              : 'Update',
                                      onPressed: () {
                                        if (reportC.webImage != null &&
                                            reportC
                                                .reportTitle
                                                .text
                                                .isNotEmpty) {
                                          reportC.isEdit.value =
                                              uid != null && uid.isNotEmpty;
                                          int index = -1;
                                          if (reportC.isEdit.value) {
                                            index = reportC.tempListReport
                                                .indexWhere(
                                                  (r) => r.uid == uid,
                                                );
                                          }
                                          if (index != -1) {
                                            // Update hanya imageBf pada item yang ada
                                            reportC
                                                .tempListReport[index]
                                                .imageBf = base64Encode(
                                              reportC.webImage!,
                                            );
                                            reportC
                                                    .tempListReport[index]
                                                    .report =
                                                reportC.reportTitle.text;

                                            reportC.webImage = null;
                                            reportC.reportTitle.clear();
                                            reportC.isEdit.value = false;
                                            reportC.update();
                                          } else {
                                            // Jika tidak ada, tambahkan baru
                                            reportC.generateUid();
                                            //generat uid
                                            reportC.tempListReport.add(
                                              Report(
                                                id: reportC.idReport,
                                                cabang: reportC.branchCode,
                                                report:
                                                    reportC.reportTitle.text,
                                                imageBf: base64Encode(
                                                  reportC.webImage!,
                                                ),
                                                status: 'ON PROGRESS',
                                                createdAt:
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch
                                                        .toString(),
                                                uid: reportC.uId,
                                              ),
                                            );
                                            reportC.webImage = null;
                                            reportC.reportTitle.clear();
                                            reportC.update();
                                          }
                                          // Get.back();
                                        } else {
                                          failedDialog(
                                            context,
                                            'ERROR',
                                            'Gambar atau Report tidak boleh kosong.',
                                            isWideScreen,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: isWideScreen ? false : true,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 90,
                              child: Text('Report Image'),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                beforeImage,
                                const SizedBox(height: 5),
                                CsElevatedButton(
                                  color: Colors.blue,
                                  fontsize: 14,
                                  label:
                                      reportC.isEdit.value == false
                                          ? 'Add'
                                          : 'Update',
                                  onPressed: () {
                                    if (reportC.webImage != null &&
                                        reportC.reportTitle.text.isNotEmpty) {
                                      reportC.isEdit.value =
                                          uid != null && uid.isNotEmpty;
                                      int index = -1;
                                      if (reportC.isEdit.value) {
                                        index = reportC.tempListReport
                                            .indexWhere((r) => r.uid == uid);
                                      }
                                      if (index != -1) {
                                        // Update hanya imageBf pada item yang ada
                                        reportC.tempListReport[index].imageBf =
                                            base64Encode(reportC.webImage!);
                                        reportC.tempListReport[index].report =
                                            reportC.reportTitle.text;

                                        reportC.webImage = null;
                                        reportC.reportTitle.clear();
                                        reportC.isEdit.value = false;
                                        reportC.update();
                                      } else {
                                        // Jika tidak ada, tambahkan baru
                                        reportC.generateUid();
                                        //generat uid
                                        reportC.tempListReport.add(
                                          Report(
                                            id: reportC.idReport,
                                            cabang: reportC.branchCode,
                                            report: reportC.reportTitle.text,
                                            imageBf: base64Encode(
                                              reportC.webImage!,
                                            ),
                                            status: 'ON PROGRESS',
                                            createdAt:
                                                DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString(),
                                            uid: reportC.uId,
                                          ),
                                        );
                                        reportC.update();
                                        reportC.webImage = null;
                                        reportC.reportTitle.clear();
                                      }
                                      // Get.back();
                                    } else {
                                      failedDialog(
                                        context,
                                        'ERROR',
                                        'Gambar atau Report tidak boleh kosong.',
                                        isWideScreen,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: DatatableReport(
                          reports: reportC.tempListReport,
                          columns: const [
                            DataColumn2(label: Text('Action'), fixedWidth: 110),
                          ],
                          cells: [DataCell(Container())],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CsElevatedButton(
                  onPressed: () async {
                    // print(reportC.tempListReport.map((e) => e.imageBf).toList());
                    // if (reportC.formKeyReport.currentState!.validate()) {
                    reportC.tempListReport.isNotEmpty
                        ? await reportC.reportSubmit(
                          id != "" ? "update_report" : "add_report",
                          id,
                        )
                        : failedDialog(
                          context,
                          'ERROR',
                          'Report belum ada\nSilahkan tambahkan report terlebih dahulu',
                          isWideScreen,
                        );
                    // } else {
                    //   showToast('Harap isi bagian yang kosong', 'red');
                    // }
                  },
                  color: Colors.blue,
                  fontsize: 12,
                  label: 'Submit',
                ),
                CsElevatedButton(
                  onPressed: () {
                    if (reportC.tempListReport.isNotEmpty) {
                      promptDialog(
                        context,
                        'KONFIRMASI',
                        'Anda yakin ingin membatalkan proses ini?\nSemua data akan terhapus',
                        () {
                          reportC.webImage = null;
                          reportC.webImage2 = null;
                          reportC.tempListReport.clear();
                          Get.back();
                        },
                        isWideScreen,
                      );
                    } else {
                      reportC.webImage = null;
                      reportC.webImage2 = null;
                      reportC.tempListReport.clear();
                      Get.back();
                    }
                  },
                  color: Colors.red,
                  fontsize: 12,
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

// Helper method untuk membuat widget kolom gambar
Widget _buildImageColumn({
  required String label,
  required VoidCallback onTap,
  required Uint8List? webImage,
  // required String imageUrl,
  required bool isBefore,
}) {
  return Column(
    children: [
      Text(label),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: ClipRRect(
          child: GetBuilder<ReportIssueController>(
            builder: (c) {
              final Uint8List? imageData = isBefore ? c.webImage : c.webImage2;
              if (imageData != null) {
                return Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: Image.memory(imageData, fit: BoxFit.contain),
                );
              }
              // else if (imageUrl.isNotEmpty) {
              //   return SizedBox(
              //     height: 140,
              //     width: 140,
              //     child: Image.network(
              //       '${ServiceApi().baseUrl}$imageUrl',
              //       fit: BoxFit.contain,
              //     ),
              //   );
              // }
              else {
                return Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      Text(
                        'Click to upload image',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    ],
  );
}
