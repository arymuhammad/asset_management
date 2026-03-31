// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/barang_keluar/views/widget/datatable_stok_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import '../../../../data/helper/app_colors.dart';
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
  stokOutC.toBranchName.text = penerima ?? '';
  stokOutC.brand.value = 'Pilih Brand';
  stokOutC.toBranch.text = kodePenerima ?? '';
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
                width: MediaQuery.of(context).size.width / 1.5,
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
                                                stokOutC.toBranchName.clear();
                                                // stokOutC.getCabang({
                                                //   "brand": val,
                                                // });
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
                                // CsDropDown(
                                //   label:
                                //       penerima != ""
                                //           ? penerima!
                                //           : 'Pilih Cabang',
                                //   items:
                                //       stokOutC.lstBranch
                                //           .map(
                                //             (data) => DropdownMenuItem(
                                //               value: data.kodeCabang!,
                                //               child: Text(data.namaCabang!),
                                //             ),
                                //           )
                                //           .toList(),
                                //   onChanged: (val) {
                                //     stokOutC.toBranch.value = val;
                                //   },
                                //   value:
                                //       // penerima != ""
                                //       //     ? stokOutC.toBranch.value = penerima!
                                //       //     :
                                //       stokOutC.toBranch.value != ""
                                //           ? stokOutC.toBranch.value
                                //           : null,
                                // ),
                                Obx(
                                  () => FutureBuilder(
                                    future: stokOutC.getCabang({
                                      "brand": stokOutC.brand.value,
                                    }),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var dataCabang = snapshot.data;
                                        List<Map<String, String>> cabangList =
                                            [];
                                        for (var data in dataCabang!) {
                                          // Simpan data sebagai map dengan nama dan kode cabang
                                          cabangList.add({
                                            "nama": data.namaCabang ?? '',
                                            "kode": data.kodeCabang ?? '',
                                          });
                                        }
                                        return TypeAheadFormField<
                                          Map<String, String>
                                        >(
                                          autoFlipDirection: true,
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                                enabled:
                                                    stokOutC.brand.isEmpty
                                                        ? false
                                                        : true,
                                                controller:
                                                    stokOutC.toBranchName,
                                                decoration: InputDecoration(
                                                  labelText: 'Pilih cabang',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      stokOutC.toBranchName
                                                          .clear();
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .highlight_remove_rounded,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          suggestionsCallback: (pattern) {
                                            return cabangList.where(
                                              (option) => option["nama"]!
                                                  .toLowerCase()
                                                  .contains(
                                                    pattern.toLowerCase(),
                                                  ),
                                            );
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              tileColor: Colors.white,
                                              title: Text(
                                                suggestion['nama'] ?? "",
                                              ),
                                            );
                                          },
                                          onSuggestionSelected: (
                                            suggestion,
                                          ) async {
                                            stokOutC.toBranchName.text =
                                                suggestion["nama"] ?? "";
                                            stokOutC.toBranch.text =
                                                suggestion["kode"] ?? "";
                                          },
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      }
                                      return const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          SizedBox(width: 5),
                                          Text('Loading...'),
                                        ],
                                      );
                                    },
                                  ),
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
                            maxLines: 5,
                            label: 'Keterangan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    SizedBox(
                      height: 45,
                      child: FutureBuilder(
                        future: stokOutC.getAssetByDiv(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataAsset = snapshot.data;
                            List<String> allAsset = <String>[];
                            dataAsset!.map((data) {
                              allAsset.add(data.assetName!);
                            }).toList();

                            return TypeAheadFormField<String>(
                              autoFlipDirection: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                enabled: statusData == "CLOSED" ? false : true,
                                controller: stokOutC.asset,
                                // ..text = userData!.levelUser!,
                                decoration: InputDecoration(
                                  labelText: 'Cari Asset',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      stokOutC.asset.clear();
                                    },
                                    icon: const Icon(
                                      Icons.highlight_remove_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return allAsset.where(
                                  (option) => option.toLowerCase().contains(
                                    pattern.toLowerCase(),
                                  ),
                                );
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  tileColor: Colors.white,
                                  title: Text(suggestion.capitalize!),
                                );
                              },
                              onSuggestionSelected: (suggestion) async {
                                stokOutC.asset.text = suggestion;
                                for (int i = 0; i < dataAsset.length; i++) {
                                  if (dataAsset[i].assetName == suggestion) {
                                    await stokOutC.fetchStockAsset(
                                      dataAsset[i].assetCode,
                                    );
                                    var index1 = stokOutC.tempAssetData
                                        .indexWhere(
                                          ((val) =>
                                              val.assetCode ==
                                              dataAsset[i].assetCode),
                                        );

                                    if (index1 != -1) {
                                      if (stokOutC.tempScanData
                                              .map((e) => e.assetCode)
                                              .toList()
                                              .contains(
                                                dataAsset[i].assetCode,
                                              ) ||
                                          detailData!
                                              .map((e) => e.assetCode)
                                              .toList()
                                              .contains(
                                                dataAsset[i].assetCode,
                                              )) {
                                        showToast("Data ini sudah ada", "red");
                                        // stokOutC.scanInput.clear();
                                      } else {
                                        if (detailData.isNotEmpty) {
                                          stokOutC.detailStokOut.add(
                                            DetailBarangMasukKeluar(
                                              assetCode: dataAsset[i].assetCode,
                                              assetName: dataAsset[i].assetName,
                                              group: dataAsset[i].group,
                                              qtyTotal:
                                                  stokOutC
                                                      .tempAssetData
                                                      .first
                                                      .qtyTotal,
                                              soh:
                                                  stokOutC
                                                      .tempAssetData
                                                      .first
                                                      .qtyTotal,
                                              qtyOut: '0',
                                              neww: '0',
                                              sec: '0',
                                              bad: '0',
                                            ),
                                          );
                                          stokOutC.asset.clear();
                                        } else {
                                          stokOutC.tempScanData.add(
                                            DetailBarangMasukKeluar(
                                              assetCode: dataAsset[i].assetCode,
                                              assetName: dataAsset[i].assetName,
                                              group: dataAsset[i].group,
                                              qtyTotal:
                                                  stokOutC
                                                      .tempAssetData
                                                      .first
                                                      .qtyTotal,
                                              soh:
                                                  stokOutC
                                                      .tempAssetData
                                                      .first
                                                      .qtyTotal,
                                              qtyOut: '0',
                                              neww: '0',
                                              sec: '0',
                                              bad: '0',
                                            ),
                                          );

                                          stokOutC.asset.clear();
                                        }
                                      }
                                      // stokOutC.selectedLevel.value =
                                      //     dataAsset[i].id!;
                                      // stokOutC.levelName.value =
                                      //     dataAsset[i].namaLevel!;
                                      // stokOutC.vst.value = dataAsset[i].visit!;
                                      // stokOutC.cekStok.value =
                                      //     dataAsset[i].cekStok!;
                                    } else {
                                      failedDialog(
                                        Get.context!,
                                        'ERROR',
                                        'Data tidak ditemukan atau stok kosong\nPeriksa ketersediaan stok terlebih dahulu',
                                        isWideScreen,
                                      );
                                    }
                                  }
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: CircularProgressIndicator()),
                              SizedBox(width: 5),
                              Text('Loading...'),
                            ],
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      height: 280,
                      child: DatatableStokOut(
                        stokOutData:
                            stokOutC.detailStokOut.isNotEmpty
                                ? stokOutC.detailStokOut
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
                  child: Obx(
                    () => CsElevatedButton(
                      onPressed:
                          stokOutC.isEnable.value
                              ? () async {
                                if (id != ""
                                    ? stokOutC.detailStokOut.isNotEmpty
                                    : stokOutC.tempScanData.isNotEmpty) {
                                  if (stokOutC.toBranch.text.isNotEmpty) {
                                    Get.back();
                                    loadingDialog("Mengirim data", "");
                                    await stokOutC.saveDataOut(
                                      id != "" ? id! : "",
                                      id != "" ? "update_data" : "add_stokOut",
                                    );
                                    await stokOutC.getStokOutData(
                                      stokOutC.fromBranch,
                                      stokOutC.levelUser.split(' ')[0],
                                    );
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
                                    "Tidak ada data barang yang di input.\nHarap input data barang terlebih dahulu sebelum klik SAVE",
                                    isWideScreen,
                                  );
                                }
                              }
                              : null,
                      color: green,
                      fontsize: 12,
                      label: 'SAVE',
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      statusData == "OPEN" || statusData == "" ? true : false,
                  child: Obx(
                    () => CsElevatedButton(
                      onPressed:
                          stokOutC.isEnable.value
                              ? () async {
                                if (id != ""
                                    ? stokOutC.detailStokOut.isNotEmpty
                                    : stokOutC.tempScanData.isNotEmpty) {
                                  if (stokOutC.toBranch.text.isNotEmpty) {
                                    Get.back();
                                    loadingDialog("Mengirim data", "");
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
                                    "Tidak ada data barang yang di input.\nHarap input data barang terlebih dahulu sebelum klik SUBMIT",
                                    isWideScreen,
                                  );
                                }
                              }
                              : null,
                      color: Colors.blue,
                      fontsize: 12,
                      label: 'SUBMIT',
                    ),
                  ),
                ),
                CsElevatedButton(
                  onPressed: () {
                    stokOutC.brand.value = "";
                    stokOutC.toBranchName.clear();
                    stokOutC.toBranch.clear();
                    stokOutC.lstBranch.clear();
                    stokOutC.asset.clear();
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
                  color: AppColors.itemsBackground,
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
