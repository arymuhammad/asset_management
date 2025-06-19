import 'package:assets_management/app/data/models/login_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/shared/text_field.dart';
import '../controllers/stok_controller.dart';

class StockView extends GetView {
  StockView({super.key, this.userData}) {
    dataSource = StokData(dataStok: stokC.dataStokFiltered);
  }

  late final StokData dataSource;
  final Data? userData;
  final stokC = Get.put(StokController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder(
          future: stokC.getStok(userData!.kodeCabang!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PaginatedDataTable2(
                minWidth: 1300,
                columnSpacing: 20,
                isHorizontalScrollBarVisible: true,
                isVerticalScrollBarVisible: true,
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
                empty: const Text('Belum ada data'),
                actions: [
                  SizedBox(
                    width: 150,
                    height: 35,
                    child: CsTextField(
                      label: 'Search Data',
                      onChanged: (val) {
                        stokC.filterDataStok(val);
                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                        dataSource.notifyListeners();
                      },
                    ),
                  ),
                ],
                header: const Text('STOCK'),
                columns: const [
                  DataColumn2(label: Text('Kode Asset'), fixedWidth: 205),
                  DataColumn2(label: Text('Nama Asset'), fixedWidth: 185),
                  DataColumn2(label: Text('Cabang'), fixedWidth: 185),
                  DataColumn2(label: Text('Kategori'), fixedWidth: 180),
                  DataColumn2(label: Text('IN'), fixedWidth: 70),
                  DataColumn2(label: Text('OUT'), fixedWidth: 70),
                  DataColumn2(label: Text('TOTAL'), fixedWidth: 70),
                  DataColumn2(label: Text('GOOD'), fixedWidth: 70),
                  DataColumn2(label: Text('BAD'), fixedWidth: 70),
                  // DataColumn(label: Text('Action')),
                ],
                source: dataSource,
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
    );
  }
}

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
          Row(
            children: [
              Text(item.barcode!),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: item.barcode!));
                  ScaffoldMessenger.of(Get.context!).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Barcode ${item.barcode!} berhasil disalin ke clipboard!',
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
        DataCell(Text(item.assetName!)),
        DataCell(Text(item.cabang!)),
        DataCell(Text(item.category!)),
        DataCell(
          CsContainerColor(color: Colors.greenAccent[700]!,
            child: Text(item.stokIn!, style: const TextStyle(color: Colors.white)),
          ),
        ),
        DataCell(
          CsContainerColor(
            color: Colors.redAccent[700]!,
            child: Text(item.stokOut!, style: const TextStyle(color: Colors.white)),
          ),
        ),
        DataCell(CsContainerColor(
          color: Colors.blueAccent[700]!,
          child: Text('${int.parse(item.stokIn!) - int.parse(item.stokOut!)}', style: const TextStyle(color: Colors.white)))),
        DataCell(Text(item.good!)),
        DataCell(Text(item.bad!)),

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

class CsContainerColor extends StatelessWidget {
  const CsContainerColor({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8.0),
    this.color = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        // vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
