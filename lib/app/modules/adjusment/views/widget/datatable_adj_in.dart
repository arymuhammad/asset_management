import 'package:assets_management/app/data/models/detail_adj_model.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/adjusment/views/widget/add_edit_adj_in.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DatatableAdj extends StatelessWidget {
  const DatatableAdj({
    super.key,
    required this.statusData,
    // required this.pengirim,
    // required this.penerima,
    required this.adjData,
  });

  final String statusData;
  // final String pengirim;
  // final String penerima;
  final RxList<DetailAdjModel> adjData;

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
                statusData == "OPEN" || statusData == ""
                    ? const Text('Action')
                    : Container(),
            fixedWidth: 120,
          ),
        ],
        rows:
            // stokInData!.isNotEmpty
            //     ?
            adjData.map((e) {
              RxList<DetailAdjModel> tempData =
                  adjC.tempScanData.isNotEmpty
                      ? adjC.tempScanData
                      : adjC.detailAdjIn.isNotEmpty
                      ? adjC.detailAdjIn
                      : adjC.detailAdjOut;

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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        label: 'New',
                        initialValue:
                            adjData.isNotEmpty ? e.qtyNew.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].qtyNew.value =
                                val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].qtyNew.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].qtySec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].qtyBad.value) ?? 0;
                            tempData[index].qtyAdj.value =
                                (newwNum + secNum + badNum).toString();
                            adjC.update();
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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        label: 'Second',
                        initialValue:
                            adjData.isNotEmpty ? e.qtySec.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].qtySec.value =
                                val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].qtyNew.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].qtySec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].qtyBad.value) ?? 0;
                            tempData[index].qtyAdj.value =
                                (newwNum + secNum + badNum).toString();
                            adjC.update();
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
                            statusData == "OPEN" || statusData == ""
                                ? true
                                : false,
                        label: 'Bad',
                        initialValue:
                            adjData.isNotEmpty ? e.qtyBad.value : "",
                        onChanged: (val) {
                          // int index = stokInC.detailStokIn.indexWhere(
                          //   (data) => data.assetCode == e.assetCode,
                          // );
                          if (index != -1) {
                            tempData[index].qtyBad.value =
                                val.isEmpty ? '0' : val;
                            // Update qtyIn langsung pada baris ini
                            num newwNum =
                                num.tryParse(tempData[index].qtyNew.value) ?? 0;
                            num secNum =
                                num.tryParse(tempData[index].qtySec.value) ?? 0;
                            num badNum =
                                num.tryParse(tempData[index].qtyBad.value) ?? 0;
                            tempData[index].qtyAdj.value =
                                (newwNum + secNum + badNum).toString();
                            adjC.update();
                            // Update UI sesuai kebutuhan, misal dengan setState atau GetX update
                          }
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      height: 37,
                      child: Center(
                        child: Text(
                          tempData[index].qtyAdj.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    statusData == "OPEN" || statusData == ""
                        ? IconButton(
                          onPressed: () {
                            adjData.remove(e);
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
