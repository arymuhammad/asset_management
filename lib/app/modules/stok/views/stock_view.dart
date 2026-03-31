import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:assets_management/app/data/shared/elevated_button_icon.dart';
import 'package:assets_management/app/modules/barang_masuk/views/widget/add_edit_stok_in.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart' as exc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/shared/container_color.dart';
import '../../../data/shared/dropdown.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/stok_controller.dart';
import 'widget/detail_stock.dart';
import 'widget/drawer_stok.dart';

class StockView extends GetView {
  StockView({super.key, this.userData});

  final Data? userData;
  final stokC = Get.put(StokController());
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        var listDivisi = ["AUDIT", "IT", "VISUAL"];
        var hiddenDivisi = [
          "Online (Another)",
          "Online (Urban)",
          "Ruang Busdev",
          "Ruang Direktur",
          "Ruang GM",
          "Ruang Kerja Another",
          "Ruang Kerja Audit",
          "Ruang Kerja Brand",
          "Ruang Kerja HRD",
          "Ruang Kerja IT",
          "Ruang Kerja Ops",
          "Ruang Kerja Project",
          "Ruang Kerja Purchasing",
          "Ruang Meeting",
        ];
        return Scaffold(
          endDrawer: DrawerStok(userData: userData),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: stokC.getStok(
                userData!.kodeCabang!,
                userData!.levelUser!.split(' ')[0],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  stokC.branchCode = userData!.kodeCabang!;
                  return PaginatedDataTable2(
                    minWidth: 1500,
                    columnSpacing: 20,
                    // columnSpacing: 100,
                    // horizontalMargin: 40,
                    smRatio: 0.9, // Rasio lebar kolom S terhadap M
                    lmRatio: 2.0,
                    // fixedLeftColumns: 1,
                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                    showFirstLastButtons: true,
                    onRowsPerPageChanged: (value) {
                      if (value != null) {
                        stokC.rowsPerPage = value;
                      }
                    },
                    renderEmptyRowsInTheEnd: false,
                    empty: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Belum ada data')],
                    ),
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
                    //         controller: stokC.searchController,
                    //         label: 'Search Data',
                    //         maxLines: 1,
                    //         onChanged: (val) {
                    //           stokC.filterDataStok(val);
                    //           // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                    //           stokC.dataSource.notifyListeners();
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ],
                    header: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 35,
                          child: CsTextField(
                            controller: stokC.searchController,
                            label: 'Search Data',
                            maxLines: 1,
                            onChanged: (val) {
                              stokC.filterDataStok(val);
                              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                              stokC.dataSource.notifyListeners();
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Visibility(
                          visible:
                              userData!.kodeCabang == "HO000" &&
                                      listDivisi.contains(
                                        userData!.levelUser!.split(' ')[0],
                                      ) &&
                                      isWideScreen
                                  ? true
                                  : false,
                          child: Obx(
                            () => Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    width: 170,
                                    child: CsDropDown(
                                      label: 'Pilih Brand',
                                      items:
                                          stokC.lstBrand
                                              .map(
                                                (data) => DropdownMenuItem(
                                                  value: data.brandCabang!,
                                                  child: Text(
                                                    data.brandCabang!,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val == 'Pilih Brand') {
                                          stokC.brand.value = "";
                                          dialogMsg(
                                            'Peringatan',
                                            'Harap pilih cabang terlebih dulu',
                                          );
                                        } else {
                                          stokC.brand.value = val;
                                          stokC.selectedBranch.value = "";
                                          // penerima = "";
                                          stokC.toBranchName.clear();
                                          stokC.selectedBranch.value = "";
                                          stokC.selectedDivisi.value = '';
                                          stokC.filterDataStok('');
                                          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                          stokC.dataSource.notifyListeners();
                                          // stokC.getCabang({
                                          //   "brand": val,
                                          // });
                                        }
                                        // stokC.catSelected.value = "";
                                      },
                                      value:
                                          // kelompok != ""
                                          //     ? stokC.assetsSelected.value = kelompok!
                                          //     :
                                          stokC.brand.value != ""
                                              ? stokC.brand.value
                                              : null,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Harap isi bagian pilihan ini';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 180,
                                    height: 35,
                                    child: FutureBuilder(
                                      future: stokC.getCabang({
                                        "brand": stokC.brand.value,
                                      }),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var dataCabang = snapshot.data;
                                          List<Map<String, String>> cabangList =
                                              [];
                                          for (var data in dataCabang!) {
                                            // Simpan data sebagai map dengan nama dan kode cabang
                                            cabangList.add({
                                              "nama": data.namaCabang ?? '',
                                              "kode": data.kodeCabang ?? '',
                                            });
                                          }
                                          return TypeAheadFormField<
                                            Map<String, String>
                                          >(
                                            autoFlipDirection: true,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                                  enabled:
                                                      stokC.brand.isEmpty
                                                          ? false
                                                          : true,
                                                  focusNode: stokC.fcsBrand,
                                                  controller:
                                                      stokC.toBranchName,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    labelText: 'Pilih cabang',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        stokC
                                                            .selectedDivisi
                                                            .value = "";
                                                        stokC.toBranchName
                                                            .clear();
                                                        stokC.fcsBrand
                                                            .requestFocus();
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .highlight_remove_rounded,
                                                      ),
                                                      splashRadius: 10,
                                                    ),
                                                  ),
                                                ),
                                            suggestionsCallback: (pattern) {
                                              return cabangList.where(
                                                (option) => option["nama"]!
                                                    .toLowerCase()
                                                    .contains(
                                                      pattern.toLowerCase(),
                                                    ),
                                              );
                                            },
                                            itemBuilder: (context, suggestion) {
                                              return ListTile(
                                                tileColor: Colors.white,
                                                title: Text(
                                                  suggestion['nama'] ?? "",
                                                ),
                                              );
                                            },
                                            onSuggestionSelected: (
                                              suggestion,
                                            ) async {
                                              stokC.filterDataStok('');
                                              stokC.toBranchName.text =
                                                  suggestion["nama"] ?? "";
                                              // stokC.toBranch.text =
                                              //     suggestion["kode"] ?? "";
                                              stokC.selectedBranch.value =
                                                  suggestion["kode"] ?? "";
                                              await stokC.getStok(
                                                stokC.selectedBranch.value,
                                                '',
                                              );
                                              stokC.dataSource
                                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                  .notifyListeners();
                                            },
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('${snapshot.error}');
                                        }
                                        return const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text('Loading...'),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    width: 240,
                                    height: 35,
                                    child: CsDropDown(
                                      label: 'Pilih Divisi/Lokasi',
                                      items:
                                          stokC.divisi
                                              .where((data) {
                                                if (stokC
                                                        .selectedBranch
                                                        .value ==
                                                    'HO000') {
                                                  return true; // tampilkan semua
                                                }
                                                return !hiddenDivisi.contains(
                                                  data,
                                                ); // hide item tertentu
                                              })
                                              .map(
                                                (data) => DropdownMenuItem(
                                                  value: data,
                                                  child: Text(data),
                                                ),
                                              )
                                              .toList(),
                                      value:
                                          stokC.selectedDivisi.isNotEmpty
                                              ? stokC.selectedDivisi.value
                                              : null,
                                      onChanged:
                                          stokC.selectedBranch.isEmpty
                                              ? null
                                              : (val) async {
                                                stokC.selectedDivisi.value =
                                                    val;
                                                stokC.isLoading.value = true;
                                                await stokC.getStok(
                                                  stokC.selectedBranch.value,
                                                  val,
                                                );
                                                //                                         // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                //                                         stokC.dataSource = StokData(dataStok: stokC.dataStok);
                                                // stokC.update();
                                              },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        CsElevatedButtonIcon(
                          icon: const Icon(Icons.print),
                          fontSize: 13,
                          onPressed: () async {
                            loadingDialog("Memuat data", "");
                            await stokC.getStok(
                              stokC.selectedBranch.isNotEmpty
                                  ? stokC.selectedBranch.value
                                  : userData!.kodeCabang!,''
                              // userData!.levelUser!.split(' ')[0],
                            );
                            Get.back();
                            stokC.printStock(
                              userData!.nama!,
                              userData!.levelUser!,
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                          label: 'Print',
                          size: const Size(60, 35),
                        ),
                        const SizedBox(width: 5),
                        CsElevatedButtonIcon(
                          onPressed: () {
                            loadingDialog("Menyiapkan data", "");
                            Future.delayed(
                              const Duration(seconds: 1),
                              () async {
                                await exportExcel();
                              },
                            );

                            Get.back();
                          },
                          icon: const Icon(Icons.sim_card_download, size: 24.0),
                          fontSize: 14,
                          label: 'Export',
                          size: const Size(105, 35),
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn2(
                        label: Text(
                          'Kode Asset',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 205,
                      ),
                      DataColumn2(
                        label: Text(
                          'Nama Asset',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 220,
                      ),
                      DataColumn2(
                        label: Text(
                          'Cabang',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 185,
                      ),
                      DataColumn2(
                        label: Text(
                          'Kategori',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 180,
                      ),
                      DataColumn2(
                        label: Text(
                          'IN',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      DataColumn2(
                        label: Text(
                          'OUT',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      DataColumn2(
                        label: Text(
                          'ADJ IN',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      DataColumn2(
                        label: Text(
                          'ADJ OUT',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 80,
                      ),
                      DataColumn2(
                        label: Text(
                          'TOTAL',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      DataColumn2(
                        label: Text(
                          'NEW',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      DataColumn2(
                        label: Text(
                          'SECOND',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 80,
                      ),
                      DataColumn2(
                        label: Text(
                          'BAD',
                          style: TextStyle(color: Colors.white),
                        ),
                        fixedWidth: 70,
                      ),
                      // DataColumn(label: Text('Action')),
                    ],
                    source: stokC.dataSource,
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
                  ? Builder(
                    builder: (context) {
                      return FloatingActionButton(
                        backgroundColor: AppColors.itemsBackground,
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: const Icon(Icons.search),
                      );
                    },
                  )
                  : null,
        );
      },
    );
  }

  exportExcel() async {
    var excel = exc.Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Menambahkan data ke sheet
    sheet.appendRow([
      'Kode Asset',
      'Nama Asset',
      'Cabang',
      'Kategori',
      'Kelompok',
      'In',
      'Out',
      'Adj In',
      'Adj Out',
      'Total',
      'New',
      'Second',
      'Bad',
    ]);
    for (var i in stokC.dataStok) {
      sheet.appendRow([
        i.barcode,
        i.assetName!.capitalize,
        i.namaCabang!.capitalize,
        i.category,
        i.group,
        i.stokIn,
        i.stokOut,
        i.adjIn,
        i.adjOut,
        i.total,
        i.neww,
        i.sec,
        i.bad,
      ]);
    }
    var fileName =
        "Stok Asset Store ${stokC.dataStok[0].namaCabang!.capitalize}";

    // Menyimpan file Excel
    excel.save(fileName: '$fileName.xlsx');
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
//                 controller: stokC.searchController,
//                 maxLines: 1,
//                 label: 'Search Data',
//                 onChanged: (val) {
//                   stokC.filterDataStok(val);
//                   // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
//                   stokC.dataSource.notifyListeners();
//                 },
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

class StokData extends DataTableSource {
  StokData({required this.dataStok});
  final RxList<Stok> dataStok;
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataStok.length) {
      return null;
    }
    final item = dataStok[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: item.barcode!));
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(
                  content: Text(
                    'Barcode ${item.barcode!} berhasil disalin ke clipboard!',
                  ),
                ),
              );
            },
            child: Text(
              item.barcode!,
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Image.network(
                  '${ServiceApi().baseUrl}${item.assetImg!}',
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Image.asset('assets/image/no-image.jpg'),
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 115,
                child: Text(
                  item.assetName!.capitalize!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(item.namaCabang!.capitalize!)),
        DataCell(Text(item.category!)),
        DataCell(
          InkWell(
            onTap: () {
              stokC.grandTotal.value = 0;
              detailStock(
                context: Get.context!,
                type: 'IN',
                itemCode: item.barcode!,
                itemName: item.assetName!,
                cabang: item.kodeCabang!,
              );
            },
            child: Text(
              item.stokIn!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              stokC.grandTotal.value = 0;
              detailStock(
                context: Get.context!,
                type: 'OUT',
                itemCode: item.barcode!,
                itemName: item.assetName!,
                cabang: item.kodeCabang!,
              );
            },
            child: Text(
              item.stokOut!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              stokC.grandTotal.value = 0;
              detailStock(
                context: Get.context!,
                type: 'ADJ IN',
                itemCode: item.barcode!,
                itemName: item.assetName!,
                cabang: item.kodeCabang!,
              );
            },
            child: Text(
              item.adjIn!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              stokC.grandTotal.value = 0;
              detailStock(
                context: Get.context!,
                type: 'ADJ OUT',
                itemCode: item.barcode!,
                itemName: item.assetName!,
                cabang: item.kodeCabang!,
              );
            },
            child: Text(
              item.adjOut!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              stokC.grandTotal.value = 0;
              detailStock(
                context: Get.context!,
                type: 'SUMMARY', // <-- PENTING: gunakan 'SUMMARY'
                itemCode: item.barcode!,
                itemName: item.assetName!,
                cabang: item.kodeCabang!,
              );
            },
            child: Text(
              item.total!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        DataCell(
          Text(
            item.neww!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataCell(
          Text(
            item.sec!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        DataCell(
          Text(
            item.bad!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),

        // DataCell(Row(
        //   children: [
        //     IconButton(
        //       tooltip: 'Edit',
        //       onPressed: () {
        //         // addEditAssets(Get.context!, item.id, item.assetName,
        //         //     item.category, item.price, item.status);
        //       },
        //       icon: const Icon(
        //         Icons.edit,
        //         size: 20,
        //         color: Colors.green,
        //       ),
        //       splashRadius: 10,
        //     ),
        //     IconButton(
        //       tooltip: 'Hapus',
        //       onPressed: () {
        //         // stokC.deleteAssetCategories(item.id!);
        //       },
        //       icon: const Icon(
        //         Icons.delete,
        //         size: 20,
        //         color: Colors.red,
        //       ),
        //       splashRadius: 10,
        //     ),
        //   ],
        // )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataStok.length;

  @override
  int get selectedRowCount => 0;
}
