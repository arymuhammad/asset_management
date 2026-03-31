import 'package:assets_management/app/data/models/so_detail_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/shared/text_field.dart';
import 'add_edit_stock_opname.dart';

class DataTableSo extends StatelessWidget {
  const DataTableSo({
    super.key,
    required this.soData,
    required this.statusData,
  });
  final String statusData;
  final RxList<SoDetailModel> soData;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DataTable2(
        empty: const Center(child: Text('Belum ada data')),
        lmRatio: 1,
        minWidth: 1200,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        fixedLeftColumns: 1,
        columns: [
          const DataColumn2(label: Text('Asset Name'), fixedWidth: 190),
          const DataColumn2(label: Text('Asset Code'), fixedWidth: 210),
          const DataColumn2(label: Text('SOH'), fixedWidth: 100),
          const DataColumn2(label: Text('Qty New'), fixedWidth: 100),
          const DataColumn2(label: Text('Qty Sec'), fixedWidth: 100),
          const DataColumn2(label: Text('Qty Bad'), fixedWidth: 100),
          // const DataColumn2(label: Text('Qty Sec'), fixedWidth: 120),
          // const DataColumn2(label: Text('Qty Bad'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty Diff'), fixedWidth: 120),
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
            soData
                .map((e) {
                  RxList<SoDetailModel> tempData =
                      stokOptC.tempScanData.isNotEmpty
                          ? stokOptC.tempScanData
                          : stokOptC.detailSo;

                  int index = tempData.indexWhere(
                    (data) => data.assetCode == e.assetCode,
                  );

                  // JIKA TIDAK DITEMUKAN, SKIP ATAU TAMBAH ITEM BARU
                  if (index == -1) {
                    // Opsional: tambah ke tempData jika belum ada
                    // tempData.add(e); index = tempData.length - 1;
                    return DataRow(
                      cells: [
                        DataCell(Text(e.assetName ?? '')),
                        DataCell(Text(e.assetCode ?? '')),
                        DataCell(Obx(() => Text(e.initStock.value))),
                        const DataCell(
                          Center(child: Text('Item tidak ditemukan')),
                        ),
                        DataCell(Container()),
                        DataCell(Container()),
                      ],
                    );
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(e.assetName ?? '')),
                      DataCell(Text(e.assetCode ?? '')),
                      DataCell(Text(e.initStock.value)),

                      // Qty New - dengan validasi index
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: CsTextField(
                            maxLines: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: statusData == "OPEN" || statusData == "",
                            label: 'Qty',
                            initialValue: e.qtyNew.value,
                            onChanged: (val) {
                              if (index != -1) {
                                // TAMBAHKAN PENGECEKAN INI
                                tempData[index].qtyNew.value =
                                    val.isEmpty ? '0' : val;
                                _updateQtyAndValidate(
                                  tempData,
                                  index,
                                  e,
                                  statusData,
                                  context,
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // Qty Sec - sama seperti di atas
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: CsTextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: statusData == "OPEN" || statusData == "",
                            label: 'Qty',
                            initialValue: e.qtySec.value,
                            onChanged: (val) {
                              if (index != -1) {
                                tempData[index].qtySec.value =
                                    val.isEmpty ? '0' : val;
                                _updateQtyAndValidate(
                                  tempData,
                                  index,
                                  e,
                                  statusData,
                                  context,
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // // Qty Bad - sama
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: CsTextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: statusData == "OPEN" || statusData == "",
                            label: 'Qty',
                            initialValue: e.qtyBad.value,
                            onChanged: (val) {
                              if (index != -1) {
                                tempData[index].qtyBad.value =
                                    val.isEmpty ? '0' : val;
                                _updateQtyAndValidate(
                                  tempData,
                                  index,
                                  e,
                                  statusData,
                                  context,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: Center(
                            child: Obx(
                              () => Text(
                                tempData[index].diffQty.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      num.parse(
                                                tempData[index].diffQty.value,
                                              ) ==
                                              0
                                          ? AppColors.itemsBackground
                                          : num.parse(
                                                tempData[index].diffQty.value,
                                              ) >
                                              0
                                          // num.parse(
                                          //   e.initStock.value,
                                          // )
                                          ? AppColors.contentColorRed
                                          : AppColors.contentColorRed,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        statusData == "OPEN" || statusData == ""
                            ? IconButton(
                              onPressed: () {
                                soData.remove(e);
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
                })
                .where((row) => true)
                .toList(), // Filter row invalid jika perlu
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

void _updateQtyAndValidate(
  RxList<SoDetailModel> tempData,
  int index,
  SoDetailModel e,
  String statusData,
  BuildContext context,
) {
  int init = int.tryParse(tempData[index].initStock.value) ?? 0;
  int qtyNew = int.tryParse(tempData[index].qtyNew.value) ?? 0;
  int qtySec = int.tryParse(tempData[index].qtySec.value) ?? 0;
  int qtyBad = int.tryParse(tempData[index].qtyBad.value) ?? 0;

  int diff = init - qtyNew - qtySec - qtyBad;

  tempData[index].diffQty.value = diff.toString();

  // String sohValue = statusData == "" ? e.qtyTotal ?? '0' : e.soh ?? '0';
  // if (num.parse(tempData[index].diffQty.value) > init) {
  //   stokOptC.isEnable.value = false;
  //   failedDialog(context, 'Error', 'Out of stock', true);
  // } else {
  //   stokOptC.isEnable.value = true;
  // }
  // stokOptC.update();
}
