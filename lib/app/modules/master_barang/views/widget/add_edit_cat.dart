import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/shared/elevated_button.dart';
import 'package:assets_management/app/data/shared/text_field.dart';
import 'package:assets_management/app/modules/master_barang/controllers/master_barang_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/shared/dropdown.dart';

final catC = Get.put(MasterBarangController());

addEditCat(
  BuildContext context,
  String? id,
  String? nama,
  String? deskripsi,
  String? assetsGroup,
) {
  showDialog(
    context: context,
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;
          return AlertDialog(
            title: Text('${id != '' ? 'Edit' : ' Tambah'} Kategori'),
            content: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Form(
                key: catC.formKeyCat,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CsDropDown(
                      label: 'Kelompok',
                      items:
                          catC.assetsGroup
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data,
                                  child: Text(data),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        catC.assetsSelected.value = val;
                      },
                      value:
                          catC.assetsSelected.value != ""
                              ? catC.assetsSelected.value
                              : assetsGroup != ""
                              ? assetsGroup
                              : null,
                    ),
                    const SizedBox(height: 5),
                    CsTextField(
                      controller: catC.catName..text = nama!,
                      maxLines: 1,
                      label: 'Nama Kategori Asset',
                      onFieldSubmitted: (val) async {
                        loadingDialog("Memeriksa data", "");
                        await catC.verifiedAssetCat(val);
                        Get.back();
                        if (catC.checkCatAssets.value.total == "1") {
                          failedDialog(
                            Get.context!,
                            'ERROR',
                            'Kategori ini sudah terdaftar',
                            isWideScreen
                          );
                        } else {
                          await catC.assetsCatSubmit(
                            id != "" ? "update_kategori" : "add_kategori",
                            id,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    CsTextField(
                      controller: catC.deskripsi..text = deskripsi!,
                      label: 'Deskripsi',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              CsElevatedButton(
                onPressed: () async {
                  if (catC.formKeyCat.currentState!.validate()) {
                    await catC.assetsCatSubmit(
                      id != "" ? "update_kategori" : "add_kategori",
                      id,
                    );
                    // } else {
                    //   showToast('Harap isi bagian yang kosong', 'red');
                  }
                },
                color: Colors.blue,
                fontsize: 12,
                label: 'Submit',
              ),
              CsElevatedButton(
                onPressed: () {
                  Get.back();
                  catC.formKeyCat.currentState!.reset();
                },
                color: Colors.red,
                fontsize: 12,
                label: 'Cancel',
              ),
            ],
          );
        },
      );
    },
  );
}
