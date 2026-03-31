import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/const.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/shared/dropdown.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/controllers/master_barang_controller.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/currency_input_formatter.dart';
import '../../../../data/helper/custom_dialog.dart';
import 'add_edit_cat.dart';

final assetC = Get.put(MasterBarangController());

addEditAssets(
  BuildContext context,
  String? id,
  String? asset,
  String? sn,
  String? category,
  String? categoryName,
  String? price,
  String? purDate,
  String? kelompok,
  String? image,
  String? satuan,
) {
  assetC.assetsSelected.value = kelompok ?? '';
  assetC.catSelected.value = category ?? '';
  assetC.catSelectedObj.value = CategoryAssets(catName: categoryName!);
  assetC.asset.text = asset ?? '';
  assetC.sn.text = sn ?? '';
  assetC.unitSelected.value = satuan ?? '';
  assetC.price.text = price ?? '';
  assetC.purchaseDate.text = purDate ?? '';
  showDialog(
    context: context,
    builder: (context) {
      return Form(
        key: assetC.formKeyAsset,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth >= 800;

            return AlertDialog(
              scrollable: true, // agar konten dialog bisa digulir
              insetPadding: const EdgeInsets.all(8.0),
              title: Text('${id != '' ? 'Edit' : ' Tambah'} Assets'),
              content: Container(
                width: MediaQuery.of(context).size.width / 1.90,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row/Kolom Kelompok, Kategori dan Tombol Tambah Kategori
                    isWideScreen
                        ? Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => CsDropDown(
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
                                    assetC.getCatAssets({
                                      "type": "",
                                      "group": val,
                                    });
                                    assetC.catSelected.value = "";
                                    assetC.catSelectedObj.value = null;
                                  },
                                  value:
                                      assetC.assetsSelected.value.isNotEmpty
                                          ? assetC.assetsSelected.value
                                          : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Obx(
                                () =>
                                    assetC.isLoading.value
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : DropdownSearch<CategoryAssets>(
                                          selectedItem:
                                              assetC.catSelectedObj.value,
                                          enabled:
                                              assetC.dataCatAssets.isNotEmpty,
                                          items: (String filter, _) async {
                                            final allCat =
                                                assetC.dataCatAssets.toList();
                                            if (filter.isEmpty) return allCat;
                                            return allCat
                                                .where(
                                                  (item) => item.catName!
                                                      .toLowerCase()
                                                      .contains(
                                                        filter.toLowerCase(),
                                                      ),
                                                )
                                                .toList();
                                          },
                                          itemAsString:
                                              (CategoryAssets item) =>
                                                  item.catName!,
                                          compareFn: (a, b) => a.id == b.id,
                                          popupProps: const PopupProps.menu(
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.all(20),
                                                hintText: "Cari...",
                                              ),
                                            ),
                                          ),
                                          onChanged: (CategoryAssets? value) {
                                            assetC.catSelected.value =
                                                value!.id!;
                                            assetC.catSelectedObj.value = value;
                                          },
                                        ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            CsElevatedButton(
                              onPressed: () async {
                                addEditCat(context, '', '', '', '');
                                await assetC.getCatAssets({
                                  "type": "",
                                  "kelompok": assetC.assetsSelected.value,
                                });
                              },
                              size: const Size(160, 45),
                              color: mainColor,
                              fontsize: 16,
                              label: 'Tambah Kategori',
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => CsDropDown(
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
                                  assetC.getCatAssets({
                                    "type": "",
                                    "group": val,
                                  });
                                  assetC.catSelected.value = "";
                                  assetC.catSelectedObj.value = null;
                                },
                                value:
                                    assetC.assetsSelected.value.isNotEmpty
                                        ? assetC.assetsSelected.value
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Obx(
                              () =>
                                  assetC.isLoading.value
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : DropdownSearch<CategoryAssets>(
                                        selectedItem:
                                            assetC.catSelectedObj.value,
                                        enabled:
                                            assetC.dataCatAssets.isNotEmpty,
                                        items: (String filter, _) async {
                                          final allCat =
                                              assetC.dataCatAssets.toList();
                                          if (filter.isEmpty) return allCat;
                                          return allCat
                                              .where(
                                                (item) => item.catName!
                                                    .toLowerCase()
                                                    .contains(
                                                      filter.toLowerCase(),
                                                    ),
                                              )
                                              .toList();
                                        },
                                        itemAsString:
                                            (CategoryAssets item) =>
                                                item.catName!,
                                        compareFn: (a, b) => a.id == b.id,
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
                                        },
                                      ),
                            ),
                            const SizedBox(height: 5),
                            CsElevatedButton(
                              onPressed: () async {
                                addEditCat(context, '', '', '', '');
                                await assetC.getCatAssets({
                                  "type": "",
                                  "kelompok": assetC.assetsSelected.value,
                                });
                              },
                              size: const Size(160, 45),
                              color: mainColor,
                              fontsize: 16,
                              label: 'Tambah Kategori',
                            ),
                          ],
                        ),

                    const SizedBox(height: 5),

                    // Row/Kolom Nama Asset dan Serial Number
                    isWideScreen
                        ? Row(
                          children: [
                            Expanded(
                              child: CsTextField(
                                controller: assetC.asset,
                                maxLines: 1,
                                label: 'Nama Asset',
                                onFieldSubmitted: (val) async {
                                  loadingDialog("Memeriksa data", "");
                                  await assetC.verifiedAsset(
                                    val,
                                    assetC.assetsSelected.value,
                                  );
                                  Get.back();
                                  if (assetC.checkAssets.value.total == "1") {
                                    failedDialog(
                                      Get.context!,
                                      'ERROR',
                                      'Asset ini sudah terdaftar',
                                      isWideScreen,
                                    );
                                  } else {
                                    await assetC.assetsSubmit(
                                      id != "" ? "update_asset" : "add_asset",
                                      id,
                                      image,
                                      isWideScreen,
                                    );
                                    // // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    // catC.dataSource.notifyListeners();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: CsTextField(
                                controller: assetC.sn,
                                maxLines: 1,
                                label: 'Serial Number',
                                onFieldSubmitted: (val) async {
                                  loadingDialog("Memeriksa data", "");
                                  await assetC.verifiedAsset(
                                    assetC.asset.text,
                                    assetC.assetsSelected.value,
                                  );
                                  Get.back();
                                  if (assetC.checkAssets.value.total == "1") {
                                    failedDialog(
                                      Get.context!,
                                      'ERROR',
                                      'Asset ini sudah terdaftar',
                                      isWideScreen,
                                    );
                                  } else {
                                    await assetC.assetsSubmit(
                                      id != "" ? "update_asset" : "add_asset",
                                      id,
                                      image,
                                      isWideScreen,
                                    );
                                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    // catC.dataSource.notifyListeners();
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CsTextField(
                              controller: assetC.asset,
                              maxLines: 1,
                              label: 'Nama Asset',
                              onFieldSubmitted: (val) async {
                                await assetC.verifiedAsset(
                                  val,
                                  assetC.assetsSelected.value,
                                );
                                Get.back();
                                if (assetC.checkAssets.value.total == "1") {
                                  failedDialog(
                                    Get.context!,
                                    'ERROR',
                                    'Asset ini sudah terdaftar',
                                    isWideScreen,
                                  );
                                } else {
                                  await assetC.assetsSubmit(
                                    id != "" ? "update_asset" : "add_asset",
                                    id,
                                    image,
                                    isWideScreen,
                                  );
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  // catC.dataSource.notifyListeners();
                                }
                              },
                            ),
                            const SizedBox(height: 5),
                            CsTextField(
                              controller: assetC.sn,
                              maxLines: 1,
                              label: 'Serial Number',
                              onFieldSubmitted: (val) async {
                                await assetC.verifiedAsset(
                                  assetC.asset.text,
                                  assetC.assetsSelected.value,
                                );
                                Get.back();
                                if (assetC.checkAssets.value.total == "1") {
                                  failedDialog(
                                    Get.context!,
                                    'ERROR',
                                    'Asset ini sudah terdaftar',
                                    isWideScreen,
                                  );
                                } else {
                                  await assetC.assetsSubmit(
                                    id != "" ? "update_asset" : "add_asset",
                                    id,
                                    image,
                                    isWideScreen,
                                  );
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  // catC.dataSource.notifyListeners();
                                }
                              },
                            ),
                          ],
                        ),

                    const SizedBox(height: 5),

                    // Row/Kolom Tanggal Beli, Price, dan Satuan
                    isWideScreen
                        ? Row(
                          children: [
                            SizedBox(
                              width: 160,
                              child: DateTimeField(
                                controller: assetC.purchaseDate,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  prefixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  hintText: 'Tanggal Beli',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                                format: DateFormat("yyyy-MM-dd"),
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: CsTextField(
                                controller: assetC.price,
                                maxLines: 1,
                                label: 'Price',
                                onFieldSubmitted: (val) async {
                                  await assetC.verifiedAsset(
                                    assetC.asset.text,
                                    assetC.assetsSelected.value,
                                  );
                                  Get.back();
                                  if (assetC.checkAssets.value.total == "1") {
                                    failedDialog(
                                      Get.context!,
                                      'ERROR',
                                      'Asset ini sudah terdaftar',
                                      isWideScreen,
                                    );
                                  } else {
                                    await assetC.assetsSubmit(
                                      id != "" ? "update_asset" : "add_asset",
                                      id,
                                      image,
                                      isWideScreen,
                                    );
                                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    // catC.dataSource.notifyListeners();
                                  }
                                },
                                onChanged: (val) => assetC.countPrice(val),
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
                                    assetC.unitSelected.value != ""
                                        ? assetC.unitSelected.value
                                        : null,
                              ),
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              // width: 160,
                              child: DateTimeField(
                                controller: assetC.purchaseDate,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  prefixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  hintText: 'Tanggal Beli',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                                format: DateFormat("yyyy-MM-dd"),
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            CsTextField(
                              controller: assetC.price,
                              maxLines: 1,
                              label: 'Price',
                              onFieldSubmitted: (val) async {
                                await assetC.verifiedAsset(
                                  assetC.asset.text,
                                  assetC.assetsSelected.value,
                                );
                                Get.back();
                                if (assetC.checkAssets.value.total == "1") {
                                  failedDialog(
                                    Get.context!,
                                    'ERROR',
                                    'Asset ini sudah terdaftar',
                                    isWideScreen,
                                  );
                                } else {
                                  await assetC.assetsSubmit(
                                    id != "" ? "update_asset" : "add_asset",
                                    id,
                                    image,
                                    isWideScreen,
                                  );
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  // catC.dataSource.notifyListeners();
                                }
                              },
                              onChanged: (val) => assetC.countPrice(val),
                              inputFormatters: [CurrencyInputFormatter()],
                            ),
                            const SizedBox(height: 5),
                            CsDropDown(
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
                                  assetC.unitSelected.value != ""
                                      ? assetC.unitSelected.value
                                      : null,
                            ),
                          ],
                        ),

                    const SizedBox(height: 5),

                    // Row/Kolom Upload Image
                    isWideScreen
                        ? Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => assetC.pickAndUploadImage(),
                                child: ClipRRect(
                                  child: GetBuilder<MasterBarangController>(
                                    builder:
                                        (c) =>
                                            c.webImage != null
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.camera_alt),
                                                      Text(
                                                        'Click to upload image',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => assetC.pickAndUploadImage(),
                              child: ClipRRect(
                                child: GetBuilder<MasterBarangController>(
                                  builder:
                                      (c) =>
                                          c.webImage != null
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
                                                    Text(
                                                      'Click to upload image',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                ),
                              ),
                            ),
                            if (assetC.imagePath.value.isNotEmpty)
                              Text('Path: ${assetC.imagePath.value}'),
                          ],
                        ),
                  ],
                ),
              ),
              actions: [
                CsElevatedButton(
                  onPressed: () async {
                    if (assetC.formKeyAsset.currentState!.validate()) {
                      if (id!.isEmpty) {
                        await assetC.verifiedAsset(
                          assetC.asset.text,
                          assetC.assetsSelected.value,
                        );
                        Get.back();
                        if (assetC.checkAssets.value.total == "1") {
                          failedDialog(
                            Get.context!,
                            'ERROR',
                            'Asset ini sudah terdaftar',
                            isWideScreen,
                          );
                        } else {
                          await assetC.assetsSubmit(
                           "add_asset",
                            id,
                            image,
                            isWideScreen,
                          );
                        }
                      } else {
                        await assetC.assetsSubmit(
                          "update_asset",
                          id,
                          image,
                          isWideScreen,
                        );
                      }
                    }
                  },
                  color: Colors.blue,
                  fontsize: 12,
                  label: id != "" ? 'Update' : 'Submit',
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
