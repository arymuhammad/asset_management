import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/format_waktu.dart';
import 'package:assets_management/app/data/models/stock_detail_model.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/barang_masuk/views/widget/add_edit_stok_in.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class DataTabelStock extends StatelessWidget {
  DataTabelStock({super.key, this.status, this.itemName}) {
    dataDetail = DetailStokData(
      detailDataStok: stokC.detailDataFiltered,
      status: status,
    );
  }
  late final DetailStokData dataDetail;
  final String? status;
  final String? itemName;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Expanded(
            child: PaginatedDataTable2(
              headingRowHeight: 40,
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.grey.shade300),
              // ),
              headingRowDecoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.grey.shade300),
              ),

              minWidth: 1300,
              columnSpacing: 20,
              smRatio: 0.9, // Rasio lebar kolom S terhadap M
              lmRatio: 2.0,
              // fixedLeftColumns: 1,
              availableRowsPerPage: const [5, 10, 20, 50, 100],
              showFirstLastButtons: true,
              renderEmptyRowsInTheEnd: false,
              empty: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Belum ada data')],
              ),
              // fixedLeftColumns: 1,
              header: Text(itemName!, style: const TextStyle(fontSize: 14)),
              actions: [
                SizedBox(
                  width: 150,
                  height: 35,
                  child: CsTextField(
                    controller: stokC.searchDetail,
                    label: 'Search',
                    maxLines: 1,
                    onChanged: (val) {
                      stokC.filterDetailStok(val);
                      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                      dataDetail.notifyListeners();
                    },
                  ),
                ),
              ],
              columns: [
                const DataColumn2(label: Text('ID'), fixedWidth: 186),
                DataColumn2(
                  label: Text(
                    status == 'IN'
                        ? 'Pengirim'
                        : status == 'SUMMARY'
                        ? 'Cabang'
                        : 'Penerima',
                  ),
                  fixedWidth: 150,
                ),
                const DataColumn2(label: Text('Nama Asset'), fixedWidth: 200),
                const DataColumn2(label: Text('Quantity'), fixedWidth: 100),
                const DataColumn2(label: Text('Tanggal'), fixedWidth: 100),
                const DataColumn2(label: Text('Waktu'), fixedWidth: 100),
              ],
              source: dataDetail,
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: status == 'SUMMARY' ? true : false,
                  child: Row(
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'IN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: red,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'OUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Total Quantity: ${stokC.grandTotal.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailStokData extends DataTableSource {
  DetailStokData({required this.detailDataStok, required this.status});
  final RxList<StockDetail> detailDataStok;
  final String? status;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);

    if (index >= detailDataStok.length) {
      return null;
    }
    final item = detailDataStok[index];
    // Tentukan warna baris berdasarkan status dan tipe stock
    Color? rowColor;
    if (status == 'SUMMARY') {
      if (item.type == 'stock_in') {
        rowColor = Colors.green[100];
      } else if (item.type == 'stock_out') {
        rowColor = Colors.red[100];
      }
    }
    return DataRow.byIndex(
      index: index,
      color: rowColor != null ? WidgetStateProperty.all(rowColor) : null,
      cells: [
        DataCell(
          Row(
            children: [
              Text(item.id!),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: item.id!));
                  Get.snackbar(
                    'Copied',
                    'Barcode ${item.id!} berhasil disalin ke clipboard!',
                    snackPosition: SnackPosition.BOTTOM,
                    maxWidth: 400, // Batasi lebar maksimal snackbar
                    margin: const EdgeInsets.only(
                      right: 20,
                      bottom: 20,
                    ), // Margin kanan dan bawah
                    borderRadius: 8,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    snackStyle:
                        SnackStyle
                            .FLOATING, // Floating agar tidak melebar penuh
                    animationDuration: const Duration(milliseconds: 300),
                    duration: const Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(Get.context!).showSnackBar(
                    SnackBar(
                      elevation: 20,
                      content: Text(
                        'Barcode ${item.id!} berhasil disalin ke clipboard!',
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
        DataCell(Text(item.cabang!)),
        DataCell(Text(item.assetName!)),
        DataCell(Text(item.qty!)),
        DataCell(
          Text(
            '${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(item.createdAt!))}',
          ),
        ),
        DataCell(
          Text(DateFormat('HH:mm:ss').format(DateTime.parse(item.createdAt!))),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => detailDataStok.length;

  @override
  int get selectedRowCount => 0;
}
