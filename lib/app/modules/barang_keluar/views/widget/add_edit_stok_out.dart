// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/barang_keluar/views/widget/datatable_stok_out.dart';
import 'package:flutter/material.dart';
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
    barrierDismissible: false,
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
                      child: DatatableStokOut(
                        stokOutData:
                            detailData!.isNotEmpty
                                ? detailData
                                : stokOutC.tempScanData,
                        statusData: statusData!,
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
                        if (stokOutC.toBranch.isNotEmpty) {
                          await stokOutC.saveDataOut(
                            id != "" ? id! : "",
                            id != "" ? "update_data" : "add_stokOut",
                          );
                          await stokOutC.getStokOutData(stokOutC.fromBranch);
                          // stokOutC.filterDataStokOut("");
                          // ignore: invalid_use_of_protected_member
                          stokOutC.dataSourceOut.notifyListeners();
                        } else {
                          failedDialog(
                            context,
                            "ERROR",
                            "Cabang tujuan tidak boleh kosong",
                            isWideScreen,
                          );
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
                        if (stokOutC.toBranch.isNotEmpty) {
                          await stokOutC.submitDataOut(
                            id != "" ? id! : "",
                            id != "" ? "update_data" : "add_stokOut",
                          );
                        } else {
                          failedDialog(
                            context,
                            "ERROR",
                            "Cabang tujuan tidak boleh kosong",
                            isWideScreen,
                          );
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
                    stokOutC.scanInput.clear();
                    stokOutC.tempScanData.clear();
                    // stokOutC.toBranch.value = "";
                    // penerima = "";
                    Get.back();
                    stokOutC.detailStokOut.clear();
                    stokOutC.generateNumbId();
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
