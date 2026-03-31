import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
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
                DataColumn2(
                  label: Text(
                    status == 'IN'
                        ? 'ID IN'
                        : status == 'SUMMARY'
                        ? 'ID IN/OUT'
                        : status == 'ADJ IN'
                        ? 'ID ADJ IN'
                        : status == 'ADJ OUT'
                        ? 'ID ADJ OUT'
                        : 'ID OUT',
                  ),
                  fixedWidth: 195,
                ),
                // if (!['ADJ IN', 'ADJ OUT'].contains(status))
                DataColumn2(
                  label: Text(
                    status == 'IN'
                        ? 'Pengirim'
                        : status == 'SUMMARY'
                        ? 'Cabang'
                        : 'Penerima',
                  ),
                  fixedWidth: 160,
                ),
                const DataColumn2(label: Text('Nama Asset'), fixedWidth: 200),
                const DataColumn2(label: Text('Jumlah'), fixedWidth: 100),
                const DataColumn2(label: Text('Tanggal'), fixedWidth: 110),
                const DataColumn2(label: Text('Waktu'), fixedWidth: 100),
                const DataColumn2(label: Text('Dibuat Oleh'), fixedWidth: 100),
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
      if (item.type == 'stock_in' || item.type == 'adj_in') {
        rowColor = Colors.green[100];
      } else {
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
              InkWell(
                onTap: () => snackbarCopy(item: item.id!),
                child: Text(item.id!, style: const TextStyle(color: Colors.blue),),
              ),
            ],
          ),
        ),
        DataCell(Text(item.cabang!.capitalize!)),
        DataCell(Text(item.assetName!.capitalize!)),
        DataCell(Text(item.qty!)),
        DataCell(
          Text(
            '${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(item.createdAt!))}',
          ),
        ),
        DataCell(
          Text(DateFormat('HH:mm:ss').format(DateTime.parse(item.createdAt!))),
        ),
        DataCell(Text(item.createdBy!.capitalize!)),
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
