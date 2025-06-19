import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/request_form/views/widget/data_table_reqform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../controllers/request_form_controller.dart';

final requestC = Get.put(RequestFormController());

addRequest(
  BuildContext context,
  RxList<DetailBarangMasukKeluar>? detailData,
  String? id,
) {
  showDialog(
    context: context,
    builder:
        (context) => LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;

            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: const Text('Add Request'),
              content: Container(
                width:
                    MediaQuery.of(context).size.width /
                    (isWideScreen ? 2.2 : 1.6),
                height: MediaQuery.of(context).size.height / 1.5,
                decoration: const BoxDecoration(color: Colors.white),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: isWideScreen ? true : false,
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.5,
                              child: CsTextField(
                                controller: requestC.requestTitle,
                                label: 'Request Title',
                              ),
                            ),
                            const SizedBox(width: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4.4,
                              child: FutureBuilder(
                                future: requestC.fetchCatAsset(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return CsDropDown(
                                      label: 'Category',
                                      items:
                                          requestC.catAsset
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e.id,
                                                  child: Text(e.catName!),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) async {
                                        await requestC.getReqItem(val);
                                        for (var lst
                                            in requestC.tempAssetData) {
                                          requestC.tempData.add(
                                            RequestDetailModel(
                                              id:
                                                  (requestC.tempData.length + 1)
                                                      .toString(),
                                              assetCode: lst.assetCode,
                                              assetName: lst.assetName,
                                              image: lst.image,
                                              qtyStock: lst.qtyStock ?? '0',
                                              qtyReq: '1',
                                              unit: lst.unit,
                                              price: lst.price,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  return Center(
                                    child: CupertinoActivityIndicator(),
                                  );
                                },
                              ),

                              // CsTextField(
                              //   label: 'Scan / cari data',
                              //   maxLines: 1,
                              //   controller: requestC.scanController,
                              //   onFieldSubmitted: (data) async {
                              //     if (data.isNotEmpty) {
                              //       loadingDialog("Mengambil data...", "");
                              //       await requestC.fetchCatAsset(data);
                              //       Get.back();
                              //       // var index1 =
                              //       //     requestC
                              //       //                 .tempAssetData
                              //       //                 .value
                              //       //                 .assetCode ==
                              //       //             data
                              //       //         ? 0
                              //       //         : -1;
                              //       // print(index1);
                              //       if (requestC
                              //               .tempAssetData
                              //               .value
                              //               .assetCode ==
                              //           data) {
                              //         // print('Index: $index1');
                              //         // print(transaksiController.dataBarang[index1].kodeBarang);
                              //         if (requestC.tempData
                              //                 .map((e) => e.assetCode)
                              //                 .toList()
                              //                 .contains(data) ||
                              //             detailData!
                              //                 .map((e) => e.assetCode)
                              //                 .toList()
                              //                 .contains(data)) {
                              //           showToast("Data ini sudah ada", "red");
                              //           // stokInC.scanInput.clear();
                              //         } else {
                              //           // if (detailData.isNotEmpty) {
                              //           //   requestC.detailStokIn.add(
                              //           //     DetailBarangMasukKeluar(
                              //           //       assetCode:
                              //           //           stokInC
                              //           //               .tempAssetData
                              //           //               .first
                              //           //               .assetCode,
                              //           //       assetName:
                              //           //           stokInC
                              //           //               .tempAssetData
                              //           //               .first
                              //           //               .assetName,
                              //           //       group:
                              //           //           stokInC
                              //           //               .tempAssetData
                              //           //               .first
                              //           //               .group,
                              //           //       qtyIn: '0',
                              //           //       good: '0',
                              //           //       bad: '0',
                              //           //     ),
                              //           //   );
                              //           // } else {
                              //           requestC.tempData.add(
                              //             RequestDetailModel(
                              //               id:
                              //                   (requestC.tempData.length +
                              //                           1)
                              //                       .toString(),
                              //               assetCode:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .assetCode,
                              //               assetName:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .assetName,
                              //               image:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .image,
                              //               qtyStock:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .qtyStock ??
                              //                   '0',
                              //               qtyReq: '1',
                              //               unit:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .unit,
                              //               price:
                              //                   requestC
                              //                       .tempAssetData
                              //                       .value
                              //                       .price,
                              //             ),
                              //           );
                              //           // }
                              //         }
                              //         requestC.scanController.clear();
                              //       } else {
                              //         showToast(
                              //           "Data tidak ditemukan \ Stock kosong",
                              //           "red",
                              //         );
                              //       }
                              //     } else {
                              //       showToast(
                              //         "Harap masukkan data terlebih dahulu",
                              //         "red",
                              //       );
                              //     }
                              //   },
                              // ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isWideScreen ? false : true,
                        child: CsTextField(
                          controller: requestC.requestTitle,
                          label: 'Request Title',
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Visibility(
                        visible: isWideScreen ? false : true,
                        child: CsTextField(
                          label: 'Scan / cari data',
                          maxLines: 1,
                          // controller: requestC.scanController,
                          onFieldSubmitted: (data) async {
                            if (data.isNotEmpty) {
                              loadingDialog("Mengambil data...", "");
                              await requestC.fetchCatAsset();
                              Get.back();
                              // var index1 =
                              //     requestC
                              //                 .tempAssetData
                              //                 .value
                              //                 .assetCode ==
                              //             data
                              //         ? 0
                              //         : -1;
                              // print(index1);
                              // if (requestC.tempAssetData.value.assetCode ==
                              //     data) {
                              //   // print('Index: $index1');
                              //   // print(transaksiController.dataBarang[index1].kodeBarang);
                              //   if (requestC.tempData
                              //           .map((e) => e.assetCode)
                              //           .toList()
                              //           .contains(data) ||
                              //       detailData!
                              //           .map((e) => e.assetCode)
                              //           .toList()
                              //           .contains(data)) {
                              //     showToast("Data ini sudah ada", "red");
                              //     // stokInC.scanInput.clear();
                              //   } else {
                              //     // if (detailData.isNotEmpty) {
                              //     //   requestC.detailStokIn.add(
                              //     //     DetailBarangMasukKeluar(
                              //     //       assetCode:
                              //     //           stokInC
                              //     //               .tempAssetData
                              //     //               .first
                              //     //               .assetCode,
                              //     //       assetName:
                              //     //           stokInC
                              //     //               .tempAssetData
                              //     //               .first
                              //     //               .assetName,
                              //     //       group:
                              //     //           stokInC
                              //     //               .tempAssetData
                              //     //               .first
                              //     //               .group,
                              //     //       qtyIn: '0',
                              //     //       good: '0',
                              //     //       bad: '0',
                              //     //     ),
                              //     //   );
                              //     // } else {

                              //     requestC.tempData.add(
                              //       RequestDetailModel(
                              //         id:
                              //             (requestC.tempData.length + 1)
                              //                 .toString(),
                              //         assetCode:
                              //             requestC
                              //                 .tempAssetData
                              //                 .value
                              //                 .assetCode,
                              //         assetName:
                              //             requestC
                              //                 .tempAssetData
                              //                 .value
                              //                 .assetName,
                              //         image: requestC.tempAssetData.value.image,
                              //         qtyStock:
                              //             requestC
                              //                 .tempAssetData
                              //                 .value
                              //                 .qtyStock ??
                              //             '0',
                              //         unit: requestC.tempAssetData.value.unit,
                              //         price: requestC.tempAssetData.value.price,
                              //         qtyReq: '1',
                              //       ),
                              //     );
                              //     // }
                              //   }
                              //   // requestC.scanController.clear();
                              // } else {
                              //   showToast(
                              //     "Data tidak ditemukan atau Stock kosong",
                              //     "red",
                              //   );
                              // }
                            } else {
                              showToast(
                                "Harap masukkan data terlebih dahulu",
                                "red",
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.8,
                        child: DataTableReqform(listData: requestC.tempData),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CsElevatedButton(
                  color: red!,
                  fontsize: 14,
                  onPressed: () {
                    requestC.tempData.clear();
                    requestC.requestTitle.clear();
                    Get.back();
                  },
                  label: 'Cancel',
                ),

                CsElevatedButton(
                  color: mainColor,
                  fontsize: 14,
                  onPressed: () {
                    if (requestC.tempData.isEmpty) {
                      failedDialog(
                        context,
                        "ERROR",
                        "Tidak ada data yang dimasukkan",
                        isWideScreen,
                      );
                    } else if (requestC.requestTitle.text.isEmpty) {
                      failedDialog(
                        context,
                        "ERROR",
                        "Harap isi Request Title",
                        isWideScreen,
                      );
                    } else {
                      requestC.requestSubmit(
                        id != "" ? "update_request" : "add_request",
                        id != "" ? id! : "",
                      );
                      // requestC.requestData.dataRequest.value =
                      //     requestC.tempData;
                      // requestC.requestData.title = requestC.requestTitle.text;
                      // requestC.requestData.author = requestC.author;
                      // requestC.requestData.branchCode = requestC.branchCode;
                      // requestC.generateId();
                      // Get.back(result: true);
                      //  Get.back();
                      // requestC.tempData.clear();
                      // requestC.requestTitle.clear();
                    }
                  },
                  label: 'Submit',
                ),
              ],
            );
          },
        ),
  );
}
