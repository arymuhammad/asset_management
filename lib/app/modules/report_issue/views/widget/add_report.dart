import 'dart:convert';
import 'dart:typed_data';

import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/modules/report_issue/controllers/report_issue_controller.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/datatable_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/Repo/service_api.dart';
import '../../../../data/shared/elevated_button.dart';
import '../../../../data/shared/text_field.dart';

final reportC = Get.put(ReportIssueController());
addReport(
  BuildContext context,
  String? id,
  String? div,
  String? reportTitle,
  String? image1,
  String? image2,
  String? status,
  String? uid,
  String? date,
  Data? dataUser,
) {
  reportC.idReport.text = id ?? '';
  reportC.selectedReportDiv.value = div ?? '';
  reportC.reportTitle.text = reportTitle ?? '';
  reportC.dateNow.text = date ?? '';
  reportC.tempListReport.value = reportC.detailDataReport;

  // print(reportTitle!.isEmpty);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      // print(reportTitle!.isEmpty);
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;
          Widget beforeImage = _buildImageColumn(
            // label: '',
            onTap: () async {
              if (reportTitle!.isEmpty) {
                await reportC.pickAndUploadImage();
              } else {
                await reportC.pickAndUploadImageAfter();
              }
            },
            webImage: reportC.webImage ?? reportC.webImage2,
            // imageUrl: image1!,
            isBefore: reportTitle == "" ? true : false,
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
              title: Text('${reportTitle == "" ? 'Add' : 'Edit'} Report'),
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
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
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
                                      controller: reportC.idReport,
                                      enabled: false,
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
                                      controller: reportC.dateNow,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Visibility(
                                visible: reportTitle != "",
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 90,
                                      child: Text('Status'),
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
                                                    (data) => DropdownMenuItem(
                                                      value: data,
                                                      child: Text(data),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) {
                                            reportC.statusSelected.value =
                                                val ?? '';
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: reportTitle == "",
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 90,
                                          child: Text('Division'),
                                        ),
                                        SizedBox(
                                          width: 200,
                                          height: 30,
                                          child: CsDropDown(
                                            label: 'Choose One',
                                            value:
                                                reportC
                                                        .selectedReportDiv
                                                        .isNotEmpty
                                                    ? reportC
                                                        .selectedReportDiv
                                                        .value
                                                    : null,
                                            items:
                                                reportC.reportDiv
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(e),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (val) {
                                              reportC.selectedReportDiv.value =
                                                  val;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                              reportTitle == ""
                                  ? Column(
                                    children: [
                                      // const SizedBox(height: 5),
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
                                    ],
                                  )
                                  : Container(height: isWideScreen ? 30 : 0),

                              // const SizedBox(height: 5),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Visibility(
                            visible: isWideScreen ? true : false,
                            child: Visibility(
                              visible:
                                  reportC.statusSelected.value == "DONE" ||
                                  reportTitle == "",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisSize: MainAxisSize.max,
                                children: [
                                  const SizedBox(
                                    width: 120,
                                    child: Text('Report Image'),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      beforeImage,
                                      const SizedBox(height: 5),
                                      CsElevatedButton(
                                        color: Colors.blue,
                                        fontsize: 14,
                                        label:
                                            // reportC.isEdit.value == false
                                            // ?
                                            'Add',
                                        // : 'Update'
                                        onPressed:
                                        // reportC.isUpdate.value == false
                                        //     ? null
                                        // :
                                        () async {
                                          final Uint8List? imgPick;
                                          if (reportTitle!.isEmpty) {
                                            imgPick = reportC.webImage;
                                          } else {
                                            imgPick = reportC.webImage2;
                                          }
                                          if (imgPick != null &&
                                              reportC
                                                  .reportTitle
                                                  .text
                                                  .isNotEmpty &&
                                              reportC
                                                  .selectedReportDiv
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
                                              final oldReport =
                                                  reportC.detailDataReport;
                                              if (oldReport[index].imageBf!
                                                  .contains('reports/')) {
                                                final imageUrl =
                                                    '${ServiceApi().baseUrl}${oldReport[index].imageBf!}';
                                                //print(oldReport);
                                                await reportC.downloadImageBf(
                                                  imageUrl,
                                                );
                                              } else {
                                                reportC.webImage =
                                                    Uint8List.fromList(
                                                      base64Decode(
                                                        oldReport[index]
                                                            .imageBf!,
                                                      ),
                                                    );
                                              }
                                              // Update hanya imageBf pada item yang ada
                                              reportC
                                                  .tempListReport[index]
                                                  .imageAf = base64Encode(
                                                reportC.webImage2!,
                                              );

                                              reportC
                                                      .tempListReport[index]
                                                      .report =
                                                  reportC.reportTitle.text;
                                              reportC
                                                      .tempListReport[index]
                                                      .status =
                                                  reportC.statusSelected.value;

                                              Get.back();
                                              // Tutup dialog sebelumnya jika ada
                                              Future.delayed(
                                                const Duration(seconds: 1),
                                              );
                                              addReport(
                                                context,
                                                id,
                                                div,
                                                reportTitle,
                                                oldReport[index].imageBf!,
                                                '', // image2 jika ada
                                                status,
                                                uid,
                                                date,
                                                dataUser,
                                              );

                                              reportC.isEdit.value = true;

                                              // reportC.webImage = null;
                                              reportC.webImage2 = null;
                                              reportC.reportTitle.clear();
                                              reportC.isEdit.value = false;
                                              reportC.update();
                                            } else {
                                              // Jika tidak ada, tambahkan baru
                                              reportC.generateUid();
                                              //generat uid
                                              reportC.tempListReport.add(
                                                Report(
                                                  id: reportC.idReport.text,
                                                  div:
                                                      reportC
                                                          .selectedReportDiv
                                                          .value,
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
                                                  date: DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(DateTime.now()),
                                                ),
                                              );
                                              reportC.update();
                                              reportC.webImage = null;
                                              reportC.selectedReportDiv.value =
                                                  "";
                                              reportC.reportTitle.clear();
                                            }
                                            // Get.back();
                                          } else {
                                            failedDialog(
                                              context,
                                              'ERROR',
                                              'Division, Gambar atau Report tidak boleh kosong.',
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: isWideScreen ? false : true,
                        child: Visibility(
                          visible:
                              reportC.statusSelected.value == "DONE" ||
                              reportTitle == "",
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
                                        // reportC.isEdit.value == false
                                        // ?
                                        'Add',
                                    // : 'Update',
                                    onPressed: () async {
                                      final Uint8List? imgPick;
                                      if (reportTitle!.isEmpty) {
                                        imgPick = reportC.webImage;
                                      } else {
                                        imgPick = reportC.webImage2;
                                      }
                                      if (imgPick != null &&
                                          reportC.reportTitle.text.isNotEmpty &&
                                          reportC
                                              .selectedReportDiv
                                              .isNotEmpty) {
                                        reportC.isEdit.value =
                                            uid != null && uid.isNotEmpty;
                                        int index = -1;
                                        if (reportC.isEdit.value) {
                                          index = reportC.tempListReport
                                              .indexWhere((r) => r.uid == uid);
                                        }
                                        if (index != -1) {
                                          final oldReport =
                                              reportC.detailDataReport;
                                          if (oldReport[index].imageBf!
                                              .contains('reports/')) {
                                            final imageUrl =
                                                '${ServiceApi().baseUrl}${oldReport[index].imageBf!}';
                                            //print(oldReport);
                                            await reportC.downloadImageBf(
                                              imageUrl,
                                            );
                                          } else {
                                            reportC
                                                .webImage = Uint8List.fromList(
                                              base64Decode(
                                                oldReport[index].imageBf!,
                                              ),
                                            );
                                          }
                                          // Update hanya imageBf pada item yang ada
                                          reportC
                                              .tempListReport[index]
                                              .imageAf = base64Encode(
                                            reportC.webImage2!,
                                          );

                                          reportC.tempListReport[index].report =
                                              reportC.reportTitle.text;
                                          reportC.tempListReport[index].status =
                                              reportC.statusSelected.value;

                                          Get.back(); // Tutup dialog sebelumnya jika ada
                                           Future.delayed(
                                                const Duration(seconds: 1),
                                              );
                                          addReport(
                                            context,
                                            id,
                                            div,
                                            reportTitle,
                                            oldReport[index].imageBf!,
                                            '', // image2 jika ada
                                            status,
                                            uid,
                                            date,
                                            dataUser,
                                          );

                                          reportC.isEdit.value = true;

                                          // reportC.webImage = null;
                                          reportC.webImage2 = null;
                                          reportC.reportTitle.clear();
                                          reportC.isEdit.value = false;
                                          reportC.update();
                                        } else {
                                          // Jika tidak ada, tambahkan baru
                                          reportC.generateUid();
                                          //generat uid
                                          reportC.tempListReport.add(
                                            Report(
                                              id: reportC.idReport.text,
                                              div:
                                                  reportC
                                                      .selectedReportDiv
                                                      .value,
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
                                              date: DateFormat(
                                                'yyyy-MM-dd',
                                              ).format(DateTime.now()),
                                            ),
                                          );
                                          reportC.update();
                                          reportC.webImage = null;
                                          reportC.selectedReportDiv.value = "";
                                          reportC.reportTitle.clear();
                                        }
                                        // Get.back();
                                      } else {
                                        failedDialog(
                                          context,
                                          'ERROR',
                                          'Division, Gambar atau Report tidak boleh kosong.',
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
                          dataUser: dataUser,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CsElevatedButton(
                  onPressed: () {
                    // print(object)
                    // print(reportC.tempListReport.map((e) => e.imageBf).toList());
                    // if (reportC.formKeyReport.currentState!.validate()) {
                    reportC.tempListReport.isNotEmpty
                        ? reportC.submitReport(
                          uid != "" ? "update_report" : "add_detail_report",
                          uid,
                          dataUser!.kodeCabang,
                        )
                        : failedDialog(
                          context,
                          'ERROR',
                          // 'Report belum ada\nSilahkan tambahkan report terlebih dahulu',
                          'Harap periksa kembali input data Anda',
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
                          reportC.statusSelected.value = "";
                          reportC.selectedReportDiv.value = "";
                          reportC.webImage = null;
                          reportC.webImage2 = null;
                          reportC.tempListReport.clear();
                          reportC.isEdit.value = false;
                          Get.back();
                        },
                        isWideScreen,
                      );
                    } else {
                      reportC.statusSelected.value = "";

                      reportC.selectedReportDiv.value = "";
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
  // required String label,
  required VoidCallback onTap,
  required Uint8List? webImage,
  // required String imageUrl,
  required bool isBefore,
}) {
  return Column(
    children: [
      // Text(label),
      // const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: ClipRRect(
          child: GetBuilder<ReportIssueController>(
            builder: (c) {
              final Uint8List? imageData = isBefore ? c.webImage : c.webImage2;
              if (imageData != null) {
                return Container(
                  height: 80,
                  width: 80,
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
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      Text(
                        'Click to upload image',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10),
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
