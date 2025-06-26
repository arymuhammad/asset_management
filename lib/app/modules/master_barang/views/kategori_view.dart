import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/views/widget/add_edit_assets.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/models/category_assets_model.dart';
import '../controllers/master_barang_controller.dart';
import 'widget/add_edit_cat.dart';

class KategoriView extends GetView {
  KategoriView({super.key});

  // late final Mydata dataSource;
  final masterC = Get.put(MasterBarangController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;

            return FutureBuilder(
              future: masterC.getCatAssets({"type": "", "group": ""}),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  masterC.dataSourceMydata = Mydata(
                    dataCatAsset: masterC.dataCatAssetsFiltered,
                    screenWidth: isWideScreen,
                  );
                  return PaginatedDataTable2(
                    minWidth: 1000,
                    // isHorizontalScrollBarVisible: true,
                    // isVerticalScrollBarVisible: true,
                    // columnSpacing: 100,
                    // horizontalMargin: 40,
                  
                    smRatio: 1.1, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    rowsPerPage: masterC.rowsPerPage,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        masterC.rowsPerPage = value;
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
                          label: 'Search Data',
                          onChanged: (val) {
                            masterC.filterDataCatAsset(val);
                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                            assetC.dataSourceMydata.notifyListeners();
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => addEditCat(context, '', '', '', ''),
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                      ),
                    ],
                    header: const Text('KATEGORI'),
                    columns: const [
                      DataColumn(label: Text('Kategori Asset')),
                      DataColumn(label: Text('Kelompok')),
                      DataColumn(label: Text('Deskripsi')),
                      DataColumn(label: Text('Action')),
                    ],
                    source: assetC.dataSourceMydata,
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
            );
          },
        ),
      ),
    );
  }
}

class Mydata extends DataTableSource {
  Mydata({required this.dataCatAsset, required bool screenWidth});
  final RxList<CategoryAssets> dataCatAsset;
  final bool isWideScreen = Get.width >= 800;

  // updateData(RxList<CategoryAssets> newUsers) {
  //   dataCatAsset.value = newUsers;
  //   notifyListeners(); // Memberi tahu PaginatedDataTable bahwa data berubah
  // }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataCatAsset.length) {
      return null;
    }
    final item = dataCatAsset[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(item.catName!)),
        DataCell(Text(item.assetsGroup!)),
        DataCell(Text(item.desc!)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () {
                  addEditCat(
                    Get.context!,
                    item.id,
                    item.catName,
                    item.desc,
                    item.assetsGroup,
                  );
                },
                icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                splashRadius: 10,
              ),
              IconButton(
                tooltip: 'Hapus',
                onPressed: () {
                  promptDialog(
                    Get.context!,
                    'HAPUS',
                    'Anda yakin ingin menghapus data ini?',
                    () => assetC.deleteAssetCategories(item.id!),
                    isWideScreen,
                  );
                },
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                splashRadius: 10,
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
  int get rowCount => dataCatAsset.length;

  @override
  int get selectedRowCount => 0;
}
