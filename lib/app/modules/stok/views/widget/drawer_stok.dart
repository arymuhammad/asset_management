import 'package:assets_management/app/modules/stok/controllers/stok_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/models/login_model.dart';
import '../../../../data/shared/dropdown.dart';
import '../../../../data/shared/elevated_button_icon.dart';
import '../../../../data/shared/text_field.dart';

class DrawerStok extends StatelessWidget {
  DrawerStok({super.key, this.userData});
  final Data? userData;
  final stokC = Get.find<StokController>();
  final listDivisi = ["AUDIT", "IT"];
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // SizedBox(
            //   // width: 150,
            //   height: 35,
            //   child: CsTextField(
            //     controller: stokC.searchController,
            //     label: 'Search Data',
            //     maxLines: 1,
            //     onChanged: (val) {
            //       stokC.filterDataStok(val);
            //       // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
            //       stokC.dataSource.notifyListeners();
            //     },
            //   ),
            // ),
            // const SizedBox(height: 5),
            Visibility(
              visible:
                  userData!.kodeCabang == "HO000" &&
                          listDivisi.contains(
                            userData!.levelUser!.split(' ')[0],
                          )
                      ? true
                      : false,
              child: Obx(
                () => Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        // width: 170,
                        child: CsDropDown(
                          label: 'Pilih Brand',
                          items:
                              stokC.lstBrand
                                  .map(
                                    (data) => DropdownMenuItem(
                                      value: data.brandCabang!,
                                      child: Text(data.brandCabang!),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val == 'Pilih Brand') {
                              stokC.brand.value = "";
                              dialogMsg(
                                'Peringatan',
                                'Harap pilih cabang terlebih dulu',
                              );
                            } else {
                              stokC.brand.value = val;
                              stokC.selectedBranch.value = "";
                              // penerima = "";
                              stokC.toBranchName.clear();
                              stokC.selectedBranch.value = "";
                              stokC.selectedDivisi.value = '';
                              stokC.filterDataStok('');
                              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                              stokC.dataSource.notifyListeners();
                              // stokC.getCabang({
                              //   "brand": val,
                              // });
                            }
                            // stokC.catSelected.value = "";
                          },
                          value:
                              // kelompok != ""
                              //     ? stokC.assetsSelected.value = kelompok!
                              //     :
                              stokC.brand.value != ""
                                  ? stokC.brand.value
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
                      SizedBox(
                        // width: 180,
                        height: 35,
                        child: FutureBuilder(
                          future: stokC.getCabang({"brand": stokC.brand.value}),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var dataCabang = snapshot.data;
                              List<Map<String, String>> cabangList = [];
                              for (var data in dataCabang!) {
                                // Simpan data sebagai map dengan nama dan kode cabang
                                cabangList.add({
                                  "nama": data.namaCabang ?? '',
                                  "kode": data.kodeCabang ?? '',
                                });
                              }
                              return TypeAheadFormField<Map<String, String>>(
                                autoFlipDirection: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  enabled: stokC.brand.isEmpty ? false : true,
                                  focusNode: stokC.fcsBrand,
                                  controller: stokC.toBranchName,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(12),
                                    labelText: 'Pilih cabang',
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        stokC.selectedDivisi.value = "";
                                        stokC.toBranchName.clear();
                                        stokC.fcsBrand.requestFocus();
                                      },
                                      icon: const Icon(
                                        Icons.highlight_remove_rounded,
                                      ),
                                      splashRadius: 10,
                                    ),
                                  ),
                                ),
                                suggestionsCallback: (pattern) {
                                  return cabangList.where(
                                    (option) => option["nama"]!
                                        .toLowerCase()
                                        .contains(pattern.toLowerCase()),
                                  );
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    tileColor: Colors.white,
                                    title: Text(suggestion['nama'] ?? ""),
                                  );
                                },
                                onSuggestionSelected: (suggestion) async {
                                  stokC.toBranchName.text =
                                      suggestion["nama"] ?? "";
                                  // stokC.toBranch.text =
                                  //     suggestion["kode"] ?? "";
                                  stokC.selectedBranch.value =
                                      suggestion["kode"] ?? "";
                                  stokC.filterDataStok('');
                                  await stokC.getStok(
                                    stokC.selectedBranch.value,
                                    userData!.levelUser!.split(' ')[0],
                                  );
                                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                  stokC.dataSource.notifyListeners();
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text('Loading...'),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        // width: 240,
                        height: 35,
                        child: CsDropDown(
                          label: 'Pilih Divisi/Lokasi',
                          items:
                              stokC.divisi
                                  .map(
                                    (data) => DropdownMenuItem(
                                      value: data,
                                      child: Text(data),
                                    ),
                                  )
                                  .toList(),
                          value:
                              stokC.selectedDivisi.isNotEmpty
                                  ? stokC.selectedDivisi.value
                                  : null,
                          onChanged:
                              stokC.selectedBranch.isEmpty
                                  ? null
                                  : (val) {
                                    stokC.selectedDivisi.value = val;
                                    stokC.filterByDiv(val);
                                    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                    stokC.dataSource.notifyListeners();
                                  },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 5),
            // CsElevatedButtonIcon(
            //   icon: const Icon(Icons.print),
            //   fontSize: 13,
            //   onPressed: () async {
            //     loadingDialog("Memuat data", "");
            //     await stokC.getStok(
            //       stokC.selectedBranch.isNotEmpty
            //           ? stokC.selectedBranch.value
            //           : userData!.kodeCabang!,
            //       userData!.levelUser!.split(' ')[0],
            //     );
            //     Get.back();
            //     stokC.printStock(userData!.nama!, userData!.levelUser!);
            //     // Scaffold.of(context).openEndDrawer();
            //   },
            //   label: 'Print',
            //   size: const Size(60, 35),
            // ),
          ],
        ),
      ),
    );
  }
}
