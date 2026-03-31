import 'package:assets_management/app/data/models/detail_adj_model.dart';
import 'package:assets_management/app/modules/adjusment/controllers/adjusment_controller.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/const.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/shared/elevated_button.dart';
import '../../../../data/shared/text_field.dart';
import 'datatable_adj_in.dart';

final adjC = Get.find<AdjusmentController>();

addEditAdjIn(
  BuildContext context,
  String? id,
  String? branchCode,
  String? brancName,
  String? totalQty,
  String? tgl,
  String? desc,
  String? author,
  String? statusData,
  String? lvUser,
  RxList<DetailAdjModel>? detailData,
) {
  adjC.desc.text = desc ?? '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Form(
        key: adjC.formKey,
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
                        : ' Add'} Adjusment In',
                  ),

                  isWideScreen
                      ? BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: id != "" ? id! : adjC.idTrx,
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
                          data: id != "" ? id! : adjC.idTrx,
                          width: 230,
                          height: 40,
                        ),
                    const SizedBox(height: 10),
                    statusData == "CLOSED"
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
                                            'Date',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $tgl'),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     SizedBox(
                                    //       width: 90,
                                    //       child: Text(
                                    //         'Pengirim',
                                    //         style: titleTextStyle,
                                    //       ),
                                    //     ),
                                    //     Text(': $pengirim'),
                                    //   ],
                                    // ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            'Store',
                                            style: titleTextStyle,
                                          ),
                                        ),
                                        Text(': $brancName'),
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
                                            'Created By',
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
                                      Text(
                                        'Description',
                                        style: titleTextStyle,
                                      ),
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
                            statusData == "Waiting for review"
                                ? Container()
                                : Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    width: 30,
                                    height: 47,
                                    child: FutureBuilder(
                                      future: adjC.getAssetByDiv(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var dataAsset = snapshot.data;
                                          List<String> allAsset = <String>[];
                                          dataAsset!.map((data) {
                                            allAsset.add(data.assetName!);
                                          }).toList();

                                          return TypeAheadFormField<String>(
                                            autoFlipDirection: true,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                                  enabled:
                                                      statusData == "CLOSED"
                                                          ? false
                                                          : true,
                                                  controller: adjC.asset,
                                                  // ..text = userData!.levelUser!,
                                                  decoration: InputDecoration(
                                                    labelText: 'Cari Asset',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    suffixIcon: IconButton(
                                                      onPressed: () {
                                                        adjC.asset.clear();
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .highlight_remove_rounded,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            suggestionsCallback: (pattern) {
                                              return allAsset.where(
                                                (option) => option
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
                                                  suggestion.capitalize!,
                                                ),
                                              );
                                            },
                                            onSuggestionSelected: (
                                              suggestion,
                                            ) async {
                                              adjC.asset.text = suggestion;
                                              for (
                                                int i = 0;
                                                i < dataAsset.length;
                                                i++
                                              ) {
                                                if (dataAsset[i].assetName ==
                                                    suggestion) {
                                                  await adjC.fetchStockAsset(
                                                    dataAsset[i].assetCode,
                                                  );
                                                  var index1 = adjC
                                                      .tempAssetData
                                                      .indexWhere(
                                                        ((val) =>
                                                            val.assetCode ==
                                                            dataAsset[i]
                                                                .assetCode),
                                                      );

                                                  if (index1 != -1) {
                                                    if (adjC.tempScanData
                                                            .map(
                                                              (e) =>
                                                                  e.assetCode,
                                                            )
                                                            .toList()
                                                            .contains(
                                                              dataAsset[i]
                                                                  .assetCode,
                                                            ) ||
                                                        detailData!
                                                            .map(
                                                              (e) =>
                                                                  e.assetCode,
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
                                                      // adjC.scanInput.clear();
                                                    } else {
                                                      if (detailData
                                                          .isNotEmpty) {
                                                        adjC.detailAdjIn.add(
                                                          DetailAdjModel(
                                                            assetCode:
                                                                dataAsset[i]
                                                                    .assetCode,
                                                            assetName:
                                                                dataAsset[i]
                                                                    .assetName,

                                                            qtyAdj: '0',
                                                            qtyNew: '0',
                                                            qtySec: '0',
                                                            qtyBad: '0',
                                                          ),
                                                        );
                                                        adjC.asset.clear();
                                                      } else {
                                                        adjC.tempScanData.add(
                                                          DetailAdjModel(
                                                            assetCode:
                                                                dataAsset[i]
                                                                    .assetCode,
                                                            assetName:
                                                                dataAsset[i]
                                                                    .assetName,

                                                            qtyAdj: '0',
                                                            qtyNew: '0',
                                                            qtySec: '0',
                                                            qtyBad: '0',
                                                          ),
                                                        );

                                                        adjC.asset.clear();
                                                      }
                                                    }
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
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
                                controller: adjC.desc,
                                maxLines: 2,
                                label: 'Keterangan',
                              ),
                            ),
                          ],
                        ),

                    SizedBox(
                      height: 350,
                      child: DatatableAdj(
                        statusData: statusData!,
                        // pengirim: id != "" ? pengirim! : '',
                        // penerima: id != "" ? penerima! : '',
                        adjData:
                            adjC.detailAdjIn.isNotEmpty
                                ? adjC.detailAdjIn
                                : adjC.tempScanData,
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
                          !adjC.canSubmit
                              ? null
                              : () async {
                                if (id != ""
                                    ? adjC.detailAdjIn.isNotEmpty
                                    : adjC.tempScanData.isNotEmpty) {
                                  Get.back();
                                  loadingDialog("Mengirim data", "");

                                  await adjC.saveAdjIn(
                                    id != "" ? id! : "",
                                    id != "" ? "update_data" : "add_adjIn",
                                  );
                                  adjC.resetForm();
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
                ),
                Visibility(
                  visible:
                      statusData == "OPEN" || statusData == "" ? true : false,
                  child: Obx(
                    () => CsElevatedButton(
                      onPressed:
                          !adjC.canSubmit
                              ? null
                              : () async {
                                // if (adjC.tempScanData.isNotEmpty ||
                                //     adjC.detailStokIn.isNotEmpty) {
                                Get.back();
                                loadingDialog("Mengirim data", "");
                                await adjC.submitAdjIn(
                                  id != "" ? id! : "",
                                  id != "" ? "update_data" : "add_adjIn",
                                  desc,
                                  author,
                                );
                                adjC.resetForm();
                              },
                      color: Colors.blue,
                      fontsize: 12,
                      label: 'SUBMIT',
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      statusData == "Waiting for review" &&
                      (['IT', 'AUDIT']).contains(lvUser),
                  child: CsElevatedButton(
                    onPressed: () async {
                      promptDialog(
                        context,
                        'ACCEPT',
                        'Anda yakin ingin menyetujui adjustment ini?',
                        () async {
                          Get.back();
                          loadingDialog('Memproses data...', "");
                          await adjC.acceptAdjIn(id!, author!);
                        },
                        isWideScreen,
                      );
                    },
                    color: AppColors.contentColorGreenAccent,
                    fontsize: 12,
                    label: 'ACCEPT',
                  ),
                ),
                CsElevatedButton(
                  onPressed: () async {
                    if (statusData == 'Waiting for review') {
                      if (statusData != "" &&
                          statusData != 'Reject' &&
                          (['IT', 'AUDIT']).contains(lvUser)) {
                        promptDialog(
                          context,
                          'REJECT',
                          'Anda yakin ingin menolak adjustment ini?',
                          () async {
                            Get.back();
                            loadingDialog('Memproses data...', "");
                            await adjC.rejectAdjIn(id!, author!);
                          },
                          isWideScreen,
                        );
                      } else {
                        adjC.resetForm();
                        Get.back();
                      }
                    } else {
                      adjC.resetForm();
                      Get.back();
                      // adjC.generateNumbId();
                      // adjC.formKey.currentState!.reset();
                    }
                  },
                  color:
                      statusData == "Waiting for review" &&
                              (['IT', 'AUDIT']).contains(lvUser)
                          ? Colors.red
                          : AppColors.itemsBackground,
                  fontsize: 12,
                  label:
                      statusData == "Waiting for review" &&
                              (['IT', 'AUDIT']).contains(lvUser)
                          ? 'REJECT'
                          : statusData == ""
                          ? 'CANCEL'
                          : 'CLOSE',
                ),
                Visibility(
                  visible:
                      statusData == "Waiting for review" &&
                      (['IT', 'AUDIT']).contains(lvUser),
                  child: CsElevatedButton(
                    color: AppColors.itemsBackground,
                    fontsize: 12,
                    label: 'CLOSE',
                    onPressed: () {
                      adjC.resetForm();
                      Get.back();
                    },
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
