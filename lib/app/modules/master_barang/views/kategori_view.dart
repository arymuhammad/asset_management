import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/elevated_button_icon.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/views/widget/add_edit_assets.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/models/category_assets_model.dart';
import '../../../data/models/login_model.dart';
import '../controllers/master_barang_controller.dart';
import 'widget/add_edit_cat.dart';

class KategoriView extends GetView {
  KategoriView({super.key, this.userData});

  // late final Mydata dataSource;
  final Data? userData;
  final masterC = Get.put(MasterBarangController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: masterC.getCatAssets({"type": "", "group": ""}),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  masterC.category = Mydata(
                    dataCatAsset: masterC.dataCatAssetsFiltered,
                    screenWidth: isWideScreen,
                    userData: userData
                  );
                  return PaginatedDataTable2(
                    minWidth: 1000,
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
                      (states) => AppColors.itemsBackground,
                    ),
                    headingRowHeight: 40,
                    // actions: [
                    //   Visibility(
                    //     visible: isWideScreen ? true : false,
                    //     child: SizedBox(
                    //       width: 150,
                    //       height: 35,
                    //       child: CsTextField(
                    //         controller: catC.searchKategoriController,
                    //         label: 'Search Data',
                    //         maxLines: 1,
                    //         onChanged: (val) {
                    //           masterC.filterDataCatAsset(val);
                    //           // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                    //           assetC.category.notifyListeners();
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    //   IconButton(
                    //     onPressed: () => addEditCat(context, '', '', '', ''),
                    //     icon: const Icon(HugeIcons.strokeRoundedAddCircle),
                    //     tooltip: 'Add Category',
                    //   ),
                    // ],
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategori', style: TextStyle(fontSize: 15)),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 35,
                              child: CsTextField(
                                controller: catC.searchKategoriController,
                                label: 'Search Data',
                                maxLines: 1,
                                onChanged: (val) {
                                  masterC.filterDataCatAsset(val);
                                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                  assetC.category.notifyListeners();
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            CsElevatedButtonIcon(
                              icon: const Icon(Icons.playlist_add_outlined),
                              fontSize: 13,
                              label: 'Add',
                              onPressed:
                                  () => addEditCat(context, '', '', '', ''),
                              size: const Size(90, 35),
                            ),
                          ],
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Kategori Asset',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Kelompok',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Deskripsi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Center(
                          child: Text(
                            'Action',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    source: assetC.category,
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
          // floatingActionButton:
          //     !isWideScreen
          //         ? FloatingActionButton(
          //           backgroundColor: AppColors.itemsBackground,
          //           onPressed: () {
          //             seachForm(context);
          //           },
          //           child: const Icon(Icons.search),
          //         )
          //         : null,
        );
      },
    );
  }
}

// seachForm(context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return LayoutBuilder(
//         builder: (context, constraints) {
//           return AlertDialog(
//             contentPadding: const EdgeInsets.all(8),
//             content: SizedBox(
//               width: 150,
//               height: 35,
//               child: CsTextField(
//                 // readOnly: false,
//                 controller: catC.searchKategoriController,
//                 maxLines: 1,
//                 label: 'Search Data',
//                 onChanged: (val) {
//                   catC.filterDataCatAsset(val);
//                   // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
//                   catC.category.notifyListeners();
//                 },
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

class Mydata extends DataTableSource {
  Mydata({
    required this.dataCatAsset,
    required bool screenWidth,
    this.userData,
  });
  final RxList<CategoryAssets> dataCatAsset;
  final bool isWideScreen = Get.width >= 800;
  final Data? userData;

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
        DataCell(Text(item.catName!.capitalize!)),
        DataCell(Text(item.assetsGroup!)),
        DataCell(Text(item.desc!)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () {
  if (userData?.level != '1') {
    failedDialog(
      Get.context!,
      'ERROR',
      'Harap hubungi IT untuk perubahan data ini',
      isWideScreen,
    );
  } else {
     addEditCat(
                            Get.context!,
                            item.id,
                            item.catName,
                            item.desc,
                            item.assetsGroup,
                          );
  }
},
             
                icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                splashRadius: 10,
              ),
              IconButton(
                tooltip: 'Hapus',
                 onPressed: () {
  if (userData?.level != '1') {
    failedDialog(
      Get.context!,
      'ERROR',
      'Harap hubungi IT untuk penghapusan data ini',
      isWideScreen,
    );
  } else {
    promptDialog(
                            Get.context!,
                            'HAPUS',
                            'Anda yakin ingin menghapus data ini?',
                            () => assetC.deleteAssetCategories(item.id!),
                            isWideScreen,
                          );
  }
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
