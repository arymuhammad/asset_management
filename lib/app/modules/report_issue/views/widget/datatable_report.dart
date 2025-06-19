import 'dart:convert';
import 'dart:typed_data';

import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/edit_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../data/Repo/service_api.dart';
import 'add_report.dart';

class DatatableReport extends StatelessWidget {
  const DatatableReport({
    super.key,
    this.reports,
    this.dataCell,
    this.columns = const [],
    this.cells = const [],
    this.cabang,
  });
  final RxList<Report>? reports;
  final Widget? dataCell;
  final List<DataColumn2>? columns; // Bisa null dan bisa list
  final List<DataCell>? cells;
  final String? cabang;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DataTable2(
        empty: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Belum ada data')],
        ),
        lmRatio: 1,
        minWidth: 1000,
        // isHorizontalScrollBarVisible: true,
        // isVerticalScrollBarVisible: true,
        fixedLeftColumns: 1,
        columns: [
          const DataColumn2(label: Text('Image'), fixedWidth: 70),
          const DataColumn2(label: Text('Report'), fixedWidth: 250),
          ...columns!.isNotEmpty
              ? columns!
              : [
                const DataColumn2(label: Text('Priority'), fixedWidth: 110),
                const DataColumn2(label: Text('Progress'), size: ColumnSize.M),
                const DataColumn2(label: Text('Status'), size: ColumnSize.M),
                const DataColumn2(label: Text('Issue'), size: ColumnSize.M),
                const DataColumn2(label: Text('Keterangan'), size: ColumnSize.M),
                const DataColumn2(label: Text('Action'), fixedWidth: 110),
              ],
        ],
        rows:
            reports!
                .map(
                  (report) => DataRow2(
                    cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            // Handle image tap if needed
                          },
                          child: WidgetZoom(
                            heroAnimationTag: 'reportImage${report.id}',
                            zoomWidget: ClipRRect(
                              child:
                                  report.imageBf!.contains('reports/')
                                      ? Image.network(
                                        '${ServiceApi().baseUrl}${report.imageBf!}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/image/no-image.jpg',
                                                ),
                                        height: 100,
                                        width: 100,
                                      )
                                      : Image.memory(
                                        base64Decode(report.imageBf!),
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: 100,
                                      ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        InkWell(
                          onTap:
                              columns!.isEmpty
                                  ? () {
                                    // Handle report tap if needed
                                    Get.back(); // Tutup dialog sebelumnya jika ada
                                    reportC.isUpdate.value = true;
                                    editReport(
                                      context,
                                      report.id!,
                                      cabang,
                                      report.priority!,
                                      report.progress!,
                                      report.status!,
                                      report.issue!,
                                      report.keterangan!,
                                      report.report!,
                                      report.uid!,
                                    );
                                  }
                                  : null,
                          child: Text(
                            report.report!,
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
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      final oldReport = report;
                                      // Buka dialog addReport kembali
                                      Get.back(); // Tutup dialog sebelumnya jika ada
                                      reportC.webImage = Uint8List.fromList(
                                        base64Decode(oldReport.imageBf!),
                                      );
                                      reportC.isEdit.value = true;
                                      addReport(
                                        context,
                                        oldReport.id,
                                        oldReport.report,
                                        oldReport.imageBf,
                                        '', // image2 jika ada
                                        oldReport.status,
                                        oldReport.uid,
                                      );
                                    },
                                  ),
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
                            DataCell(dataCell!),
                          ],
                    ],
                  ),
                )
                .toList()
                .reversed
                .toList(),
      ),
    );
  }
}
