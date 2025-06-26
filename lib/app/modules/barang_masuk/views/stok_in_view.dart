import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/helper/format_waktu.dart';
import 'package:assets_management/app/data/models/barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/modules/barang_masuk/controllers/barang_masuk_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/helper/const.dart';
import '../../../data/shared/text_field.dart';
import 'widget/add_edit_stok_in.dart';

class StokInView extends GetView {
  StokInView({super.key, this.userData});

  late final StokInData dataSource;
  final Data? userData;
  final stokInC = Get.put(BarangMasukController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: stokInC.getStokInData(userData!.kodeCabang!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  stokInC.dataSource = StokInData(
                    dataStokIn: stokInC.dataStokInFiltered,
                    screenWidth: isWideScreen,
                  );
                  return PaginatedDataTable2(
                    minWidth: 1300,
                    columnSpacing: 20,
                    // columnSpacing: 100,
                    // horizontalMargin: 40,
                    smRatio: 0.9, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    fixedLeftColumns: 1,
                    rowsPerPage: stokInC.rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        stokInC.rowsPerPage = value;
                      }
                    },
                    renderEmptyRowsInTheEnd: false,
                    showFirstLastButtons: true,
                    empty: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Belum ada data')],
                    ),
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.grey[400],
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
                            controller: stokInC.searchController,
                            label: 'Search Data',
                            onChanged: (val) {
                              stokInC.filterDataStokIn(val);
                              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                              stokInC.dataSource.notifyListeners();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          addEditStokIn(
                            context,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            RxList.empty(),
                          );
                          await stokInC.generateNumbId();
                        },
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                      ),
                    ],
                    header: const Text(
                      'BARANG MASUK',
                      style: TextStyle(fontSize: 15),
                    ),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Pengirim')),
                      DataColumn(label: Text('Penerima')),
                      DataColumn2(
                        label: Text('Keterangan'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(label: Text('Total'), fixedWidth: 80),
                      DataColumn2(
                        label: Text('Dibuat oleh'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(label: Text('Tanggal'), fixedWidth: 100),
                      DataColumn2(label: Text('Status'), fixedWidth: 80),
                      DataColumn2(label: Text('Action'), fixedWidth: 90),
                    ],
                    source: stokInC.dataSource,
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
                controller: stokInC.searchController,
                maxLines: 1,
                label: 'Search Data',
                onChanged: (val) {
                  stokInC.filterDataStokIn(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  stokInC.dataSource.notifyListeners();
                },
              ),
            ),
          );
        },
      );
    },
  );
}

class StokInData extends DataTableSource {
  StokInData({required this.dataStokIn, required bool screenWidth});
  final RxList<BarangKeluarMasuk> dataStokIn;
  final bool isWideScreen = Get.width >= 800;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataStokIn.length) {
      return null;
    }
    final item = dataStokIn[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.id!)),
        DataCell(Text(item.pengirim!)),
        DataCell(Text(item.penerima!)),
        DataCell(Text(item.desc!)),
        DataCell(Text(item.qtyAmount!)),
        DataCell(Text(item.createdBy!)),
        DataCell(
          Text(
            FormatWaktu.formatTglBlnThn(
              tanggal: DateTime.parse(item.createdAt!),
            ),
          ),
        ),
        DataCell(Text(item.status!)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: item.status! == "OPEN" ? 'Edit' : 'Show Detail',
                onPressed: () async {
                  loadingDialog("Memuat data...", "");
                  await stokInC.editDataIn(item.id!);
                  Get.back();
                  addEditStokIn(
                    Get.context!,
                    item.id,
                    item.kodePengirim,
                    item.pengirim,
                    item.kodePenerima,
                    item.penerima,
                    item.qtyAmount,
                    FormatWaktu.formatTglBlnThn(
                      tanggal: DateTime.parse(item.createdAt!),
                    ),
                    item.desc,
                    item.createdBy,
                    item.status,
                    stokInC.detailStokIn,
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
                visible:
                    item.status! == "OPEN" && item.pengirim == item.penerima
                        ? true
                        : false,
                child: IconButton(
                  tooltip: item.status! == "OPEN" ? 'Cancel' : 'Delete',
                  onPressed: () async {
                    promptDialog(
                      Get.context!,
                      'HAPUS',
                      'Anda yakin ingin menghapus data ini?',
                      () async {
                        await stokInC.deleteStokIn(item.id!);
                        await stokInC.getStokInData(stokInC.fromBranch);
                      },
                      isWideScreen,
                    );
                    stokInC.filterDataStokIn("");
                    // ignore: invalid_use_of_protected_member
                    stokInC.dataSource.notifyListeners();
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
  int get rowCount => dataStokIn.length;

  @override
  int get selectedRowCount => 0;
}
