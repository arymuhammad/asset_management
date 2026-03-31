import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
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
        minWidth: 1200,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        fixedLeftColumns: 1,
        columns: [
          const DataColumn2(label: Text('Asset Name'), fixedWidth: 190),
          const DataColumn2(label: Text('Asset Code'), fixedWidth: 210),
          const DataColumn2(label: Text('SOH'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty New'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty Sec'), fixedWidth: 120),
          const DataColumn2(label: Text('Qty Bad'), fixedWidth: 120),
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
            // stokOutData.isNotEmpty
            //     ?
            stokOutData
                .map((e) {
                  RxList<DetailBarangMasukKeluar> tempData =
                      stokOutC.tempScanData.isNotEmpty
                          ? stokOutC.tempScanData
                          : stokOutC.detailStokOut;

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
                        DataCell(
                          Text(statusData == "" ? e.qtyTotal : e.soh ?? ''),
                        ),
                        const DataCell(
                          Center(child: Text('Item tidak ditemukan')),
                        ),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Container()),
                      ],
                    );
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(e.assetName ?? '')),
                      DataCell(Text(e.assetCode ?? '')),
                      DataCell(
                        Text(statusData == "" ? e.qtyTotal : e.soh ?? ''),
                      ),

                      // Qty New - dengan validasi index
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: CsTextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: statusData == "OPEN" || statusData == "",
                            label: 'New',
                            initialValue: e.neww.value,
                            onChanged: (val) {
                              if (index != -1) {
                                // TAMBAHKAN PENGECEKAN INI
                                tempData[index].neww.value =
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
                            label: 'Second',
                            initialValue: e.sec.value,
                            onChanged: (val) {
                              if (index != -1) {
                                tempData[index].sec.value =
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

                      // Qty Bad - sama
                      DataCell(
                        SizedBox(
                          height: 37,
                          child: CsTextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            enabled: statusData == "OPEN" || statusData == "",
                            label: 'Bad',
                            initialValue: e.bad.value,
                            onChanged: (val) {
                              if (index != -1) {
                                tempData[index].bad.value =
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
                        child: Text(
                          tempData[index].qtyOut.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                num.parse(tempData[index].qtyOut.value) == 0
                                    ? AppColors.itemsBackground
                                    : num.parse(tempData[index].qtyOut.value) >
                                        num.parse(
                                          statusData == ""
                                              ? e.qtyTotal
                                              : e.soh!,
                                        )
                                    ? AppColors.contentColorRed
                                    : AppColors.contentColorGreenAccent,
                          ),
                        ),
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

void _updateQtyAndValidate(RxList<DetailBarangMasukKeluar> tempData, 
                          int index, DetailBarangMasukKeluar e, 
                          String statusData, BuildContext context) {
  num newwNum = num.tryParse(tempData[index].neww.value) ?? 0;
  num secNum = num.tryParse(tempData[index].sec.value) ?? 0;
  num badNum = num.tryParse(tempData[index].bad.value) ?? 0;
  tempData[index].qtyOut.value = (newwNum + secNum + badNum).toString();
  
  String sohValue = statusData == "" ? e.qtyTotal ?? '0' : e.soh ?? '0';
  if (num.parse(tempData[index].qtyOut.value) > num.parse(sohValue)) {
    stokOutC.isEnable.value = false;
    failedDialog(context, 'Error', 'Out of stock', true);
  } else {
    stokOutC.isEnable.value = true;
  }
  stokOutC.update();
}
