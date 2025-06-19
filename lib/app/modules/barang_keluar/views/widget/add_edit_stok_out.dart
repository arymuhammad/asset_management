// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/barang_keluar_controller.dart';

final stokOutC = Get.put(BarangKeluarController());

addEditStokOut(
  BuildContext context,
  String? id,
  String? kodePenerima,
  String? penerima,
  String? desc,
  String? statusData,
  RxList<DetailBarangMasukKeluar>? detailData,
) {
  stokOutC.toBranch.value = kodePenerima ?? '';
  stokOutC.brand.value = 'Pilih Brand';

  showDialog(
    context: context,
    builder: (context) {
      return Form(
        key: stokOutC.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;
            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${id != '' ? 'Edit' : ' Tambah'} Data Barang Keluar'),
                  isWideScreen
                      ? Text('ID : ${id != "" ? id : stokOutC.idTrx}')
                      : const SizedBox(width: 100),
                ],
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 1,
                width: MediaQuery.of(context).size.width / 2,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isWideScreen
                        ? const SizedBox(width: 50)
                        : Text('ID : ${id != "" ? id : stokOutC.idTrx}'),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Obx(
                          () => Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  //  width: 70,
                                  child: CsDropDown(
                                    label: 'Pilih Brand',
                                    items:
                                        stokOutC.lstBrand
                                            .map(
                                              (data) => DropdownMenuItem(
                                                value: data.brandCabang!,
                                                child: Text(data.brandCabang!),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        statusData == "OPEN" || statusData == ""
                                            ? (val) {
                                              if (val == 'Pilih Brand') {
                                                stokOutC.brand.value = "";
                                                dialogMsg(
                                                  'Peringatan',
                                                  'Harap pilih cabang terlebih dulu',
                                                );
                                              } else {
                                                stokOutC.brand.value = val;
                                                // penerima = "";
                                                stokOutC.toBranch.value = "";
                                                stokOutC.getCabang({
                                                  "brand": val,
                                                });
                                              }
                                              // stokOutC.catSelected.value = "";
                                            }
                                            : null,
                                    value:
                                        // kelompok != ""
                                        //     ? stokOutC.assetsSelected.value = kelompok!
                                        //     :
                                        stokOutC.brand.value != ""
                                            ? stokOutC.brand.value
                                            : null,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Harap isi bagian pilihan ini';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                CsDropDown(
                                  label:
                                      penerima != ""
                                          ? penerima!
                                          : 'Pilih Cabang',
                                  items:
                                      stokOutC.lstBranch
                                          .map(
                                            (data) => DropdownMenuItem(
                                              value: data.kodeCabang!,
                                              child: Text(data.namaCabang!),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    stokOutC.toBranch.value = val;
                                  },
                                  value:
                                      // penerima != ""
                                      //     ? stokOutC.toBranch.value = penerima!
                                      //     :
                                      stokOutC.toBranch.value != ""
                                          ? stokOutC.toBranch.value
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: CsTextField(
                            enabled:
                                statusData == "OPEN" || statusData == ""
                                    ? true
                                    : false,
                            controller: stokOutC.desc..text = desc!,
                            maxLines: 4,
                            label: 'Keterangan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    CsTextField(
                      enabled:
                          statusData == "OPEN" || statusData == ""
                              ? true
                              : false,
                      maxLines: 1,
                      label: 'Scan Barcode ',
                      controller: stokOutC.scanInput,
                      onFieldSubmitted: (data) async {
                        if (data.isNotEmpty) {
                          loadingDialog("Mengambil data...", "");
                          await stokOutC.fetchStockAsset(data);
                          Get.back();
                          var index1 = stokOutC.tempAssetData.indexWhere(
                            ((val) => val.assetCode == data),
                          );

                          if (index1 != -1) {
                            // print('Index: $index1');
                            // print(transaksiController.dataBarang[index1].kodeBarang);
                            if (stokOutC.tempScanData
                                    .map((e) => e.assetCode)
                                    .toList()
                                    .contains(data) ||
                                detailData!.isNotEmpty &&
                                    detailData
                                        .map((e) => e.assetCode)
                                        .toList()
                                        .contains(data)) {
                              showToast("Data ini sudah ada", "red");
                              // stokOutC.scanInput.clear();
                            } else {
                              if (detailData.isNotEmpty) {
                                stokOutC.detailStokOut.add(
                                  DetailBarangMasukKeluar(
                                    assetCode:
                                        stokOutC.tempAssetData.first.assetCode,
                                    assetName:
                                        stokOutC.tempAssetData.first.assetName,
                                    group: stokOutC.tempAssetData.first.group,
                                    qtyOut: '0',
                                    good: '0',
                                    bad: '0',
                                  ),
                                );
                              } else {
                                stokOutC.tempScanData.add(
                                  DetailBarangMasukKeluar(
                                    assetCode:
                                        stokOutC.tempAssetData.first.assetCode,
                                    assetName:
                                        stokOutC.tempAssetData.first.assetName,
                                    group: stokOutC.tempAssetData.first.group,
                                    qtyOut: '0',
                                    good: '0',
                                    bad: '0',
                                  ),
                                );
                              }
                            }
                            stokOutC.scanInput.clear();
                          } else {
                            failedDialog(
                              Get.context!,
                              'ERROR',
                              'Data tidak ditemukan atau stok kosong\nPeriksa ketersediaan stok terlebih dahulu',
                              isWideScreen,
                            );
                          }
                        } else {
                          showToast(
                            "Harap masukkan data terlebih dahulu",
                            "red",
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 250,
                      child: Obx(
                        () => DataTable2(
                          empty: const Center(child: Text('Belum ada data')),
                          lmRatio: 1,
                          minWidth: 1000,
                          isHorizontalScrollBarVisible: true,
                          isVerticalScrollBarVisible: true,
                          fixedLeftColumns: 1,
                          columns: [
                            const DataColumn2(
                              label: Text('Asset Name'),
                              fixedWidth: 190,
                            ),
                            const DataColumn2(
                              label: Text('Asset Code'),
                              fixedWidth: 200,
                            ),
                            const DataColumn2(
                              label: Text('Qty Total'),
                              fixedWidth: 120,
                            ),
                            const DataColumn2(
                              label: Text('Qty Good'),
                              fixedWidth: 120,
                            ),
                            const DataColumn2(
                              label: Text('Qty Bad'),
                              fixedWidth: 120,
                            ),
                            DataColumn2(
                              label:
                                  statusData == "OPEN" || statusData == ""
                                      ? const Text('Action')
                                      : Container(),
                              fixedWidth: 120,
                            ),
                          ],
                          rows:
                              detailData!.isNotEmpty
                                  ? detailData
                                      .map(
                                        (e) => DataRow(
                                          cells: [
                                            DataCell(Text(e.assetName!)),
                                            DataCell(Text(e.assetCode!)),
                                            DataCell(
                                              SizedBox(
                                                height: 37,
                                                child: CsTextField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  initialValue:
                                                      detailData.isNotEmpty
                                                          ? e.qtyOut
                                                          : "",
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .detailStokOut
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .qtyOut = '0';
                                                      } else {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .qtyOut = val;
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
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  label: 'Good',
                                                  initialValue:
                                                      detailData.isNotEmpty
                                                          ? e.good
                                                          : "",
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .detailStokOut
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .good = '0';
                                                      } else {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .good = val;
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
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  label: 'Bad',
                                                  initialValue:
                                                      detailData.isNotEmpty
                                                          ? e.bad
                                                          : "",
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .detailStokOut
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .bad = '0';
                                                      } else {
                                                        stokOutC
                                                            .detailStokOut[index]
                                                            .bad = val;
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              statusData == "OPEN" ||
                                                      statusData == ""
                                                  ? IconButton(
                                                    onPressed: () {
                                                      detailData.remove(e);
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .highlight_remove_rounded,
                                                      color: Colors.red[700],
                                                    ),
                                                  )
                                                  : Container(),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList()
                                  : stokOutC.tempScanData
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => DataRow(
                                          cells: [
                                            DataCell(Text(e.value.assetName)),
                                            DataCell(Text(e.value.assetCode)),
                                            DataCell(
                                              SizedBox(
                                                height: 37,
                                                child: CsTextField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .tempScanData
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.value.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .qtyOut = '0';
                                                      } else {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .qtyOut = val;
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
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  label: 'Good',
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .tempScanData
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.value.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .good = '0';
                                                      } else {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .good = val;
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
                                                    FilteringTextInputFormatter
                                                        .digitsOnly,
                                                  ],
                                                  enabled:
                                                      statusData == "OPEN" ||
                                                              statusData == ""
                                                          ? true
                                                          : false,
                                                  label: 'Bad',
                                                  onChanged: (val) {
                                                    int index = stokOutC
                                                        .tempScanData
                                                        .indexWhere(
                                                          (data) =>
                                                              data.assetCode ==
                                                              e.value.assetCode,
                                                        );
                                                    if (index != -1) {
                                                      if (val.isEmpty) {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .bad = '0';
                                                      } else {
                                                        stokOutC
                                                            .tempScanData[index]
                                                            .bad = val;
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              statusData == "OPEN" ||
                                                      statusData == ""
                                                  ? IconButton(
                                                    onPressed: () {
                                                      stokOutC.tempScanData
                                                          .removeAt(e.key);
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .highlight_remove_rounded,
                                                      color: Colors.red[700],
                                                    ),
                                                  )
                                                  : Container(),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Visibility(
                  visible:
                      statusData == "OPEN" || statusData == "" ? true : false,
                  child: CsElevatedButton(
                    onPressed: () async {
                      if (id != ""
                          ? stokOutC.detailStokOut.isNotEmpty
                          : stokOutC.tempScanData.isNotEmpty) {
                        if (stokOutC.formKey.currentState!.validate()) {
                          await stokOutC.saveDataIn(
                            id != "" ? id! : "",
                            id != "" ? "update_data" : "add_stokOut",
                          );
                          await stokOutC.getStokOutData(stokOutC.fromBranch);
                          stokOutC.filterDataStokOut("");
                          // ignore: invalid_use_of_protected_member
                          stokOutC.dataSource.notifyListeners();
                        }
                      } else {
                        failedDialog(
                          context,
                          "ERROR",
                          "Tidak ada data barang yang di scan.\nHarap scan data barang terlebih dahulu sebelum klik SAVE",
                          isWideScreen,
                        );
                      }
                    },
                    color: green,
                    fontsize: 12,
                    label: 'SAVE',
                  ),
                ),
                Visibility(
                  visible:
                      statusData == "OPEN" || statusData == "" ? true : false,
                  child: CsElevatedButton(
                    onPressed: () async {
                      if (id != ""
                          ? stokOutC.detailStokOut.isNotEmpty
                          : stokOutC.tempScanData.isNotEmpty) {
                        if (stokOutC.formKey.currentState!.validate()) {
                          await stokOutC.submitDataIn(
                            id != "" ? id! : "",
                            id != "" ? "update_data" : "add_stokOut",
                          );
                          await stokOutC.getStokOutData(stokOutC.fromBranch);
                          // stokOutC.filterDataAsset("");
                          // ignore: invalid_use_of_protected_member
                          stokOutC.dataSource.notifyListeners();
                        }
                      } else {
                        failedDialog(
                          context,
                          "ERROR",
                          "Tidak ada data barang yang di scan.\nHarap scan data barang terlebih dahulu sebelum klik SUBMIT",
                          isWideScreen,
                        );
                      }
                    },
                    color: Colors.blue,
                    fontsize: 12,
                    label: 'SUBMIT',
                  ),
                ),
                CsElevatedButton(
                  onPressed: () {
                    stokOutC.brand.value = "";
                    stokOutC.lstBranch.clear();
                    // stokOutC.toBranch.value = "";
                    // penerima = "";
                    Get.back();
                    // stokOutC.getCatAssets({
                    //   "type": "",
                    // });
                    // stokOutC.webImage = null;
                    // stokOutC.catSelected.value = "";
                    // stokOutC.assetsSelected.value = "";
                    // stokOutC.formKey.currentState!.reset();
                  },
                  color: Colors.red,
                  fontsize: 12,
                  label:
                      statusData == "OPEN" || statusData == ""
                          ? 'CANCEL'
                          : 'CLOSE',
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
