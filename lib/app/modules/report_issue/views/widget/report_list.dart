import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/report_by_store_model.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/report_issue/views/report_issue_view.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/add_report.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/models/login_model.dart';
import '../../../../data/shared/container_color.dart';
import '../../controllers/report_issue_controller.dart';

class ReportListView extends StatelessWidget {
  const ReportListView({super.key, this.userData});
  final Data? userData;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // bool isWideScreen = constraints.maxWidth >= 800;
        return Scaffold(
          body: Obx(() {
            if (!reportC.isReady.value || reportC.dataListStore == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final fade = FadeTransition(opacity: animation, child: child);
                final slide = SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0), // geser dikit dari kanan
                    end: Offset.zero,
                  ).animate(animation),
                  child: fade,
                );
                return slide;
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child:
                    reportC.viewMode.value == ReportViewMode.list
                        ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                                color: Colors.black.withOpacity(0.08),
                              ),
                            ],
                          ),
                          child: ClipRect(
                            child: _buildTable(key: const ValueKey('list')),
                          ),
                        ) // tabel lama kamu
                        : ReportIssueView(
                          userData: userData,
                          key: const ValueKey('detail'),
                          branch: reportC.selectedStore.value!.kodeCabang,
                          isHO: true,
                        ),
              ),
            );
          }),
        );
      },
    );
  }

  PaginatedDataTable2 _buildTable({required ValueKey<String> key}) {
    return PaginatedDataTable2(
      key: key,

      // ====== Layout ======
      wrapInCard: false, // kita bikin card sendiri biar lebih modern
      minWidth: 1200,
      headingRowHeight: 46,
      dataRowHeight: 46,

      // ====== NO GAP / NO LINE ======
      horizontalMargin: 0,
      columnSpacing: 0,
      // dividerThickness: 0,
      border: const TableBorder(
        horizontalInside: BorderSide.none,
        verticalInside: BorderSide.none,
        top: BorderSide.none,
        bottom: BorderSide.none,
        left: BorderSide.none,
        right: BorderSide.none,
      ),

      // ====== Header ======
      headingRowColor: WidgetStateProperty.all(AppColors.itemsBackground),
      headingTextStyle: const TextStyle(
        color: Colors.white,
        // fontWeight: FontWeight.w700,
        fontSize: 13,
      ),

      // // ====== Row style ======
      // dataRowColor: WidgetStateProperty.resolveWith((states) {
      //   if (states.contains(WidgetState.hovered)) {
      //     return Colors.black.withOpacity(0.04);
      //   }
      //   return Colors.transparent;
      // }),

      // ====== Pagination ======
      rowsPerPage: reportC.rowsPerPage,
      availableRowsPerPage: const [5, 10, 20, 50, 100],
      onRowsPerPageChanged: (value) {
        if (value != null) reportC.rowsPerPage = value;
      },
      showFirstLastButtons: true,
      renderEmptyRowsInTheEnd: false,

      // ====== Empty ======
      empty:
          reportC.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : const Center(child: Text("Belum ada data")),

      // ====== Top Header ======
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Text(
              "Dashboard Statistik Report",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: 180,
              height: 34,
              child: CsTextField(
                label: "Search",
                onChanged: (val) {
                  reportC.filterDataReportByStore(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  reportC.dataListStore!.notifyListeners();
                },
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),

      // ====== Columns ======
      columns: const [
        DataColumn2(label: _HeaderCell("No"), fixedWidth: 50),
        DataColumn2(label: _HeaderCell("Store"), fixedWidth: 280),
        DataColumn2(label: _HeaderCell("Total"), fixedWidth: 90),
        DataColumn2(label: _HeaderCell("Pending"), fixedWidth: 90),
        DataColumn2(label: _HeaderCell("Follow Up"), fixedWidth: 90),
        DataColumn2(label: _HeaderCell("On Progress"), fixedWidth: 110),
        DataColumn2(label: _HeaderCell("Done"), fixedWidth: 90),
        DataColumn2(label: _HeaderCell("Re Schedule"), fixedWidth: 110),
      ],

      source: reportC.dataListStore!,
    );
  }
}

class ReportListStore extends DataTableSource {
  ReportListStore({required this.dataListStore, required this.userData});
  RxList<ReportByStore> dataListStore;
  final Data userData;
  @override
  DataRow? getRow(int index) {
    if (index >= dataListStore.length) return null;

    final item = dataListStore[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(_TextCell('${index + 1}', align: TextAlign.center)),
        DataCell(
          InkWell(
            onTap: () async {
              loadingDialog("Memuat data...", "");

              await reportC.getReport(item.kodeCabang);
              reportC.statusSelected.value = "";
              reportC.filterDataReport('');

              Get.back();
              reportC.showDetail(item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaCabang ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Klik untuk lihat detail",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ====== Statistik block ======
        DataCell(CsContainerColor(color: Colors.red, child: Text(item.totalReport!, style: const TextStyle(color: Colors.white),))),
        DataCell(CsContainerColor(color: Colors.grey, child: Text(item.totalPending!, style: const TextStyle(color: Colors.white),))),
        DataCell(
          CsContainerColor(color: Colors.yellow.shade700, child: Text(item.totalFu!, style: const TextStyle(color: Colors.white),)),
        ),
        DataCell(CsContainerColor(color: Colors.blue, child: Text(item.totalOnPrgs!, style: const TextStyle(color: Colors.white),))),
        DataCell(CsContainerColor(color: Colors.green, child: Text(item.totalDone!, style: const TextStyle(color: Colors.white),))),
        DataCell(CsContainerColor(color: Colors.black, child: Text(item.totalResche!, style: const TextStyle(color: Colors.white),))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataListStore.length;

  @override
  int get selectedRowCount => 0;
}

class _TextCell extends StatelessWidget {
  const _TextCell(this.text, {this.align = TextAlign.left});
  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text, textAlign: align, style: const TextStyle(fontSize: 13)),
    );
  }
}
class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text),
    );
  }
}
