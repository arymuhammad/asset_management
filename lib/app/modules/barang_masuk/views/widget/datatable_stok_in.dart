import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../../data/shared/text_field.dart';
import 'add_edit_stok_in.dart';

class DatatableStokIn extends StatelessWidget {
  const DatatableStokIn({
    super.key,
    required this.statusData,
    required this.pengirim,
    required this.penerima,
    required this.stokInData,
  });

  final String statusData;
  final String pengirim;
  final String penerima;
  final RxList<DetailBarangMasukKeluar> stokInData;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DataTable2(
        empty: const Center(child: Text('Belum ada data')),
        lmRatio: 1,
        minWidth: 1100,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        fixedLeftColumns: 1,
        columns: [
          const DataColumn2(label: Text('Asset Name'), fixedWidth: 190),
          const DataColumn2(label: Text('Asset Code'), fixedWidth: 210),
          const DataColumn2(label: Text('Qty New'), fixedWidth: 115),
          const DataColumn2(label: Text('Qty Sec'), fixedWidth: 110),
          const DataColumn2(label: Text('Qty Bad'), fixedWidth: 110),
          const DataColumn2(label: Text('Qty Total'), fixedWidth: 120),
          DataColumn2(
            label:
                statusData == "OPEN" && pengirim == penerima || statusData == ""
                    ? const Text('Action')
                    : Container(),
            fixedWidth: 120,
          ),
        ],
        rows:
            // stokInData!.isNotEmpty
            //     ?
            stokInData.map((e) {
              RxList<DetailBarangMasukKeluar> tempData =
                  stokInC.tempScanData.isNotEmpty
                      ? stokInC.tempScanData
                      : stokInC.detailStokIn;

              int index = tempData.indexWhere(
                (data) => data.assetCode == e.assetCode,
              );

              return DataRow(
                cells: [
                  DataCell(Text(e.assetName!)),
                  DataCell(Text(e.assetCode!)),
                  DataCell(
                    SizedBox(
                      height: 37,
                      child: CsTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        enabled:
                            // statusData == "OPEN" ||
                            statusData == "OPEN" && pengirim == penerima ||
                                    statusData == ""
                                ? true
                                : false,
                        label: 'New',
                        initialValue: stokInData.isNotEmpty ? e.neww.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].neww.value =
                                val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].neww.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].sec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].bad.value) ?? 0;
                            tempData[index].qtyIn.value =
                                (newwNum + secNum + badNum).toString();
                            stokInC.update();
                            // Update UI sesuai kebutuhan, misal dengan setState atau GetX update
                          }
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      height: 37,
                      child: CsTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        enabled:
                            // statusData == "OPEN" ||
                            statusData == "OPEN" && pengirim == penerima ||
                                    statusData == ""
                                ? true
                                : false,
                        label: 'Second',
                        initialValue: stokInData.isNotEmpty ? e.sec.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].sec.value = val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].neww.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].sec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].bad.value) ?? 0;
                            tempData[index].qtyIn.value =
                                (newwNum + secNum + badNum).toString();
                            stokInC.update();
                            // Update UI sesuai kebutuhan, misal dengan setState atau GetX update
                          }
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      height: 37,
                      child: CsTextField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        enabled:
                            // statusData == "OPEN" ||
                            statusData == "OPEN" && pengirim == penerima ||
                                    statusData == ""
                                ? true
                                : false,
                        label: 'Bad',
                        initialValue: stokInData.isNotEmpty ? e.bad.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].bad.value = val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].neww.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].sec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].bad.value) ?? 0;
                            tempData[index].qtyIn.value =
                                (newwNum + secNum + badNum).toString();
                            stokInC.update();
                            // Update UI sesuai kebutuhan, misal dengan setState atau GetX update
                          }
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      height: 37,
                      child: Center(child: Text(tempData[index].qtyIn.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                    ),
                  ),
                  DataCell(
                    statusData == "OPEN" && pengirim == penerima ||
                            statusData == ""
                        ? IconButton(
                          onPressed: () {
                            stokInData.remove(e);
                          },
                          icon: Icon(
                            Icons.highlight_remove_rounded,
                            color: Colors.red[700],
                          ),
                        )
                        : Container(),
                  ),
                ],
              );
            }).toList(),
        // : stokInC.tempScanData
        //     .asMap()
        //     .entries
        //     .map(
        //       (e) => DataRow(
        //         cells: [
        //           DataCell(Text(e.value.assetName)),
        //           DataCell(Text(e.value.assetCode)),
        //           DataCell(
        //             SizedBox(
        //               height: 37,
        //               child: CsTextField(
        //                 inputFormatters: [
        //                   FilteringTextInputFormatter.digitsOnly,
        //                 ],
        //                 enabled:
        //                     statusData == "OPEN" ||
        //                             statusData == "OPEN" &&
        //                                 pengirim == penerima ||
        //                             statusData == ""
        //                         ? true
        //                         : false,
        //                 onChanged: (val) {
        //                   int index = stokInC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokInC.tempScanData[index].qtyIn = '0';
        //                     } else {
        //                       stokInC.tempScanData[index].qtyIn = val;
        //                     }
        //                     // print(index);
        //                   }
        //                 },
        //                 label: 'Total',
        //               ),
        //             ),
        //           ),
        //           DataCell(
        //             SizedBox(
        //               height: 37,
        //               child: CsTextField(
        //                 inputFormatters: [
        //                   FilteringTextInputFormatter.digitsOnly,
        //                 ],
        //                 enabled:
        //                     statusData == "OPEN" ||
        //                             statusData == "OPEN" &&
        //                                 pengirim == penerima ||
        //                             statusData == ""
        //                         ? true
        //                         : false,
        //                 label: 'Good',
        //                 onChanged: (val) {
        //                   int index = stokInC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokInC.tempScanData[index].good = '0';
        //                     } else {
        //                       stokInC.tempScanData[index].good = val;
        //                     }
        //                   }
        //                 },
        //               ),
        //             ),
        //           ),
        //           DataCell(
        //             SizedBox(
        //               height: 37,
        //               child: CsTextField(
        //                 inputFormatters: [
        //                   FilteringTextInputFormatter.digitsOnly,
        //                 ],
        //                 enabled:
        //                     statusData == "OPEN" ||
        //                             statusData == "OPEN" &&
        //                                 pengirim == penerima ||
        //                             statusData == ""
        //                         ? true
        //                         : false,
        //                 label: 'Bad',
        //                 onChanged: (val) {
        //                   int index = stokInC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokInC.tempScanData[index].bad = '0';
        //                     } else {
        //                       stokInC.tempScanData[index].bad = val;
        //                     }
        //                   }
        //                 },
        //               ),
        //             ),
        //           ),
        //           DataCell(
        //             statusData == "OPEN" && pengirim == penerima ||
        //                     statusData == ""
        //                 ? IconButton(
        //                   onPressed: () {
        //                     stokInC.tempScanData.removeAt(e.key);
        //                   },
        //                   icon: Icon(
        //                     Icons.highlight_remove_rounded,
        //                     color: Colors.red[700],
        //                   ),
        //                 )
        //                 : Container(),
        //           ),
        //         ],
        //       ),
        //     )
        //     .toList()
        //     .reversed
        //     .toList(),
      ),
    );
  }
}
