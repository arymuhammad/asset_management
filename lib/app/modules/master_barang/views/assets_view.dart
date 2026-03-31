import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/format_waktu.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/dashboard/views/widget/drawer_menu.dart';
import 'package:assets_management/app/modules/master_barang/controllers/master_barang_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/currency_format.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/assets_model.dart';
import '../../../data/models/login_model.dart';
import 'widget/add_edit_assets.dart';

class AssetsView extends GetView {
  AssetsView({super.key, this.userData}) {
    // dataSource = AssetData(dataAsset: assetC.dataAssetsFiltered);
  }

  // late final AssetData dataSource;
  final Data? userData;
  final assetC = Get.put(MasterBarangController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder(
              future: assetC.getAssets(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  assetC.dataSource = AssetData(
                    dataAsset: assetC.dataAssetsFiltered,
                    screenWidth: isWideScreen,
                    userData: userData,
                  );
                  return Obx(
                    () => Stack(
                      children: [
                        PaginatedDataTable2(
                          // controller: ,
                          minWidth: 1700,
                          columnSpacing: 20,
                          // isHorizontalScrollBarVisible: true,
                          // isVerticalScrollBarVisible: true,
                          // fixedLeftColumns: 1,
                          // columnSpacing: 100,
                          // horizontalMargin: 40,
                          smRatio: 0.9, // Rasio lebar kolom S terhadap M
                          lmRatio: 2.0,
                          rowsPerPage: assetC.rowsPerPage,
                          availableRowsPerPage: const [5, 10, 20, 50, 100],
                          onRowsPerPageChanged: (value) {
                            if (value != null) {
                              assetC.changeRowsPerPage(value);
                            }
                          },
                          renderEmptyRowsInTheEnd: false,
                          showFirstLastButtons: true,
                          empty: const Text('Belum ada data'),
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
                                  controller: assetC.searchAssetController,
                                  label: 'Search Data',
                                  maxLines: 1,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      assetC.searchAssetController.clear();
                                      assetC.filterDataAsset('');
                                      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                      assetC.dataSource.notifyListeners();
                                    },
                                    icon: const Icon(Icons.clear, size: 20),
                                    splashRadius: 10,
                                  ),
                                  onChanged: (val) {
                                    assetC.filterDataAsset(val);
                                    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                    assetC.dataSource.notifyListeners();
                                  },
                                ),
                              ),
                            ),
                            IconButton.filled(
                              color: mainColor,
                              icon: const Icon(
                                HugeIcons.strokeRoundedAddCircle,
                              ),
                              // fontSize: 16,
                              onPressed: () {
                                // assetC.getAssets();
                                addEditAssets(
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
                                );
                                // assetC.isLoading.value = false;
                              },
                              splashRadius: 25,
                              tooltip: 'Add',
                              // label: '',
                            ),
                          ],
                          header: const Row(
                            children: [
                              Text('Assets', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                          columns: const [
                            DataColumn2(
                              label: Text(
                                'Kode Asset',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 212,
                            ),
                            DataColumn2(
                              label: Center(
                                child: Text(
                                  'Nama Asset',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              fixedWidth: 220,
                            ),
                            DataColumn2(
                              label: Text(
                                'Kelompok',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 120,
                            ),
                            DataColumn2(
                              label: Text(
                                'Kategori',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 160,
                            ),
                            DataColumn2(
                              label: Text(
                                'Satuan',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 80,
                            ),
                            DataColumn2(
                              label: Text(
                                'Tanggal Beli',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 110,
                            ),
                            DataColumn2(
                              label: Text(
                                'Harga/Nilai',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 130,
                            ),
                            DataColumn2(
                              label: Text(
                                'Harga/Nilai Saat Ini',
                                style: TextStyle(color: Colors.white),
                              ),
                              fixedWidth: 145,
                            ),
                            DataColumn2(
                              label: Center(
                                child: Text(
                                  'Action',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              fixedWidth: 130,
                            ),
                          ],
                          source: assetC.dataSource,
                        ),
                        if (assetC.isChangingRowPerPage.value)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black45,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                controller: assetC.searchAssetController,
                maxLines: 1,
                label: 'Search Data',
                onChanged: (val) {
                  assetC.filterDataAsset(val);
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  assetC.dataSource.notifyListeners();
                },
              ),
            ),
          );
        },
      );
    },
  );
}

class AssetData extends DataTableSource {
  AssetData({
    required this.dataAsset,
    required bool screenWidth,
    this.userData,
  });
  final RxList<AssetsModel> dataAsset;
  final bool isWideScreen = Get.width >= 800;
  final Data? userData;

  // updateData(RxList<AssetsModel> newUsers) {
  //   dataAsset.value = newUsers;
  //   notifyListeners(); // Memberi tahu PaginatedDataTable bahwa data berubah
  // }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= dataAsset.length) {
      return null;
    }
    final item = dataAsset[index];

    int yearDifference(DateTime from, DateTime to) {
      int years = to.year - from.year;
      // Kurangi 1 tahun jika bulan atau hari to lebih kecil dari from (belum genap tahun)
      if (to.month < from.month ||
          (to.month == from.month && to.day < from.day)) {
        years--;
      }
      return years.abs(); // jika ingin hasil absolut (positif)
    }

    var dateA = DateTime.parse(item.purchaseDate!);
    var dateB = DateTime.now();

    var differenceDate = yearDifference(dateA, dateB);
    var differencePrice = int.tryParse(item.price!)! / differenceDate;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Row(
            children: [
              Text(item.assetsCode!),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: item.assetsCode!),
                  );
                  ScaffoldMessenger.of(Get.context!).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Barcode ${item.assetsCode!} berhasil disalin ke clipboard!',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  HugeIcons.strokeRoundedCopy01,
                  color: Colors.blue[400],
                ),
                splashRadius: 30,
                tooltip: 'copy to clipboard',
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: WidgetZoom(
                  heroAnimationTag: 'product${item.assetName}',
                  zoomWidget: ClipRect(
                    child: Image.network(
                      '${ServiceApi().baseUrl}${item.image!}',
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Image.asset('assets/image/no-image.jpg'),
                    ),
                  ),
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
        DataCell(Text(item.group!)),
        DataCell(Text(item.categoryName!)),
        DataCell(Text(item.satuan!)),
        DataCell(
          Text(
            FormatWaktu.formatTglBlnThn(
              tanggal: DateTime.parse(item.purchaseDate!),
            ),
          ),
        ),
        DataCell(
          Text(
            CurrencyFormat.convertToIdr(
              item.price != '' ? int.parse(item.price!) : 0,
              0,
            ),
          ),
        ),
        DataCell(
          Text(
            dateA.year == dateB.year
                ? CurrencyFormat.convertToIdr(
                  item.price != '' ? int.parse(item.price!) : 0,
                  0,
                )
                : CurrencyFormat.convertToIdr(
                  differencePrice != 0 ? differencePrice : 0,
                  0,
                ),
          ),
        ),

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
    addEditAssets(
      Get.context!,
      item.id,
      item.assetName,
      item.serialNo,
      item.categoryId,
      item.categoryName,
      item.price,
      item.purchaseDate,
      item.kelompok,
      item.image!,
      item.satuan,
    );
  }
},
                icon: const Icon(Icons.edit, size: 20, color: Colors.green),
                splashRadius: 10,
              ),
              IconButton(
                onPressed: () {
                  assetC.printDocument(item.assetsCode, item.assetName);
                },
                icon: Icon(
                  HugeIcons.strokeRoundedPrinter,
                  color: Colors.blue[400],
                ),
                splashRadius: 10,
                tooltip: 'print barcode',
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
      () => assetC.deleteAsset(item.id!, item.image!),
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
  int get rowCount => dataAsset.length;

  @override
  int get selectedRowCount => 0;
}
