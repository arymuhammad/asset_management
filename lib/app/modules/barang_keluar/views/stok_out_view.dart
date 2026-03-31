import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/models/barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/barang_keluar_controller.dart';
import 'widget/add_edit_stok_out.dart';

class StokOutView extends GetView<BarangKeluarController> {
  StokOutView({super.key, this.userData});

  final stokOutC = Get.put(BarangKeluarController());
  final Data? userData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        stokOutC.dataSourceOut = StokOutData(
          dataStokOut: stokOutC.dataStokOutFiltered,
          screenWidth: isWideScreen,
        );
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: FutureBuilder(
              future: stokOutC.getStokOutData(userData!.kodeCabang!, userData!.levelUser!.split(' ')[0]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PaginatedDataTable2(
                    minWidth: 1300,
                    columnSpacing: 20,
                    // // columnSpacing: 100,
                    // horizontalMargin: 40,
                    smRatio: 0.9, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    // fixedLeftColumns: 1,
                    rowsPerPage: stokOutC.rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        stokOutC.rowsPerPage = value;
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
                            controller: stokOutC.searchController,
                            label: 'Search Data',
                            onChanged: (val) {
                              stokOutC.filterDataStokOut(val);
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              stokOutC.dataSourceOut.notifyListeners();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          addEditStokOut(
                            context,
                            '',
                            '',
                            '',
                            '',
                            '',
                            RxList.empty(),
                          );
                          await stokOutC.generateNumbId();
                          // print(stokOutC.idTrx);
                        },
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                      ),
                    ],
                    header: const Text(
                      'Barang Keluar',
                      style: TextStyle(fontSize: 15),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Pengirim',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Penerima',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn2(
                        label: Text(
                          'Keterangan',
                          style: TextStyle(color: Colors.white),
                        ),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(
                          'Total',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 80,
                      ),
                      DataColumn2(
                        label: Text(
                          'Dibuat oleh',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 135,
                      ),
                      DataColumn2(
                        label: Text(
                          'Tanggal',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 110,
                      ),
                      DataColumn2(
                        label: Text(
                          'Status',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 90,
                      ),
                      DataColumn2(
                        label: Text(
                          'Action',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 90,
                      ),
                    ],
                    source: stokOutC.dataSourceOut,
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
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
                      seachForm(context);
                    },
                    child: const Icon(Icons.search),
                  )
                  : null,
        );
      },
    );
  }
}

seachForm(context) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(8),
            content: SizedBox(
              width: 150,
              height: 35,
              child: CsTextField(
                // readOnly: false,
                controller: stokOutC.searchController,
                maxLines: 1,
                label: 'Search Data',
                onChanged: (val) {
                  stokOutC.filterDataStokOut(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  stokOutC.dataSourceOut.notifyListeners();
                },
              ),
            ),
          );
        },
      );
    },
  );
}

class StokOutData extends DataTableSource {
  StokOutData({required this.dataStokOut, required bool screenWidth});
  final RxList<BarangKeluarMasuk> dataStokOut;
  final bool isWideScreen = Get.width >= 800;
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataStokOut.length) {
      return null;
    }
    final item = dataStokOut[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.id!)),
        DataCell(Text(item.pengirim!.capitalize!, style: const TextStyle(fontSize: 13))),
        DataCell(Text(item.penerima!.capitalize!, style: const TextStyle(fontSize: 13))),
        DataCell(Text(item.desc!.capitalize!, style: const TextStyle(fontSize: 13))),
        DataCell(Text(item.qtyAmount!)),
        DataCell(Text(item.createdBy!.capitalize!)),
        DataCell(
          Text(
            FormatWaktu.formatTglBlnThn(
              tanggal: DateTime.parse(item.createdAt!),
            ),
          ),
        ),
        DataCell(Text(item.status!, style: const TextStyle(fontSize: 12),)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: item.status! == "OPEN" ? 'Edit' : 'Detail',
                onPressed: () async {
                  loadingDialog("Memuat data...", "");
                  await stokOutC.editDataOut(item.id!);
                  Get.back();
                  addEditStokOut(
                    Get.context!,
                    item.id,
                    item.kodePenerima,
                    item.penerima,
                    item.desc,
                    item.status,
                    stokOutC.detailStokOut,
                  );
                },
                icon: Icon(
                  item.status! == "OPEN"
                      ? Icons.edit
                      : Icons.remove_red_eye_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                splashRadius: 10,
              ),
              Visibility(
                visible: item.status! == "OPEN" ? true : false,
                child: IconButton(
                  tooltip: item.status! == "OPEN" ? 'Cancel' : 'Delete',
                  onPressed: () {
                    promptDialog(
                      Get.context!,
                      'HAPUS',
                      'Anda yakin ingin menghapus data ini?',
                      () async {
                        await stokOutC.deleteStokOut(item.id!);
                        await stokOutC.getStokOutData(stokOutC.fromBranch, stokOutC.levelUser.split(' ')[0]);
                        stokOutC.filterDataStokOut("");
                        // ignore: invalid_use_of_protected_member
                        stokOutC.dataSourceOut.notifyListeners();
                      },
                      isWideScreen,
                    );
                    // stokC.deleteAssetCategories(item.id!);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  splashRadius: 10,
                ),
              ),
              Visibility(
                visible: item.status! == "CLOSED" ? true : false,
                child: IconButton(
                  tooltip: 'Print',
                  onPressed: () async {
                    loadingDialog("Memuat data...", "");
                    await stokOutC.editDataOut(item.id!);
                    Get.back();
                    stokOutC.printDoc(id:item.id, penerima: item.penerima, pembuat:item.createdBy);
                  },
                  icon: const Icon(
                    Icons.print,
                    size: 20,
                    color: Colors.lightBlue,
                  ),
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
  int get rowCount => dataStokOut.length;

  @override
  int get selectedRowCount => 0;
}
