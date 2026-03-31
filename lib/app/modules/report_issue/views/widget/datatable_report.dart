import 'dart:convert';
import 'dart:typed_data';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/edit_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../data/Repo/service_api.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../controllers/report_issue_controller.dart';
import 'add_report.dart';

class DatatableReport extends StatelessWidget {
  DatatableReport({
    super.key,
    this.reports,
    this.dataCell,
    this.columns = const [],
    this.cells = const [],
    this.cabang,
    this.dataUser,
  });
  final RxList<Report>? reports;
  final Widget? dataCell;
  final List<DataColumn2>? columns; // Bisa null dan bisa list
  final List<DataCell>? cells;
  final String? cabang;
  final Data? dataUser;
  final rptC = Get.find<ReportIssueController>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;
          return Obx(
            () => DataTable2(
              empty: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Belum ada data')],
              ),
              lmRatio: 1,
              minWidth: 1300,
              dataRowHeight:
                  reports!.isNotEmpty && reports!.first.report!.length >= 50
                      ? 80
                      : 50, // fixedLeftColumns: 1,
              columns: [
                const DataColumn2(label: Text('Image B/A'), fixedWidth: 120),
                const DataColumn2(label: Text('Report'), fixedWidth: 250),
                ...columns!.isNotEmpty
                    ? columns!
                    : [
                      const DataColumn2(
                        label: Text('Priority'),
                        fixedWidth: 105,
                      ),
                      const DataColumn2(
                        label: Text('Progress'),
                        fixedWidth: 200,
                      ),
                      const DataColumn2(label: Text('Status'), fixedWidth: 120),
                      const DataColumn2(
                        label: Text('Issue'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(label: Text('Note'), fixedWidth: 180),
                      const DataColumn2(label: Text('Action'), fixedWidth: 110),
                    ],
              ],
              rows:
                  reports!.map((report) {
                    final imgAf = report.imageAf;

                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.black,
                                        insetPadding: const EdgeInsets.all(0),
                                        child: GestureDetector(
                                          onSecondaryTapDown:
                                              rptC.storePosition, // Tangkap posisi klik kanan
                                          onSecondaryTap: rptC.showCustomMenu(
                                            context,
                                            '${ServiceApi().baseUrl}${report.imageBf!}',
                                            isWideScreen,
                                          ), // Tampilkan menu kustom
                                          // onLongPress: () async {
                                          //   // try {
                                          //   rptC.copyImageToClipboard(

                                          //   );
                                          //   // } catch (e) {
                                          //   //   failedDialog(
                                          //   //     context,
                                          //   //     'error',
                                          //   //     'Failed to copy image: $e',
                                          //   //     isWideScreen,
                                          //   //   );
                                          //   // }
                                          // },
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            rptC.enableRightClick();
                                          },
                                          child: PhotoView(
                                            imageProvider:
                                                report.imageBf!.contains(
                                                      'reports/',
                                                    )
                                                    ? NetworkImage(
                                                      '${ServiceApi().baseUrl}${report.imageBf!}',
                                                    )
                                                    : MemoryImage(
                                                          base64Decode(
                                                            report.imageBf!,
                                                          ),
                                                        )
                                                        as ImageProvider,
                                            backgroundDecoration:
                                                const BoxDecoration(
                                                  color: Colors.black,
                                                ),
                                            minScale:
                                                PhotoViewComputedScale
                                                    .contained,
                                            maxScale:
                                                PhotoViewComputedScale.covered *
                                                3,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child:
                                    report.imageBf!.contains('reports/')
                                        ? Image.network(
                                          '${ServiceApi().baseUrl}${report.imageBf!}',
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                                    'assets/image/no-image.jpg',
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            );
                                          },
                                        )
                                        : Image.memory(
                                          base64Decode(report.imageBf!),
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                        ),
                              ),
                              const SizedBox(width: 5),

                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.black,
                                        insetPadding: const EdgeInsets.all(0),
                                        child: GestureDetector(
                                          onSecondaryTapDown:
                                              rptC.storePosition, // Tangkap posisi klik kanan
                                          onSecondaryTap: () {
                                            final imgAf = report.imageAf;
                                            rptC.showCustomMenu(
                                              context,
                                              imgAf != null && imgAf.isNotEmpty
                                                  ? '${ServiceApi().baseUrl}$imgAf'
                                                  : '',
                                              isWideScreen,
                                            );
                                          },
                                          // Tampilkan menu kustom
                                          // onLongPress: () async {
                                          //   // try {
                                          //   rptC.copyImageToClipboard(

                                          //   );
                                          //   // } catch (e) {
                                          //   //   failedDialog(
                                          //   //     context,
                                          //   //     'error',
                                          //   //     'Failed to copy image: $e',
                                          //   //     isWideScreen,
                                          //   //   );
                                          //   // }
                                          // },
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            rptC.enableRightClick();
                                          },
                                          child: PhotoView(
                                            imageProvider:
                                                imgAf != null &&
                                                        imgAf.isNotEmpty &&
                                                        imgAf.contains(
                                                          'reports/',
                                                        )
                                                    ? NetworkImage(
                                                      '${ServiceApi().baseUrl}$imgAf',
                                                    )
                                                    : MemoryImage(
                                                          base64Decode(imgAf!),
                                                        )
                                                        as ImageProvider,
                                            backgroundDecoration:
                                                const BoxDecoration(
                                                  color: Colors.black,
                                                ),
                                            minScale:
                                                PhotoViewComputedScale
                                                    .contained,
                                            maxScale:
                                                PhotoViewComputedScale.covered *
                                                3,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child:
                                    imgAf != null &&
                                            imgAf.isNotEmpty &&
                                            imgAf.contains('reports/')
                                        ? Image.network(
                                          '${ServiceApi().baseUrl}$imgAf',
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                                    'assets/image/no-image.jpg',
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            );
                                          },
                                        )
                                        : imgAf != null && imgAf.isNotEmpty
                                        ? Image.memory(
                                          base64Decode(imgAf),
                                          fit: BoxFit.cover,
                                          height: 50,
                                          width: 50,
                                        )
                                        : Container(),
                              ),
                            ],
                          ),
                        ),

                        DataCell(
                          InkWell(
                            onTap:
                                columns!.isEmpty
                                    ? () async {
                                      // Handle report tap if needed
                                      Get.back(); // Tutup dialog sebelumnya jika ada
                                      reportC.isUpdate.value = true;
                                      editReport(
                                        context,
                                        report.id!,
                                        report.kodeCabang,
                                        cabang,
                                        // report.imageAf!,
                                        report.priority!,
                                        report.progress!,
                                        report.status!,
                                        report.issue!,
                                        report.keterangan!,
                                        report.report!.capitalizeFirst,
                                        report.uid!,
                                        report.createdBy!,
                                        dataUser!,
                                      );
                                    }
                                    : null,
                            child: Text(
                              report.report!.capitalizeFirst!,
                              style: subtitleTextStyle.copyWith(
                                color:
                                    columns!.isEmpty ? mainColor : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        ...cells!.isNotEmpty
                            ? [
                              DataCell(
                                Row(
                                  children: [
                                    // IconButton(
                                    //   icon: const Icon(Icons.edit),
                                    //   onPressed: () async {
                                    //     final oldReport = report;
                                    //     if (oldReport.imageBf!.contains(
                                    //       'reports/',
                                    //     )) {
                                    //       final imageUrl =
                                    //           '${ServiceApi().baseUrl}${report.imageBf!}';
                                    //       //print(oldReport);
                                    //       await reportC.downloadImageBf(
                                    //         imageUrl,
                                    //       );
                                    //     } else {
                                    //       reportC.webImage = Uint8List.fromList(
                                    //         base64Decode(oldReport.imageBf!),
                                    //       );
                                    //     }

                                    //     // Buka dialog addReport kembali
                                    //     Get.back(); // Tutup dialog sebelumnya jika ada
                                    //     addReport(
                                    //       context,
                                    //       oldReport.id,
                                    //       oldReport.div,
                                    //       oldReport.report,
                                    //       oldReport.imageBf,
                                    //       '', // image2 jika ada
                                    //       oldReport.status,
                                    //       oldReport.uid,
                                    //       oldReport.date,
                                    //       dataUser,
                                    //     );

                                    //     reportC.isEdit.value = true;
                                    //   },
                                    // ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        reportC.tempListReport.remove(report);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]
                            : [
                              DataCell(Text(report.priority!)),
                              DataCell(Text(report.progress!)),
                              DataCell(Text(report.status!)),
                              DataCell(Text(report.issue!)),
                              DataCell(Text(report.keterangan!)),
                              // DataCell(IconButton(onPressed: (){}, icon: icon)),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete, color: red),
                                  onPressed: () {
                                    int index = -1;
                                    index = reports!.indexWhere(
                                      (r) => r.uid == report.uid!,
                                    );
                                    promptDialog(
                                      context,
                                      'Hapus report ini',
                                      report.report,
                                      () async {
                                        if (reports!.length <= 1) {
                                          failedDialog(
                                            context,
                                            'Error',
                                            'Tidak bisa menghapus item ini\n Item Report tidak boleh kosong\n Sisakan setidaknya 1 item',
                                            isWideScreen,
                                          );
                                        } else {
                                          reports!.removeAt(index);
                                          loadingDialog("Menghapus data", "");
                                          await reportC.deleteDetailReport(
                                            report.imageBf!,
                                            report.uid!,
                                          );
                                          Get.back();
                                        }
                                      },
                                      isWideScreen,
                                    );
                                    reportC.update();
                                  },
                                ),
                              ),
                            ],
                      ],
                    );
                  }).toList(),
            ),
          );
        },
      ),
    );
  }
}
