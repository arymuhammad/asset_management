// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/elevated_button_icon.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/barang_masuk/controllers/barang_masuk_controller.dart';
import 'package:assets_management/app/modules/barang_masuk/views/widget/datatable_stok_in.dart';
import 'package:assets_management/app/modules/stok/controllers/stok_controller.dart';
// import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

final stokInC = Get.find<BarangMasukController>();
final stokC = Get.find<StokController>();

addEditStokIn(
  BuildContext context,
  String? id,
  String? kodePengirim,
  String? pengirim,
  String? kodePenerima,
  String? penerima,
  String? totalQty,
  String? tgl,
  String? desc,
  String? author,
  String? statusData,
  RxList<DetailBarangMasukKeluar>? detailData,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Form(
        key: stokInC.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;
            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${id != ''
                        ? statusData != 'CLOSED'
                            ? 'Edit'
                            : 'Detail'
                        : ' Tambah'} Data Barang Masuk',
                  ),

                  isWideScreen
                      ? BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: id != "" ? id! : stokInC.idTrx,
                        width: 230,
                        height: 50,
                      )
                      : const SizedBox(width: 100),
                ],
              ),
              content: Container(
                height: MediaQuery.of(context).size.height / 1,
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isWideScreen
                        ? const SizedBox(width: 50)
                        : BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: id != "" ? id! : stokInC.idTrx,
                          width: 230,
                          height: 40,
                        ),
                    const SizedBox(height: 10),
                    statusData == "CLOSED" || pengirim != penerima
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Tanggal',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $tgl'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Pengirim',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $pengirim'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Penerima',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $penerima'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Total Qty',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $totalQty'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Dibuat oleh',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $author'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 240),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Keterangan', style: titleTextStyle),
                                      Text('$desc'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            statusData == "CLOSED" || pengirim != penerima
                                ? Container()
                                : Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    width: 30,
                                    height: 47,
                                    child: FutureBuilder(
                                      future: stokInC.getAssetByDiv(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var dataAsset = snapshot.data;

                                          List<Map<String, String>> assetList =
                                              [];
                                          for (var data in dataAsset!) {
                                            // Simpan data sebagai map dengan nama dan kode cabang
                                            assetList.add({
                                              "nama": data.assetName ?? '',
                                              "group": data.group ?? '',
                                            });
                                          }
                                          // List<String> allAsset = <String>[];
                                          // dataAsset!.map((data) {
                                          //   allAsset.add(data.assetName!);
                                          // }).toList();

                                          return TypeAheadFormField<
                                            Map<String, String>
                                          >(
                                            autoFlipDirection: true,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                                  controller: stokInC.asset,
                                                  // ..text = userData!.levelUser!,
                                                  decoration: InputDecoration(
                                                    labelText: 'Cari Asset',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        stokInC.asset.clear();
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .highlight_remove_rounded,
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
                                            onSuggestionSelected: (suggestion) {
                                              stokInC.asset.text =
                                                  suggestion['nama'] ?? "";
                                              for (
                                                int i = 0;
                                                i < dataAsset.length;
                                                i++
                                              ) {
                                                if (dataAsset[i].assetName ==
                                                        suggestion['nama'] &&
                                                    dataAsset[i].group ==
                                                        suggestion['group']) {
                                                  if (stokInC.tempScanData
                                                          .map(
                                                            (e) => e.assetCode,
                                                          )
                                                          .toList()
                                                          .contains(
                                                            dataAsset[i]
                                                                .assetCode,
                                                          ) ||
                                                      detailData!
                                                          .map(
                                                            (e) => e.assetCode,
                                                          )
                                                          .toList()
                                                          .contains(
                                                            dataAsset[i]
                                                                .assetCode,
                                                          )) {
                                                    showToast(
                                                      "Data ini sudah ada",
                                                      "red",
                                                    );
                                                    // stokInC.scanInput.clear();
                                                  } else {
                                                    if (detailData.isNotEmpty) {
                                                      stokInC.detailStokIn.add(
                                                        DetailBarangMasukKeluar(
                                                          assetCode:
                                                              dataAsset[i]
                                                                  .assetCode,
                                                          assetName:
                                                              dataAsset[i]
                                                                  .assetName,
                                                          group:
                                                              dataAsset[i]
                                                                  .group,
                                                          qtyTotal: '0',
                                                          qtyIn: '0',
                                                          neww: '0',
                                                          sec: '0',
                                                          bad: '0',
                                                        ),
                                                      );
                                                      stokInC.asset.clear();
                                                    } else {
                                                      stokInC.tempScanData.add(
                                                        DetailBarangMasukKeluar(
                                                          assetCode:
                                                              dataAsset[i]
                                                                  .assetCode,
                                                          assetName:
                                                              dataAsset[i]
                                                                  .assetName,
                                                          group:
                                                              dataAsset[i]
                                                                  .group,
                                                          qtyTotal: '0',
                                                          qtyIn: '0',
                                                          neww: '0',
                                                          sec: '0',
                                                          bad: '0',
                                                        ),
                                                      );

                                                      stokInC.asset.clear();
                                                    }
                                                    // stokInC.selectedLevel.value =
                                                    //     dataAsset[i].id!;
                                                    // stokInC.levelName.value =
                                                    //     dataAsset[i].namaLevel!;
                                                    // stokInC.vst.value = dataAsset[i].visit!;
                                                    // stokInC.cekStok.value =
                                                    //     dataAsset[i].cekStok!;
                                                  }
                                                }
                                              }
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
                                              child: SizedBox(
                                                height: 10,
                                                width: 10,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Text('Loading...'),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 3,
                              child: CsTextField(
                                enabled:
                                    statusData == "OPEN" || statusData == ""
                                        ? true
                                        : false,
                                controller: stokInC.desc..text = desc!,
                                maxLines: 2,
                                label: 'Keterangan',
                              ),
                            ),
                          ],
                        ),

                    SizedBox(
                      height: 350,
                      child: DatatableStokIn(
                        statusData: statusData!,
                        pengirim: id != "" ? pengirim! : '',
                        penerima: id != "" ? penerima! : '',
                        stokInData:
                            stokInC.detailStokIn.isNotEmpty
                                ? stokInC.detailStokIn
                                : stokInC.tempScanData,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Visibility(
                  visible:
                      statusData == "OPEN" && pengirim == penerima ||
                              statusData == ""
                          ? true
                          : false,
                  child: CsElevatedButton(
                    onPressed: () async {
                      if (id != ""
                          ? stokInC.detailStokIn.isNotEmpty
                          : stokInC.tempScanData.isNotEmpty) {
                        Get.back();
                        loadingDialog("Mengirim data", "");

                        await stokInC.saveDataIn(
                          id != "" ? id! : "",
                          id != "" ? "update_data" : "add_stokIn",
                          kodePenerima,
                          kodePengirim,
                        );

                        // ignore: invalid_use_of_protected_member
                        stokInC.dataSource.notifyListeners();
                      } else {
                        failedDialog(
                          context,
                          'ERROR',
                          'Tidak ada data yang disimpan',
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
                  child: Obx(
                    () => CsElevatedButton(
                      onPressed:
                          !stokInC.canSubmit
                              ? null
                              : () async {
                                // if (stokInC.tempScanData.isNotEmpty ||
                                //     stokInC.detailStokIn.isNotEmpty) {
                                Get.back();
                                loadingDialog("Mengirim data", "");
                                await stokInC.submitDataIn(
                                  id != "" ? id! : "",
                                  id != "" ? "update_data" : "add_adjIn",
                                  kodePenerima,
                                  kodePengirim,
                                  desc,
                                  author,
                                );
                                stokInC.filterDataStokIn("");
                                // ignore: invalid_use_of_protected_member
                                stokInC.dataSource.notifyListeners();
                                // } else {
                                //   failedDialog(
                                //     context,
                                //     'ERROR',
                                //     'Tidak ada data yang disimpan',
                                //     isWideScreen,
                                //   );
                                // }
                              },
                      color: Colors.blue,
                      fontsize: 12,
                      label: pengirim == penerima ? 'SUBMIT' : 'CONFIRM',
                    ),
                  ),
                ),
                CsElevatedButton(
                  onPressed: () async {
                    if (pengirim != penerima && statusData != 'CLOSED') {
                      if (pengirim != penerima && statusData != 'REJECT') {
                        promptDialog(
                          context,
                          'REJECT',
                          'Anda yakin ingin menolak data ini?',
                          () async {
                            Get.back();
                            loadingDialog('Memproses data...', "");
                            await stokInC.rejectDataIn(id!);
                          },
                          isWideScreen,
                        );
                      } else {
                        stokInC.brand.value = "";
                        stokInC.lstBranch.clear();
                        stokInC.detailStokIn.clear();
                        Get.back();
                      }
                    } else {
                      stokInC.brand.value = "";
                      stokInC.lstBranch.clear();
                      stokInC.tempScanData.clear();
                      stokInC.detailStokIn.clear();
                      // stokInC.toBranch.value = "";
                      // penerima = "";
                      Get.back();
                      stokInC.generateNumbId();
                      // stokInC.getCatAssets({
                      //   "type": "",
                      // });
                      // stokInC.webImage = null;
                      // stokInC.catSelected.value = "";
                      // stokInC.assetsSelected.value = "";
                      // stokInC.formKey.currentState!.reset();
                    }
                  },
                  color:
                      statusData == "OPEN" && pengirim != penerima
                          ? Colors.red
                          : AppColors.itemsBackground,
                  fontsize: 12,
                  label:
                      statusData == "OPEN" && pengirim != penerima
                          ? 'REJECT'
                          : statusData == "OPEN" || statusData == ""
                          ? 'CANCEL'
                          : 'CLOSE',
                ),
                Visibility(
                  visible: statusData == "OPEN" && pengirim != penerima,
                  child: CsElevatedButton(
                    color: AppColors.itemsBackground,
                    fontsize: 12,
                    label: 'CLOSE',
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
