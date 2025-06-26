import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/controllers/master_barang_controller.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/helper/currency_input_formatter.dart';
import 'add_edit_cat.dart';

final assetC = Get.put(MasterBarangController());

addEditAssets(
  BuildContext context,
  String? id,
  String? asset,
  String? category,
  String? categoryName,
  String? price,
  String? kelompok,
  String? image,
  String? satuan,
) {
  assetC.catSelected.value = category ?? '';
  assetC.catSelectedObj.value = CategoryAssets(catName: categoryName!);
  assetC.unitSelected.value = satuan ?? '';
  assetC.price.text = price ?? '';
  showDialog(
    context: context,
    builder: (context) {
      return Form(
        key: assetC.formKeyAsset,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;
            // print(isWideScreen);
            return AlertDialog(
              insetPadding: const EdgeInsets.all(8.0),
              title: Text('${id != '' ? 'Edit' : ' Tambah'} Assets'),
              content: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CsDropDown(
                            label: 'Kelompok',
                            items:
                                assetC.assetsGroup
                                    .map(
                                      (data) => DropdownMenuItem(
                                        value: data,
                                        child: Text(data),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              assetC.assetsSelected.value = val;
                              assetC.getCatAssets({"type": "", "group": val});
                              // assetC.catName.clear();
                              assetC.catSelected.value = "";
                              assetC.catSelectedObj.value = null;
                            },
                            value:
                                kelompok != ""
                                    ? assetC.assetsSelected.value = kelompok!
                                    : assetC.assetsSelected.value != ""
                                    ? assetC.assetsSelected.value
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Obx(
                            () {
                              // print(assetC.isLoading.value);
                              return assetC.isLoading.value
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : DropdownSearch<CategoryAssets>(
                                    selectedItem: assetC.catSelectedObj.value,
                                    enabled:
                                        assetC.dataCatAssets.isEmpty
                                            ? false
                                            : true,
                                    items: (String filter, _) async {
                                      final allCat =
                                          assetC.dataCatAssets
                                              .toList(); // konversi RxList ke List
                                      if (filter.isEmpty) return allCat;
                                      return allCat
                                          .where(
                                            (item) => item.catName!
                                                .toLowerCase()
                                                .contains(filter.toLowerCase()),
                                          )
                                          .toList();
                                    },
                                    itemAsString:
                                        (CategoryAssets item) => item.catName!,
                                    compareFn:
                                        (CategoryAssets a, CategoryAssets b) =>
                                            a.id == b.id,
                                    popupProps: const PopupProps.menu(
                                      showSearchBox: true,
                                      searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                          hintText: "Cari...",
                                        ),
                                      ),
                                    ),
                                    onChanged: (CategoryAssets? value) {
                                      assetC.catSelected.value = value!.id!;
                                      assetC.catSelectedObj.value = value;

                                      // Lakukan sesuatu dengan nilai yang dipilih
                                    },
                                  );
                            },

                            // CsDropDown(
                            //   label: 'Pilih Kategori',
                            //   items:
                            //       assetC.dataCatAssets
                            //           .map(
                            //             (data) => DropdownMenuItem(
                            //               value: data.id,
                            //               child: Text(data.catName),
                            //             ),
                            //           )
                            //           .toList(),
                            //   onChanged: (val) {
                            //     assetC.catSelected.value = val;
                            //   },
                            //   value:
                            //       assetC.catSelected.value != ""
                            //           ? assetC.catSelected.value
                            //           : null,
                            // ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        CsElevatedButton(
                          onPressed: () async {
                            addEditCat(context, '', '', '', '');
                            // stokC.isLoading.value = true;
                            await assetC.getCatAssets({
                              "type": "",
                              "kelompok": catC.assetsSelected.value,
                            });
                            // Get.back(closeOverlays: true);
                          },
                          size: const Size(160, 45),
                          color: mainColor,
                          fontsize: 16,
                          label: 'Tambah Kategori',
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: CsTextField(
                            controller: assetC.asset..text = asset!,
                            maxLines: 1,
                            label: 'Nama Asset',
                            onFieldSubmitted: (val) async {
                              await assetC.assetsSubmit(
                                id != "" ? "update_asset" : "add_asset",
                                id,
                                image,
                                isWideScreen,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: CsTextField(
                                  controller: assetC.price,
                                  maxLines: 1,
                                  label: 'Price',
                                  onFieldSubmitted: (val) async {
                                    await assetC.assetsSubmit(
                                      id != "" ? "update_asset" : "add_asset",
                                      id,
                                      image,
                                      isWideScreen,
                                    );
                                  },
                                  inputFormatters: [CurrencyInputFormatter()],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: CsDropDown(
                                  label: 'Satuan',
                                  items:
                                      assetC.assetsUnit
                                          .map(
                                            (data) => DropdownMenuItem(
                                              value: data,
                                              child: Text(data),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    assetC.unitSelected.value = val;
                                  },
                                  value:
                                      // kelompok != ""
                                      //     ? assetC.assetsSelected.value = kelompok!
                                      //     :
                                      assetC.unitSelected.value != ""
                                          ? assetC.unitSelected.value
                                          : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            // onTap: () => assetC.pickImg(),
                            onTap: () => assetC.pickAndUploadImage(),
                            child: ClipRRect(
                              child: GetBuilder<MasterBarangController>(
                                builder:
                                    (c) =>
                                        c.webImage != null
                                            // return kIsWeb
                                            ? Container(
                                              height: 300,
                                              width: 300,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                              ),
                                              child: Image.memory(
                                                c.webImage!,
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                            // : Container(
                                            //     height: 150,
                                            //     width: 150,
                                            //     decoration:
                                            //         BoxDecoration(color: Colors.grey[300]),
                                            //     child: Image.file(
                                            //       File(c.image!.path),
                                            //       fit: BoxFit.cover,
                                            //     ),
                                            //   );
                                            // } else {
                                            : image != ""
                                            ? SizedBox(
                                              height: 300,
                                              width: 300,
                                              child: Image.network(
                                                '${ServiceApi().baseUrl}$image',
                                                fit: BoxFit.contain,
                                              ),
                                            )
                                            : Container(
                                              height: 150,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                              ),
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera_alt),
                                                  Text('Click to upload image'),
                                                ],
                                              ),
                                            ),
                                // }
                                // },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (assetC.imagePath.value.isNotEmpty)
                      Text('Path: ${assetC.imagePath.value}'),
                  ],
                ),
              ),
              actions: [
                CsElevatedButton(
                  onPressed: () async {
                    if (assetC.formKeyAsset.currentState!.validate()) {
                      // print(id);
                      await assetC.assetsSubmit(
                        id != "" ? "update_asset" : "add_asset",
                        id,
                        image,
                        isWideScreen,
                      );
                    }
                    //else {
                    //   showToast('Asset tidak boleh kosong', 'red');
                    // }
                  },
                  color: Colors.blue,
                  fontsize: 12,
                  label: 'Submit',
                ),
                CsElevatedButton(
                  onPressed: () {
                    Get.back();
                    assetC.getCatAssets({"type": ""});
                    assetC.webImage = null;
                    assetC.catSelected.value = "";
                    assetC.catSelectedObj.value = null;
                    assetC.assetsSelected.value = "";
                    assetC.formKeyAsset.currentState!.reset();
                  },
                  color: Colors.red,
                  fontsize: 12,
                  label: 'Cancel',
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
