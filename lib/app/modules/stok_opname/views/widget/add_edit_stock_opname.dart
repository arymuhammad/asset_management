import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/so_detail_model.dart';
import 'package:assets_management/app/modules/stok_opname/controllers/stok_opname_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/shared/dropdown.dart';
import '../../../../data/shared/elevated_button.dart';
import '../../../../data/shared/text_field.dart';
import 'data_table_so.dart';

final stokOptC = Get.find<StokOpnameController>();

addEditSo(
  BuildContext context,
  String? id,
  String? kodePenerima,
  String? penerima,
  String? desc,
  String? statusData,
  RxList<SoDetailModel>? detailSoData,
) {
  stokOptC.brnch.text = penerima ?? '';
  stokOptC.brand.value = 'Pilih Kelompok';
  stokOptC.branchCode.value = kodePenerima ?? '';
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Form(
        key: stokOptC.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;
            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${id != '' ? 'Edit' : ' Create'} Stock Opname'),
                  isWideScreen
                      ? Text('ID : ${id != "" ? id : stokOptC.idTrx}')
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
                        : Text('ID : ${id != "" ? id : stokOptC.idTrx}'),
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
                                    label: 'Pilih Kelompok',
                                    items:
                                        stokOptC.lstBrand
                                            .map(
                                              (data) => DropdownMenuItem(
                                                value: data.brandCabang!,
                                                child: Text(data.brandCabang!),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        statusData == "OPEN"
                                            ? null
                                            : (val) {
                                              if (val == 'Pilih Kelompok') {
                                                stokOptC.brand.value = "";
                                                dialogMsg(
                                                  'Peringatan',
                                                  'Harap pilih store terlebih dulu',
                                                );
                                              } else {
                                                stokOptC.brand.value = val;
                                                // penerima = "";
                                                stokOptC.branchName.value = "";
                                                stokOptC.brnch.clear();
                                                // stokOptC.getCabang({
                                                //   "brand": val,
                                                // });
                                              }
                                              // stokOptC.catSelected.value = "";
                                            },
                                    value:
                                        // kelompok != ""
                                        //     ? stokOptC.assetsSelected.value = kelompok!
                                        //     :
                                        stokOptC.brand.value != ""
                                            ? stokOptC.brand.value
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
                                //       stokOptC.lstBranch
                                //           .map(
                                //             (data) => DropdownMenuItem(
                                //               value: data.kodeCabang!,
                                //               child: Text(data.namaCabang!),
                                //             ),
                                //           )
                                //           .toList(),
                                //   onChanged: (val) {
                                //     stokOptC.toBranch.value = val;
                                //   },
                                //   value:
                                //       // penerima != ""
                                //       //     ? stokOptC.toBranch.value = penerima!
                                //       //     :
                                //       stokOptC.toBranch.value != ""
                                //           ? stokOptC.toBranch.value
                                //           : null,
                                // ),
                                Obx(
                                  () => FutureBuilder(
                                    future: stokOptC.getCabang({
                                      "brand": stokOptC.brand.value,
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
                                                    stokOptC.brand.isEmpty ||
                                                            statusData == "OPEN"
                                                        ? false
                                                        : true,
                                                controller: stokOptC.brnch,
                                                decoration: InputDecoration(
                                                  labelText: 'Pilih Store',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      stokOptC.brnch.clear();
                                                      stokOptC
                                                          .branchName
                                                          .value = "";
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
                                            stokOptC.branchName.value =
                                                suggestion["nama"] ?? "";
                                            stokOptC.branchCode.value =
                                                suggestion["kode"] ?? "";
                                            stokOptC.brnch.text =
                                                stokOptC.branchName.value;
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
                            controller: stokOptC.desc..text = desc!,
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
                        future: stokOptC.getAssetByDiv(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var dataAsset = snapshot.data;
                            // List<String> allAsset = <String>[];
                            // dataAsset!.map((data) {
                            //   allAsset.add(data.assetName!);
                            // }).toList();

                            List<Map<String, String>> assetList = [];
                            for (var data in dataAsset!) {
                              // Simpan data sebagai map dengan nama dan kode cabang
                              assetList.add({
                                "nama": data.assetName ?? '',
                                "group": data.group ?? '',
                              });
                            }

                            return TypeAheadFormField<Map<String, String>>(
                              autoFlipDirection: true,
                              textFieldConfiguration: TextFieldConfiguration(
                                enabled: statusData == "CLOSED" ? false : true,
                                controller: stokOptC.asset,
                                // ..text = userData!.levelUser!,
                                decoration: InputDecoration(
                                  labelText: 'Cari Asset',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      stokOptC.asset.clear();
                                    },
                                    icon: const Icon(
                                      Icons.highlight_remove_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                return assetList.where(
                                                (option) => option['nama']!
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
                                                  suggestion['nama']!
                                                          .capitalize ??
                                                      "", style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  suggestion['group']!
                                                          .capitalize ??
                                                      "",
                                                ),
                                              );
                              },
                              onSuggestionSelected: (suggestion) async {
                                stokOptC.asset.text = suggestion['nama'] ?? "";
                                for (int i = 0; i < dataAsset.length; i++) {
                                  if (dataAsset[i].assetName ==  suggestion['nama'] &&
                                                    dataAsset[i].group ==
                                                        suggestion['group']) {
                                    await stokOptC.fetchStockAsset(
                                      dataAsset[i].assetCode!,
                                      stokOptC.branchCode.value,
                                    );
                                    // var index1 = stokOptC.tempAssetData
                                    //     .indexWhere(
                                    //       ((val) =>
                                    //           val.assetCode ==
                                    //           dataAsset[i].assetCode),
                                    //     );

                                    // if (index1 != -1) {
                                    if (stokOptC.tempScanData
                                            .map((e) => e.assetCode)
                                            .toList()
                                            .contains(dataAsset[i].assetCode) ||
                                        detailSoData!
                                            .map((e) => e.assetCode)
                                            .toList()
                                            .contains(dataAsset[i].assetCode)) {
                                      showToast("Data ini sudah ada", "red");
                                      // stokOptC.scanInput.clear();
                                    } else {
                                      if (detailSoData.isNotEmpty) {
                                        stokOptC.detailSo.add(
                                          SoDetailModel(
                                            assetCode: dataAsset[i].assetCode,
                                            assetName: dataAsset[i].assetName,
                                            // group: dataAsset[i].group,
                                            initStock:
                                                stokOptC
                                                    .tempAssetData
                                                    .first
                                                    .qtyTotal,
                                            diffQty: '0',
                                            // soh:
                                            //     stokOptC
                                            //         .tempAssetData
                                            //         .first
                                            //         .qtyTotal,
                                            // qtyOut: '0',
                                            // neww: '0',
                                            // sec: '0',
                                            // bad: '0',
                                          ),
                                        );
                                        stokOptC.asset.clear();
                                      } else {
                                        stokOptC.tempScanData.add(
                                          SoDetailModel(
                                            assetCode: dataAsset[i].assetCode,
                                            assetName: dataAsset[i].assetName,
                                            // group: dataAsset[i].group,
                                            initStock:
                                                stokOptC
                                                    .tempAssetData
                                                    .first
                                                    .qtyTotal,
                                            diffQty: '0',
                                            // soh:
                                            //     stokOptC
                                            //         .tempAssetData
                                            //         .first
                                            //         .qtyTotal,
                                            // qtyOut: '0',
                                            // neww: '0',
                                            // sec: '0',
                                            // bad: '0',
                                          ),
                                        );

                                        stokOptC.asset.clear();
                                      }
                                    }
                                    // stokOptC.selectedLevel.value =
                                    //     dataAsset[i].id!;
                                    // stokOptC.levelName.value =
                                    //     dataAsset[i].namaLevel!;
                                    // stokOptC.vst.value = dataAsset[i].visit!;
                                    // stokOptC.cekStok.value =
                                    //     dataAsset[i].cekStok!;
                                    // } else {
                                    //   failedDialog(
                                    //     Get.context!,
                                    //     'ERROR',
                                    //     'Data tidak ditemukan atau stok kosong\nPeriksa ketersediaan stok terlebih dahulu',
                                    //     isWideScreen,
                                    //   );
                                    // }
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
                      child: DataTableSo(
                        soData:
                            stokOptC.detailSo.isNotEmpty
                                ? stokOptC.detailSo
                                : stokOptC.tempScanData,
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
                          stokOptC.canSubmit
                              ? () async {
                                // if (id != ""
                                //     ? stokOptC.detailSo.isNotEmpty
                                //     : stokOptC.tempScanData.isNotEmpty) {
                                if (stokOptC.branchCode.value.isNotEmpty) {
                                  Get.back();
                                  loadingDialog("Mengirim data", "");
                                  await stokOptC.saveDataSo(
                                    id != "" ? id! : "",
                                    id != "" ? "update_data" : "add_so",
                                  );
                                  await stokOptC.getSoData(
                                    // stokOptC.fromBranch,
                                    // stokOptC.levelUser.split(' ')[0],
                                  );
                                  // stokOptC.filterDataStokOut("");
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  stokOptC.dtSo.notifyListeners();
                                } else {
                                  failedDialog(
                                    context,
                                    "ERROR",
                                    "Silahkan pilih store terlebih dahulu",
                                    isWideScreen,
                                  );
                                }
                                // } else {
                                //   failedDialog(
                                //     context,
                                //     "ERROR",
                                //     "Tidak ada data barang yang di input.\nHarap input data barang terlebih dahulu sebelum klik SAVE",
                                //     isWideScreen,
                                //   );
                                // }
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
                          stokOptC.canSubmit
                              ? () async {
                                // if (id != ""
                                //     ? stokOptC.detailSo.isNotEmpty
                                //     : stokOptC.tempScanData.isNotEmpty) {
                                if (stokOptC.branchCode.value.isNotEmpty) {
                                  bool diff = stokOptC.detailSo.any(
                                    (e) => int.parse(e.diffQty.value) != 0,
                                  );
                                  if (diff) {
                                    warningDialog(
                                      context,
                                      'Warning',
                                      'Ada qty asset yang nilainya minus\nLanjutkan proses ini?',
                                      () async {
                                        Get.back();
                                        loadingDialog("Memproses data", "");
                                        await stokOptC.processDataSo(
                                          id != "" ? id! : "",
                                          id != "" ? "update_data" : "add_so",
                                        );
                                        await stokOptC.getSoData();
                                        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                        stokOptC.dtSo.notifyListeners();
                                      },
                                      isWideScreen,
                                    );
                                  } else {
                                    Get.back();
                                    loadingDialog("Memproses data", "");
                                    await stokOptC.processDataSo(
                                      id != "" ? id! : "",
                                      id != "" ? "update_data" : "add_so",
                                    );
                                    await stokOptC.getSoData(
                                      // stokOptC.fromBranch,
                                      // stokOptC.levelUser.split(' ')[0],
                                    );
                                    await stokOptC.getSoData(
                                      // stokOptC.fromBranch,
                                      // stokOptC.levelUser.split(' ')[0],
                                    );
                                    // stokOptC.filterDataStokOut("");
                                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    stokOptC.dtSo.notifyListeners();
                                  }
                                } else {
                                  failedDialog(
                                    context,
                                    "ERROR",
                                    "Silahkan pilih store terlebih dahulu",
                                    isWideScreen,
                                  );
                                }
                                // } else {
                                //   failedDialog(
                                //     context,
                                //     "ERROR",
                                //     "Tidak ada data barang yang di input.\nHarap input data barang terlebih dahulu sebelum klik SUBMIT",
                                //     isWideScreen,
                                //   );
                                // }
                              }
                              : null,
                      color: Colors.blue,
                      fontsize: 12,
                      label: 'PROCESS',
                    ),
                  ),
                ),
                CsElevatedButton(
                  onPressed: () {
                    stokOptC.resetForm();
                    // stokOptC.toBranch.value = "";
                    // penerima = "";
                    Get.back();
                    stokOptC.detailSo.clear();
                    stokOptC.generateNumbId();
                    // stokOptC.getCatAssets({
                    //   "type": "",
                    // });
                    // stokOptC.webImage = null;
                    // stokOptC.catSelected.value = "";
                    // stokOptC.assetsSelected.value = "";
                    // stokOptC.formKey.currentState!.reset();
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
