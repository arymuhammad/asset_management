import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../../data/shared/text_field.dart';
import 'add_edit_stok_out.dart';

class DatatableStokOut extends StatelessWidget {
  const DatatableStokOut({
    super.key,
    required this.stokOutData,
    required this.statusData,
  });
  final String statusData;
  final RxList<DetailBarangMasukKeluar> stokOutData;

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
                statusData == "OPEN" || statusData == ""
                    ? const Text('Action')
                    : Container(),
            fixedWidth: 120,
          ),
        ],
        rows:
            // stokOutData.isNotEmpty
            //     ?
            stokOutData.map((e) {

              RxList<DetailBarangMasukKeluar> tempData =
                  stokOutC.tempScanData.isNotEmpty
                      ? stokOutC.tempScanData
                      : stokOutC.detailStokOut;

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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        initialValue: stokOutData.isNotEmpty ? e.qtyOut : "",
                        onChanged: (val) {
                          // tempData = stokOutC.tempScanData.
                          // int index = stokOutC.detailStokOut.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            if (val.isEmpty) {
                              tempData[index].qtyOut = '0';
                            } else {
                              tempData[index].qtyOut = val;
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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        label: 'Good',
                        initialValue: stokOutData.isNotEmpty ? e.good : "",
                        onChanged: (val) {
                          // int index = stokOutC.detailStokOut.indexWhere(
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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        label: 'Bad',
                        initialValue: stokOutData.isNotEmpty ? e.bad : "",
                        onChanged: (val) {
                          // int index = stokOutC.detailStokOut.indexWhere(
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
                    statusData == "OPEN" || statusData == ""
                        ? IconButton(
                          onPressed: () {
                            stokOutData.remove(e);
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

        // : stokOutC.tempScanData
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
        //                     statusData == "OPEN" || statusData == ""
        //                         ? true
        //                         : false,
        //                 onChanged: (val) {
        //                   int index = stokOutC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokOutC.tempScanData[index].qtyOut = '0';
        //                     } else {
        //                       stokOutC.tempScanData[index].qtyOut = val;
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
        //                     statusData == "OPEN" || statusData == ""
        //                         ? true
        //                         : false,
        //                 label: 'Good',
        //                 onChanged: (val) {
        //                   int index = stokOutC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokOutC.tempScanData[index].good = '0';
        //                     } else {
        //                       stokOutC.tempScanData[index].good = val;
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
        //                     statusData == "OPEN" || statusData == ""
        //                         ? true
        //                         : false,
        //                 label: 'Bad',
        //                 onChanged: (val) {
        //                   int index = stokOutC.tempScanData.indexWhere(
        //                     (data) =>
        //                         data.assetCode == e.value.assetCode,
        //                   );
        //                   if (index != -1) {
        //                     if (val.isEmpty) {
        //                       stokOutC.tempScanData[index].bad = '0';
        //                     } else {
        //                       stokOutC.tempScanData[index].bad = val;
        //                     }
        //                   }
        //                 },
        //               ),
        //             ),
        //           ),
        //           DataCell(
        //             statusData == "OPEN" || statusData == ""
        //                 ? IconButton(
        //                   onPressed: () {
        //                     stokOutC.tempScanData.removeAt(e.key);
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
        //     .toList(),
      ),
    );
  }
}
