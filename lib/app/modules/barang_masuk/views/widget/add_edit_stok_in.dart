// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/barang_masuk/controllers/barang_masuk_controller.dart';
import 'package:assets_management/app/modules/barang_masuk/views/widget/datatable_stok_in.dart';
import 'package:assets_management/app/modules/stok/controllers/stok_controller.dart';
// import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barcode_widget/barcode_widget.dart';

final stokInC = Get.put(BarangMasukController());
final stokC = Get.put(StokController());

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
                width: MediaQuery.of(context).size.width / 2,
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
                                    child: CsTextField(
                                      enabled:
                                          statusData == "OPEN" ||
                                                  statusData == ""
                                              ? true
                                              : false,
                                      maxLines: 1,
                                      label: 'Scan Barcode ',
                                      controller: stokInC.scanInput,
                                      onFieldSubmitted: (data) async {
                                        if (data.isNotEmpty) {
                                          loadingDialog(
                                            "Mengambil data...",
                                            "",
                                          );
                                          await stokInC.fetchAsset(data);
                                          Get.back();
                                          var index1 = stokInC.tempAssetData
                                              .indexWhere(
                                                ((val) =>
                                                    val.assetCode == data),
                                              );

                                          if (index1 != -1) {
                                            // print('Index: $index1');
                                            // print(transaksiController.dataBarang[index1].kodeBarang);
                                            if (stokInC.tempScanData
                                                    .map((e) => e.assetCode)
                                                    .toList()
                                                    .contains(data) ||
                                                detailData!
                                                    .map((e) => e.assetCode)
                                                    .toList()
                                                    .contains(data)) {
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
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .assetCode,
                                                    assetName:
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .assetName,
                                                    group:
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .group,
                                                    qtyIn: '0',
                                                    good: '0',
                                                    bad: '0',
                                                  ),
                                                );
                                              } else {
                                                stokInC.tempScanData.add(
                                                  DetailBarangMasukKeluar(
                                                    assetCode:
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .assetCode,
                                                    assetName:
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .assetName,
                                                    group:
                                                        stokInC
                                                            .tempAssetData
                                                            .first
                                                            .group,
                                                    qtyIn: '0',
                                                    good: '0',
                                                    bad: '0',
                                                  ),
                                                );
                                              }
                                            }
                                            stokInC.scanInput.clear();
                                          } else {
                                            showToast(
                                              "Data tidak ditemukan",
                                              "red",
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
                        await stokInC.saveDataIn(
                          id != "" ? id! : "",
                          id != "" ? "update_data" : "add_stokIn",
                          kodePenerima,
                          kodePengirim,
                        );
                        await stokInC.getStokInData(stokInC.fromBranch);
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
                  child: CsElevatedButton(
                    onPressed: () async {
                      if (stokInC.tempScanData.isNotEmpty ||
                          stokInC.detailStokIn.isNotEmpty) {
                        await stokInC.submitDataIn(
                          id != "" ? id! : "",
                          id != "" ? "update_data" : "add_stokIn",
                          kodePenerima,
                          kodePengirim,
                          desc,
                        );
                        await stokInC.getStokInData(stokInC.fromBranch);
                        stokInC.filterDataStokIn("");
                        // ignore: invalid_use_of_protected_member
                        stokInC.dataSource.notifyListeners();
                        stokInC.generateNumbId();
                      } else {
                        failedDialog(
                          context,
                          'ERROR',
                          'Tidak ada data yang disimpan',
                          isWideScreen,
                        );
                      }
                    },
                    color: Colors.blue,
                    fontsize: 12,
                    label: pengirim == penerima ? 'SUBMIT' : 'CONFIRM',
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
                          () => stokInC.rejectDataIn(id!),
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
                  color: Colors.red,
                  fontsize: 12,
                  label:
                      statusData == "OPEN" && pengirim != penerima
                          ? 'REJECT'
                          : statusData == "OPEN" || statusData == ""
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
