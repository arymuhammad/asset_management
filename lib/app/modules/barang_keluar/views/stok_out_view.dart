import 'package:assets_management/app/data/models/barang_masuk_keluar_model.dart';
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
  StokOutView({super.key});

  final stokOutC = Get.put(BarangKeluarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(12),
          child:
              stokOutC.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth >= 800;
                      stokOutC.dataSource = StokOutData(
                        dataStokOut: stokOutC.dataStokOutFiltered,
                        screenWidth: isWideScreen,
                      );
                      return PaginatedDataTable2(
                        minWidth: 1300,
                        columnSpacing: 20,
                        isHorizontalScrollBarVisible: true,
                        isVerticalScrollBarVisible: true,
                        // columnSpacing: 100,
                        // horizontalMargin: 40,
                        smRatio: 0.9, // Rasio lebar kolom S terhadap M
                        lmRatio: 2.0,
                        fixedLeftColumns: 1,
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
                          children: [
                            Text('Belum ada data'),
                          ],
                        ),
                        actions: [
                          SizedBox(
                            width: 150,
                            height: 35,
                            child: CsTextField(
                              // readOnly: false,
                              label: 'Search Data',
                              onChanged: (val) {
                                stokOutC.filterDataStokOut(val);
                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                stokOutC.dataSource.notifyListeners();
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: ()async {
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
                              print(stokOutC.idTrx);
                            },
                            icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                          ),
                        ],
                        header: const Text('BARANG KELUAR'),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Pengirim')),
                          DataColumn(label: Text('Penerima')),
                          DataColumn2(
                            label: Text('Keterangan'),
                            size: ColumnSize.L,
                          ),
                          DataColumn2(label: Text('Total'), fixedWidth: 60),
                          DataColumn2(
                            label: Text('Dibuat oleh'),
                            fixedWidth: 135,
                          ),
                          DataColumn2(label: Text('Tanggal'), fixedWidth: 110),
                          DataColumn2(
                            label: Text('Status'),
                           fixedWidth: 115,
                          ),
                          DataColumn2(label: Text('Action'), fixedWidth: 100),
                        ],
                        source: stokOutC.dataSource,
                      );
                    },
                  ),
        );
      }),
    );
  }
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
                        await stokOutC.getStokOutData(stokOutC.fromBranch);
                        stokOutC.filterDataStokOut("");
                        // ignore: invalid_use_of_protected_member
                        stokOutC.dataSource.notifyListeners();
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
