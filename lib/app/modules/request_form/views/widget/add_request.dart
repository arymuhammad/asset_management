import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/request_form/views/widget/data_table_reqform.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/models/category_assets_model.dart';
import '../../controllers/request_form_controller.dart';

final requestC = Get.put(RequestFormController());

addRequest(
  BuildContext context,
  String? id,
  String? group,
  String? branchCode,
  String? reqTitle,
  String? cat,
  RxList<RequestDetailModel>? detailData,
) async {
  requestC.requestTitle.text = reqTitle ?? '';
  requestC.catSelected.value = cat ?? '';

  if (id != null && id.isNotEmpty) {
    requestC.tempData.clear();
    if (cat != null && cat.isNotEmpty) {
      await requestC.getReqItem(cat, group!, branchCode!);
    }
    for (var lst in requestC.tempAssetData) {
      final matchedDetail = detailData?.firstWhere(
        (d) => d.assetCode == lst.assetCode,
        orElse: () => RequestDetailModel(qtyReq: '0'),
      );
      requestC.tempData.add(
        RequestDetailModel(
          id: (requestC.tempData.length + 1).toString(),
          assetCode: lst.assetCode,
          assetName: lst.assetName,
          image: lst.image,
          qtyStock: lst.qtyStock ?? '0',
          qtyReq: matchedDetail?.qtyReq ?? '0',
          unit: lst.unit,
          price: lst.price,
          sts: matchedDetail?.sts ?? '',
        ),
      );
    }
    requestC.tempData.sort(
      (a, b) =>
          int.parse(b.qtyReq ?? '0').compareTo(int.parse(a.qtyReq ?? '0')),
    );

    requestC.tempData.refresh(); // Untuk trigger update pada UI
  } else {
    requestC.tempData.clear();
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder:
          (context) => LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth >= 800;
              return AlertDialog(
                insetPadding: const EdgeInsets.all(8.0),
                title: Text(id != "" ? 'Edit Resuest' : ' Add Request'),
                content: Container(
                  width:
                      MediaQuery.of(context).size.width /
                      (isWideScreen ? 1.7 : 1.6),
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
                              Expanded(
                                child: Obx(
                                  () =>
                                      requestC.isLoading.value
                                          ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                          : DropdownSearch<CategoryAssets>(
                                            selectedItem:
                                                requestC.catSelectedObj.value,
                                            enabled:
                                                requestC.catAsset.isNotEmpty,
                                            items: (String filter, _) async {
                                              final allCat =
                                                  requestC.catAsset.toList();
                                              if (filter.isEmpty) return allCat;
                                              return allCat
                                                  .where(
                                                    (item) =>
                                                        item.catName!
                                                            .toLowerCase()
                                                            .contains(
                                                              filter
                                                                  .toLowerCase(),
                                                            ) ||
                                                        item.assetsGroup!
                                                            .toLowerCase()
                                                            .contains(
                                                              filter
                                                                  .toLowerCase(),
                                                            ),
                                                  )
                                                  .toList();
                                            },
                                            itemAsString:
                                                (CategoryAssets item) =>
                                                    '${item.catName!} - ( ${item.assetsGroup!.contains('Brand')
                                                        ? 'BR'
                                                        : item.assetsGroup!.contains('Editorial')
                                                        ? 'ED'
                                                        : item.assetsGroup!.contains('General Affair')
                                                        ? 'GA'
                                                        : item.assetsGroup!.contains('Project')
                                                        ? 'PR'
                                                        : item.assetsGroup!.contains('Visual Merchandise')
                                                        ? 'VM'
                                                        : item.assetsGroup!.contains('Visual Merchandise Fashion')
                                                        ? 'VMF'
                                                        : item.assetsGroup!.contains('Online (Another)')
                                                        ? 'AN'
                                                        : item.assetsGroup!} )',
                                            compareFn: (a, b) => a.id == b.id,
                                            popupProps: const PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  hintText: "Cari...",
                                                ),
                                              ),
                                            ),
                                            onChanged: (
                                              CategoryAssets? value,
                                            ) async {
                                              requestC.catSelected.value =
                                                  value!.id!;
                                              requestC.catSelectedObj.value =
                                                  value;
                                              await requestC.getReqItem(
                                                value.id!,
                                                value.assetsGroup!,
                                                branchCode!,
                                              );
                                              for (var lst
                                                  in requestC.tempAssetData) {
                                                requestC.tempData.add(
                                                  RequestDetailModel(
                                                    id:
                                                        (requestC
                                                                    .tempData
                                                                    .length +
                                                                1)
                                                            .toString(),
                                                    assetCode: lst.assetCode,
                                                    assetName: lst.assetName,
                                                    image: lst.image,
                                                    qtyStock:
                                                        lst.qtyStock ?? '0',
                                                    qtyReq: '0',
                                                    unit: lst.unit,
                                                    price: lst.price,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                ),
                              ),
                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width / 4.4,
                              //   child: FutureBuilder(
                              //     future: requestC.fetchCatAsset(),
                              //     builder: (context, snapshot) {
                              //       if (snapshot.hasData) {
                              //         return CsDropDown(
                              //           label: 'Category',
                              //           value:
                              //               requestC.catSelected.isNotEmpty
                              //                   ? requestC.catSelected.value
                              //                   : null,
                              //           items:
                              //               requestC.catAsset
                              //                   .map(
                              //                     (e) => DropdownMenuItem(
                              //                       value: e.id,
                              //                       child: Text('${e.catName!} - ${e.assetsGroup}'),
                              //                     ),
                              //                   )
                              //                   .toList(),
                              //           onChanged: (val) async {
                              //             requestC.catSelected.value = val;
                              //             await requestC.getReqItem(val);
                              //             for (var lst
                              //                 in requestC.tempAssetData) {
                              //               requestC.tempData.add(
                              //                 RequestDetailModel(
                              //                   id:
                              //                       (requestC.tempData.length +
                              //                               1)
                              //                           .toString(),
                              //                   assetCode: lst.assetCode,
                              //                   assetName: lst.assetName,
                              //                   image: lst.image,
                              //                   qtyStock: lst.qtyStock ?? '0',
                              //                   qtyReq: '0',
                              //                   unit: lst.unit,
                              //                   price: lst.price,
                              //                 ),
                              //               );
                              //             }
                              //           },
                              //         );
                              //       } else if (snapshot.hasError) {
                              //         return Text(snapshot.error.toString());
                              //       }
                              //       return const Center(
                              //         child: CupertinoActivityIndicator(),
                              //       );
                              //     },
                              //   ),
                              // ),
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
                          child: Obx(
                            () =>
                                requestC.isLoading.value
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : DropdownSearch<CategoryAssets>(
                                      selectedItem:
                                          requestC.catSelectedObj.value,
                                      items: (String filter, _) async {
                                        final allCat =
                                            requestC.catAsset.toList();
                                        if (filter.isEmpty) return allCat;
                                        return allCat
                                            .where(
                                              (item) =>
                                                  item.catName!
                                                      .toLowerCase()
                                                      .contains(
                                                        filter.toLowerCase(),
                                                      ) ||
                                                  item.assetsGroup!
                                                      .toLowerCase()
                                                      .contains(
                                                        filter.toLowerCase(),
                                                      ),
                                            )
                                            .toList();
                                      },
                                      itemAsString:
                                          (CategoryAssets item) =>
                                              '${item.catName!} - ( ${item.assetsGroup!.contains('Brand')
                                                  ? 'BR'
                                                  : item.assetsGroup!.contains('Editorial')
                                                  ? 'ED'
                                                  : item.assetsGroup!.contains('General Affair')
                                                  ? 'GA'
                                                  : item.assetsGroup!.contains('Project')
                                                  ? 'PR'
                                                  : item.assetsGroup!.contains('Visual Merchandise')
                                                  ? 'VM'
                                                  : item.assetsGroup!.contains('Visual Merchandise Fashion')
                                                  ? 'VMF'
                                                  : item.assetsGroup!.contains('Online (Another)')
                                                  ? 'AN'
                                                  : item.assetsGroup!} )',
                                      compareFn: (a, b) => a.id == b.id,
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          decoration: InputDecoration(
                                            hintText: "Cari...",
                                          ),
                                        ),
                                      ),
                                      onChanged: (CategoryAssets? value) async {
                                        requestC.catSelected.value = value!.id!;
                                        requestC.catSelectedObj.value = value;
                                        await requestC.getReqItem(
                                          value.id!,
                                          value.assetsGroup!,
                                          branchCode!,
                                        );
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
                                              qtyReq: '0',
                                              unit: lst.unit,
                                              price: lst.price,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: DataTableReqform(listData: requestC.tempData, id:id, branch:branchCode, desc:reqTitle),
                        ),
                      ],
                    ),
                  ),
                ),
                actions:
                    id!.isNotEmpty
                        ? []
                        : [
                          CsElevatedButton(
                            color: red!,
                            fontsize: 14,
                            onPressed: () {
                              requestC.catAsset.clear();
                              requestC.tempData.clear();
                              requestC
                                  .grandTotal
                                  .value = requestC.tempData.fold(
                                0,
                                (prev, item) =>
                                    prev +
                                    ((int.tryParse(item.price ?? '0') ?? 0) *
                                        (int.tryParse(item.qtyReq ?? '0') ??
                                            0)),
                              );
                              requestC.tempData.refresh();
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
                                if (requestC.grandTotal.value == 0) {
                                  failedDialog(
                                    context,
                                    'ERROR',
                                    'Kolom Request tidak boleh kosong semua (0)\nHarap isi Kolom Request pada salah satu item',
                                    isWideScreen,
                                  );
                                } else {
                                  requestC.requestSubmit(
                                    id != "" ? "update_request" : "add_request",
                                    id != "" ? id : "",
                                  );
                                }
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
  } else {
    return;
  }
}
