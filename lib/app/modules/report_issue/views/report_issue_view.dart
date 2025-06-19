import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/add_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/report_issue_controller.dart';
import 'widget/edit_report.dart';

class ReportIssueView extends GetView<ReportIssueController> {
  ReportIssueView({super.key});

  final reportC = Get.put(ReportIssueController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(12),
          child:
              reportC.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: Colors.blueGrey[50],
                      dividerColor: Colors.grey[300],
                      textTheme: const TextTheme(
                        bodyMedium: TextStyle(fontSize: 14),
                      ),
                    ),
                    child: PaginatedDataTable2(
                      minWidth: 1300,
                      dataRowHeight:
                          200, //minimal tinggi baris, bisa disesuaikan
                      wrapInCard: true,
                      columnSpacing: 20,
                      horizontalMargin: 12,
                      // isHorizontalScrollBarVisible: true,
                      // isVerticalScrollBarVisible: true,
                      // columnSpacing: 100,
                      // horizontalMargin: 40,
                      smRatio: 0.9, // Rasio lebar kolom S terhadap M
                      lmRatio: 2.0,
                      fixedLeftColumns: 1,
                      rowsPerPage: reportC.rowsPerPage,
                      availableRowsPerPage: const [5, 10, 20, 50, 100],
                      onRowsPerPageChanged: (value) {
                        if (value != null) {
                          reportC.rowsPerPage = value;
                        }
                      },
                      renderEmptyRowsInTheEnd: false,
                      showFirstLastButtons: true,
                      empty: const Text('Belum ada data'),
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.grey[400],
                      ),
                      headingRowHeight: 40,

                      actions: [
                        SizedBox(
                          width: 150,
                          height: 35,
                          child: CsTextField(
                            // readOnly: false,
                            label: 'Search Data',
                            onChanged: (val) {
                              reportC.filterDataReport(val);
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              reportC.dataSource.notifyListeners();
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await reportC.generateNumbId();
                            addReport(context, '', '', '', '', '', '');
                            // print(reportC.idReport);
                          },
                          icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                        ),
                      ],
                      header: const Text('Report & Maintenance'),
                      columns: const [
                        // DataColumn2(label: Text('ID'), fixedWidth: 150),
                        DataColumn2(
                          label: Center(child: Text('STORE')),
                          fixedWidth: 170,
                        ),
                        DataColumn2(
                          label: Center(child: Text('REPORT')),
                          fixedWidth: 220,
                        ),
                        DataColumn2(
                          label: Center(child: Text('TANGGAL')),
                          fixedWidth: 120,
                        ),
                        DataColumn2(
                          label: Center(child: Text('PRIOTITAS')),
                          fixedWidth: 95,
                        ),
                        DataColumn2(
                          label: Center(child: Text('STATUS')),
                          size: ColumnSize.M,
                        ),
                        DataColumn(label: Center(child: Text('PROGRESS'))),
                        DataColumn2(
                          label: Center(child: Text('ISSUE')),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Center(child: Text('KETERANGAN')),
                          size: ColumnSize.M,
                        ),
                        DataColumn(label: Center(child: Text('ACTION'))),
                      ],
                      source: reportC.dataSource,
                    ),
                  ),
        );
      }),
    );
  }
}

class ReportData extends DataTableSource {
  ReportData({required this.dataReport});
  final RxList<Report> dataReport;
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataReport.length) {
      return null;
    }
    final item = dataReport[index];
    //item report
    String joinedReport = '';
    String joinedPriority = '';
    // String joinedStatus = '';
    String joinedProgress = '';
    String joinedIssue = '';
    String joinedKeterangan = '';
    List<String> itemSts = [];
    //
    if (item.report != null && item.report!.trim().isNotEmpty) {
      var itemReport = item.report!.split(',').map((e) => e.trim()).toList();
      joinedReport = itemReport
          .asMap()
          .entries
          .map((entry) {
            int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
            String val = entry.value;
            return '$idx. ${val.substring(0, val.length > 25 ? 25 : val.length) + (val.length > 25 ? '...' : '')}';
          })
          .join('\n');
    } else {
      joinedReport = 'empty';
    }

    //item priority
    if (item.priority != null && item.priority!.trim().isNotEmpty) {
      var itemPriority =
          item.priority!.split(',').map((e) => e.trim()).toList();
      joinedPriority = itemPriority
          .asMap()
          .entries
          .map((entry) {
            int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
            String val = entry.value;
            return '$idx. $val';
          })
          .join('\n');
    } else {
      joinedPriority = 'empty';
    }

    //item status
    if (item.status != null && item.status!.trim().isNotEmpty) {
      itemSts = item.status!.split(',').map((e) => e.trim()).toList();
      // joinedStatus =
      // itemSts =
      // itemStatus
      //     .asMap()
      //     .entries
      //     .map((entry) {
      //       int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
      //       String val = entry.value;
      //       return '$idx. $val';
      //     })
      //     .join('\n');
    } else {
      // joinedStatus = 'empty';
      itemSts = ['empty'];
    }

    //item progress
    if (item.progress != null && item.progress!.trim().isNotEmpty) {
      var itemProgress =
          item.progress!.split(',').map((e) => e.trim()).toList();
      joinedProgress = itemProgress
          .asMap()
          .entries
          .map((entry) {
            int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
            String val = entry.value;

            return '$idx. ${val.substring(0, val.length > 15 ? 15 : val.length) + (val.length > 15 ? '...' : '')}';
          })
          .join('\n');
    } else {
      joinedProgress = 'empty';
    }

    //item issue
    if (item.issue != null && item.issue!.trim().isNotEmpty) {
      var itemIssue = item.issue!.split(',').map((e) => e.trim()).toList();
      joinedIssue = itemIssue
          .asMap()
          .entries
          .map((entry) {
            int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
            String val = entry.value;
            return '$idx. ${val.substring(0, val.length > 15 ? 15 : val.length) + (val.length > 15 ? '...' : '')}';
          })
          .join('\n');
    } else {
      joinedIssue = 'empty';
    }

    //item keterangan
    if (item.keterangan != null && item.keterangan!.trim().isNotEmpty) {
      var itemKeterangan =
          item.keterangan!.split(',').map((e) => e.trim()).toList();
      joinedKeterangan = itemKeterangan
          .asMap()
          .entries
          .map((entry) {
            int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
            String val = entry.value;
            return '$idx. ${val.substring(0, val.length > 15 ? 15 : val.length) + (val.length > 15 ? '...' : '')}';
          })
          .join('\n');
    } else {
      joinedKeterangan = 'empty';
    }

    //item date

    var itemDate = item.date!.split(',').map((e) => e.trim()).toList();
    var joinedDate = itemDate
        .asMap()
        .entries
        .map((entry) {
          // int idx = entry.key + 1; // +1 supaya mulai dari 1 bukan 0
          String val = entry.value;
          return FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(val));
        })
        .join('\n');

    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'ON PROGRESS':
          return Colors.yellowAccent[700]!;
        case 'DONE':
          return Colors.greenAccent[700]!;
        case 'HOLD':
          return Colors.redAccent[700]!;
        // case 'OPEN':
        //   return Colors.orange;
        default:
          return Colors.blueAccent[700]!;
      }
    }

    return DataRow.byIndex(
      index: index,
      cells: [
        // DataCell(Text(item.id!)),
        DataCell(
          Container(
            color: Colors.yellow,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () async {
                  loadingDialog("Memuat data...", "");
                  await reportC.getDetailReport(item.id!);
                  Get.back();
                  editReport(
                    Get.context!,
                    item.id!,
                    item.cabang!,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    item.createdAt!,
                  );
                },
                child: Text(
                  item.cabang!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            joinedReport,
            // softWrap: true,
            // maxLines: 2, // Atur sesuai kebutuhan
            // overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text(joinedDate)),
        DataCell(Text(joinedPriority)),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                itemSts.asMap().entries.map((entry) {
                  int idx = entry.key + 1; // nomor urut mulai dari 1
                  String status = entry.value;

                  return Container(
                    // margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      // vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$idx. $status', // menambahkan nomor urut di depan status
                    ),
                  );
                }).toList(),
          ),
        ),
        DataCell(Text(joinedProgress)),
        DataCell(Text(joinedIssue)),
        DataCell(Text(joinedKeterangan)),
        DataCell(
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip:
                      item.status! == "ON PROGRESS" ? 'Edit' : 'Show Detail',
                  onPressed: () async {
                    loadingDialog("Memuat data...", "");
                    await reportC.getDetailReport(item.id!);
                    Get.back();
                    editReport(
                      Get.context!,
                      item.id!,
                      item.cabang!,
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      item.createdAt!,
                    );
                  },
                  icon: Icon(
                    item.status! == "ON PROGRESS"
                        ? Icons.edit
                        : Icons.remove_red_eye_outlined,
                    size: 20,
                    color: Colors.green,
                  ),
                  splashRadius: 10,
                ),
                IconButton(
                  tooltip: 'Print',
                  onPressed: () async {
                    await reportC.getDetailReport(item.id!);
                    reportC.printReport();
                  },
                  icon: Icon(
                    Icons.print_rounded,
                    size: 20,
                    color: Colors.blueAccent[700],
                  ),
                  splashRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataReport.length;

  @override
  int get selectedRowCount => 0;
}
