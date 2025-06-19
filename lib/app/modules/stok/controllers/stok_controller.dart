import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/models/assets_model.dart';
import '../../../data/models/category_assets_model.dart';
import '../../../data/models/login_model.dart';

class StokController extends GetxController {
  // late TextEditingController asset, ok, bad, stokAwal;
  final formKeyStok = GlobalKey<FormState>();
  var dateTimeNow = "";
  var branchCode = "";
  var dataCatAssets = <CategoryAssets>[].obs;
  var dataAssets = <AssetsModel>[].obs;
  var dataStok = <Stok>[].obs;
  var dataStokFiltered = RxList<Stok>([]);
  var isLoading = true.obs;
  var statusSelected = "".obs;
  var assetSelected = "".obs;
  var rowsPerPage = 10;
  // late StokData dataSource;

  Uint8List? webImage;

  @override
  void onInit() async {
    super.onInit();
    // asset = TextEditingController();
    // ok = TextEditingController();
    // bad = TextEditingController();
    // stokAwal = TextEditingController();
    // getAssets();
    // getCatAssets();
    updateDateTime();
    // Update the time every second
    Timer.periodic(const Duration(seconds: 1), (Timer t) => updateDateTime());

    // getStok();
    dataStokFiltered.value = dataStok;
    // dataSource = StokData(dataStok: dataStokFiltered);
  }

  // @override
  // void onClose() {
  //   super.onClose();
  //   // asset.dispose();
  //   // ok.dispose();
  //   // bad.dispose();
  // }

  void updateDateTime() {
    final now = DateTime.now();

    dateTimeNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  // getCatAssets() async {
  //   var data = {"type": ""};
  //   isLoading.value;
  //   final response = await ServiceApi().assetsCatCRUD(data);
  //   dataCatAssets.value = response;
  //   isLoading.value = false;
  //   return dataCatAssets;
  // }

  // getAssets() async {
  //   var data = {"type": ""};
  //   isLoading.value;
  //   final response = await ServiceApi().assetsCRUD(data);
  //   dataAssets.value = [AssetsModel(assetName: "", assetsCode: "")];
  //   dataAssets.addAll(response);
  //   isLoading.value = false;
  //   return dataAssets;
  // }

  getStok(String branchCode) async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    // branchCode = dataUser.kodeCabang!;
    var data = {"type": "", "cabang": branchCode};
    final response = await ServiceApi().stokCRUD(data);
    dataStok.value = response;
    isLoading.value = false;
    return dataStok;
  }

  // stokSubmit(String? type, String? id) async {
  //   var idUpdate = id != "" ? id : "";
  //   var data = {
  //     "type": type!,
  //     "branch_code": branchCode,
  //     "barcode": assetSelected.value,
  //     "stok_awal": stokAwal.text,
  //     "qty_good": ok.text,
  //     "qty_bad": bad.text,
  //     "created_at": dateTimeNow,
  //     "id": idUpdate,
  //   };
  //   // print(data);
  //   if (assetSelected.value.isEmpty) {
  //     showToast("Harap Pilih Asset terlebih dahulu", "red");
  //   }
  //   if (int.parse(stokAwal.text) < int.parse(bad.text)) {
  //     showToast("Qty Bad tidak boleh melebihi Qty Stok", "red");
  //   } else if ((int.parse(bad.text) + int.parse(ok.text)) >
  //       int.parse(stokAwal.text)) {
  //     showToast(
  //       "Jumlah Qty Good + Qty Bad,  tidak boleh melebihi Qty Stok",
  //       "red",
  //     );
  //   } else if ((int.parse(bad.text) + int.parse(ok.text)) <
  //       int.parse(stokAwal.text)) {
  //     showToast(
  //       "Jumlah Qty Good + Qty Bad,  tidak boleh kurang dari Qty Stok",
  //       "red",
  //     );
  //   } else {
  //     await ServiceApi().stokCRUD(data);
  //     isLoading.value = true;
  //     await getStok();
  //   }
  // }

  void pickImg() async {
    webImage = await ImagePickerWeb.getImageAsBytes();
    if (webImage != null) {
      update();
    } else {
      return;
    }
  }

  void filterDataStok(String val) {
    List<Stok> result = [];
    if (val.isEmpty) {
      result = dataStok;
    } else {
      result =
          dataStok
              .where(
                (e) =>
                    e.assetName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.cabang.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.barcode.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.category.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    dataStokFiltered.value = result;
  }
}
