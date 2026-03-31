import 'package:assets_management/app/data/models/so_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/helper/app_colors.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/models/login_model.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/stok_opname_controller.dart';
import 'widget/add_edit_stock_opname.dart';

class StokOpnameView extends GetView<StokOpnameController> {
  StokOpnameView({super.key, this.userData});
  final Data? userData;

  final soC = Get.put(StokOpnameController());
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: soC.getSoData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  soC.dtSo = SoDataSource(
                    dataSo: soC.dataSoFiltered,
                    screenWidth: isWideScreen,
                  );
                  return PaginatedDataTable2(
                    minWidth: 1450,
                    columnSpacing: 20,
                    // columnSpacing: 100,
                    // horizontalMargin: 40,
                    smRatio: 0.9, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    // fixedLeftColumns: 1,
                    rowsPerPage: soC.rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        soC.rowsPerPage = value;
                      }
                    },
                    renderEmptyRowsInTheEnd: false,
                    showFirstLastButtons: true,
                    empty: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Belum ada data')],
                    ),
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => AppColors.itemsBackground,
                    ),
                    headingRowHeight: 40,
                    actions: [
                      Visibility(
                        visible: isWideScreen ? true : false,
                        child: SizedBox(
                          width: 150,
                          height: 35,
                          child: CsTextField(
                            // readOnly: false,
                            controller: controller.searchController,
                            label: 'Search Data',
                            onChanged: (val) {
                              controller.filterDataSo(val);
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              controller.dtSo.notifyListeners();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await soC.generateNumbId();
                          addEditSo(
                            context,
                            '',
                            '',
                            '',
                            '',
                            '',
                            RxList.empty(),
                          );
                        },
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                      ),
                    ],
                    header: const Text(
                      'Stock Opname',
                      style: TextStyle(fontSize: 15),
                    ),
                    columns: const [
                      DataColumn2(
                        label: Text(
                          'ID',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 200,
                      ),
                      DataColumn2(
                        label: Text(
                          'Store',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 200,
                      ),
                      DataColumn2(
                        label: Text(
                          'Description',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 180,
                      ),
                      DataColumn2(
                        label: Text(
                          'Total Init Qty',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 120,
                      ),
                      DataColumn2(
                        label: Text(
                          'Scanned Qty',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 110,
                      ),
                      DataColumn2(
                        label: Text(
                          'Diff Qty',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 100,
                      ),
                      DataColumn2(
                        label: Text(
                          'Status',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 100,
                      ),
                      DataColumn2(
                        label: Text(
                          'Date',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 110,
                      ),
                      DataColumn2(
                        label: Text(
                          'Created By',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 140,
                      ),

                      DataColumn2(
                        label: Text(
                          'Action',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 90,
                      ),
                    ],
                    source: controller.dtSo,
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Memuat data... '),
                      CupertinoActivityIndicator(),
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton:
              !isWideScreen
                  ? FloatingActionButton(
                    backgroundColor: AppColors.itemsBackground,
                    onPressed: () {
                      // seachForm(context);
                    },
                    child: const Icon(Icons.search),
                  )
                  : null,
        );
      },
    );
  }
}

class SoDataSource extends DataTableSource {
  SoDataSource({required this.dataSo, required bool screenWidth});
  final RxList<SoModel> dataSo;
  final bool isWideScreen = Get.width >= 800;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataSo.length) {
      return null;
    }
    final item = dataSo[index];
    // final lvUser = soC.levelUser.split(' ')[0];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          InkWell(
            onTap: () => snackbarCopy(item: item.id!),
            child: Text(
              item.id!,
              style: const TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(Text(item.branchName!.capitalize!)),
        DataCell(
          Text(item.desc!.capitalize!, style: const TextStyle(fontSize: 13)),
        ),
        DataCell(
          Text(item.initQty ?? 'NULL', style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Text(item.scannedQty ?? 'NULL', style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Text(item.diffQty ?? 'NULL', style: const TextStyle(fontSize: 12)),
        ),
        DataCell(Text(item.stat!, style: const TextStyle(fontSize: 12))),
        DataCell(
          Text(
            FormatWaktu.formatTglBlnThn(
              tanggal: DateTime.parse(item.createdAt!),
            ),
          ),
        ),
        DataCell(Text(item.createdBy!.capitalize!)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: item.stat! == "OPEN" ? 'Edit' : 'Show Detail',
                onPressed: () async {
                  loadingDialog("Memuat data...", "");
                  await stokOptC.editSo(item.id!);
                  Get.back();
                  addEditSo(
                    Get.context!,
                    item.id,
                    item.branchCode,
                    item.branchName,
                    item.desc,
                    item.stat,
                    // item.createdBy,
                    // item.stat,
                    // lvUser,
                    stokOptC.detailSo,
                  );
                },
                icon: Icon(
                  item.stat! == 'OPEN'
                      // ? item.stat! == 'Waiting for review' &&
                      //         (['IT', 'AUDIT']).contains(lvUser)
                      ? Icons.edit
                      // : Icons.edit
                      : Icons.remove_red_eye_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                splashRadius: 10,
              ),
              Visibility(
                visible: item.stat! == "OPEN" ? true : false,
                child: IconButton(
                  tooltip: item.stat! == "OPEN" ? 'Cancel' : 'Delete',
                  onPressed: () async {
                    promptDialog(
                      Get.context!,
                      'DELETE',
                      'Are you sure you want to delete this data?',
                      () async {
                        await stokOptC.deleteSo(item.id!);
                        await stokOptC.getSoData();
                        // stokOptC.filterDataStokOut("");
                        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                        stokOptC.dtSo.notifyListeners();
                      },
                      isWideScreen,
                    );
                  },
                  icon: Icon(Icons.remove_circle_outline, size: 20, color: red),
                  splashRadius: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataSo.length;

  @override
  int get selectedRowCount => 0;
}
