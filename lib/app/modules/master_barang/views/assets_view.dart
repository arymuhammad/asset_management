import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/controllers/master_barang_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../data/helper/const.dart';
import '../../../data/helper/currency_format.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/assets_model.dart';
import 'widget/add_edit_assets.dart';

class AssetsView extends GetView {
  AssetsView({super.key}) {
    // dataSource = AssetData(dataAsset: assetC.dataAssetsFiltered);
  }

  // late final AssetData dataSource;
  final assetC = Get.put(MasterBarangController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;

            return FutureBuilder(
              future: assetC.getAssets(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  assetC.dataSource = AssetData(
                    dataAsset: assetC.dataAssetsFiltered,
                    screenWidth: isWideScreen,
                  );
                  return PaginatedDataTable2(
                    // controller: ,
                    minWidth: 1300,
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
                        assetC.rowsPerPage = value;
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
                          maxLines: 1,
                          onChanged: (val) {
                            assetC.filterDataAsset(val);
                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                            assetC.dataSource.notifyListeners();
                          },
                        ),
                      ),
                      IconButton.filled(
                        color: mainColor,
                        icon: const Icon(HugeIcons.strokeRoundedAddCircle),
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
                          );
                          // assetC.isLoading.value = false;
                        },
                        splashRadius: 25,
                        tooltip: 'Add',
                        // label: '',
                      ),
                    ],
                    header: const Row(children: [Text('ASSETS')]),
                    columns: const [
                      DataColumn2(label: Text('Kode Asset'), fixedWidth: 210),
                      DataColumn2(label: Text('Nama Asset'), fixedWidth: 350),
                      DataColumn2(label: Text('Kategori'), fixedWidth: 160),
                      DataColumn2(label: Text('Harga/Nilai'), fixedWidth: 100),
                      DataColumn2(label: Text('Satuan'), fixedWidth: 100),
                      DataColumn2(label: Text('Action'), fixedWidth: 130),
                    ],
                    source: assetC.dataSource,
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

class AssetData extends DataTableSource {
  AssetData({required this.dataAsset, required bool screenWidth});
  final RxList<AssetsModel> dataAsset;
  final bool isWideScreen = Get.width >= 800;

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
              Text(item.assetName!),
            ],
          ),
        ),
        DataCell(Text(item.categoryName!)),
        DataCell(Text(CurrencyFormat.convertToIdr(int.parse(item.price!), 0))),
        DataCell(Text(item.satuan!)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () {
                  addEditAssets(
                    Get.context!,
                    item.id,
                    item.assetName,
                    item.categoryId,
                    item.categoryName,
                    item.price,
                    item.kelompok,
                    item.image!,
                    item.satuan,
                  );
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
                  promptDialog(
                    Get.context!,
                    'HAPUS',
                    'Anda yakin ingin menghapus data ini?',
                    () => assetC.deleteAsset(item.id!, item.image!),
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
  int get rowCount => dataAsset.length;

  @override
  int get selectedRowCount => 0;
}
