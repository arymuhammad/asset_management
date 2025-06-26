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
        minWidth: 1000,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        fixedLeftColumns: 1,
        columns: [
          const DataColumn2(label: Text('Asset Name'), fixedWidth: 190),
          const DataColumn2(label: Text('Asset Code'), fixedWidth: 200),
          const DataColumn2(label: Text('Qty Total'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty Good'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty Bad'), fixedWidth: 120),
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
                        initialValue: stokInData.isNotEmpty ? e.qtyIn : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            if (val.isEmpty) {
                             tempData[index].qtyIn = '0';
                            } else {
                             tempData[index].qtyIn = val;
                            }
                            // print(index);
                          }
                        },
                        label: 'Total',
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
                        label: 'Good',
                        initialValue: stokInData.isNotEmpty ? e.good : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            if (val.isEmpty) {
                             tempData[index].good = '0';
                            } else {
                             tempData[index].good = val;
                            }
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
                        initialValue: stokInData.isNotEmpty ? e.bad : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            if (val.isEmpty) {
                             tempData[index].bad = '0';
                            } else {
                             tempData[index].bad = val;
                            }
                          }
                        },
                      ),
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
