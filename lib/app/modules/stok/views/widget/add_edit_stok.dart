// import 'package:assets_management/app/data/helper/custom_dialog.dart';
// import 'package:assets_management/app/data/shared/dropdown.dart';
// import 'package:assets_management/app/data/shared/elevated_button.dart';
// import 'package:assets_management/app/data/shared/text_field.dart';
// import 'package:assets_management/app/modules/stok/controllers/stok_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// final stokC = Get.put(StokController());

// addEditStok(BuildContext context, String? id, String? asset, String? category,
//     String? ok, String? bad, String? status) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Form(
//         key: stokC.formKeyStok,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         child: AlertDialog(
//           insetPadding: const EdgeInsets.all(8.0),
//           title: Text('${id != '' ? 'Edit' : ' Tambah'} Stok'),
//           content: Container(
//             width: MediaQuery.of(context).size.width / 3,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Obx(
//                         () => stokC.isLoading.value
//                             ? const Center(
//                                 child: CircularProgressIndicator(),
//                               )
//                             : CsDropDown(
//                                 label: 'Pilih Asset',
//                                 items: stokC.dataAssets
//                                     .map((data) => DropdownMenuItem(
//                                         value: data.assetsCode,
//                                         child: Text(data.assetName!)))
//                                     .toList(),
//                                 onChanged: (val) {
//                                   stokC.assetSelected.value = val;
//                                 },
//                                 value: stokC.assetSelected.value != ""
//                                     ? stokC.assetSelected.value
//                                     : null,
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CsTextField(
                        
//                         controller: stokC.stokAwal..text = asset!,
//                         label: 'Qty Stok',
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: CsTextField(
                        
//                         controller: stokC.ok..text = ok!,
//                         label: 'Qty GOOD',
//                         onChanged: (val) {
//                           if (int.parse(stokC.stokAwal.text) < int.parse(val)) {
//                             showToast("Qty Good tidak boleh melebihi Qty Stok",
//                                 "red");
//                           } else if ((int.parse(val) +
//                                   int.parse(stokC.bad.text)) >
//                               int.parse(stokC.stokAwal.text)) {
//                             showToast(
//                                 "Jumlah Qty Good + Qty Bad,  tidak boleh melebihi Qty Stok",
//                                 "red");
//                           } else if ((int.parse(val) +
//                                   int.parse(stokC.bad.text)) <
//                               int.parse(stokC.stokAwal.text)) {
//                             showToast(
//                                 "Jumlah Qty Good + Qty Bad,  tidak boleh kurang dari Qty Stok",
//                                 "red");
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: CsTextField(
                          
//                           controller: stokC.bad..text = bad!,
//                           label: 'QTY BAD',
//                           onChanged: (val) {
//                             if (int.parse(stokC.stokAwal.text) <
//                                 int.parse(val)) {
//                               showToast("Qty Bad tidak boleh melebihi Qty Stok",
//                                   "red");
//                             } else if ((int.parse(val) +
//                                     int.parse(stokC.ok.text)) >
//                                 int.parse(stokC.stokAwal.text)) {
//                               showToast(
//                                   "Jumlah Qty Good + Qty Bad,  tidak boleh melebihi Qty Stok",
//                                   "red");
//                             } else if ((int.parse(val) +
//                                     int.parse(stokC.ok.text)) <
//                                 int.parse(stokC.stokAwal.text)) {
//                               showToast(
//                                   "Jumlah Qty Good + Qty Bad,  tidak boleh kurang dari Qty Stok",
//                                   "red");
//                             }
//                           }),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 5,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             CsElevatedButton(
//               onPressed: () async {
//                 if (stokC.formKeyStok.currentState!.validate()) {
//                   await stokC.stokSubmit(
//                       id != "" ? "update_stok" : "add_stok", id);
//                 }
//                 //else {
//                 //   showToast('Asset tidak boleh kosong', 'red');
//                 // }
//               },
//               color: Colors.blue,
//               fontsize: 12,
//               label: 'Submit',
//             ),
//             CsElevatedButton(
//               onPressed: () {
//                 Get.back();
//                 stokC.webImage = null;
//                 stokC.assetSelected.value = "";
//                 stokC.statusSelected.value = "";
//                 stokC.formKeyStok.currentState!.reset();
//               },
//               color: Colors.red,
//               fontsize: 12,
//               label: 'Cancel',
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
