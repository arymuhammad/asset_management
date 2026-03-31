import 'dart:convert';
import 'dart:math';
import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/models/cabang_model.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/barang_masuk_keluar_model.dart';
import '../../../data/models/login_model.dart';
import '../views/stok_in_view.dart';

class BarangMasukController extends GetxController {
  var isLoading = true.obs;
  var dataStokIn = <BarangKeluarMasuk>[].obs;
  var detailStokIn = <DetailBarangMasukKeluar>[].obs;
  var dataStokInFiltered = RxList<BarangKeluarMasuk>([]);
  int rowsPerPage = 10;
  var lstBrand = <Cabang>[].obs;
  var brand = "".obs;
  var lstBranch = <Cabang>[].obs;
  var toBranch = "".obs;
  final formKey = GlobalKey<FormState>();
  var tempAssetData = <DetailBarangMasukKeluar>[].obs;
  var tempScanData = <DetailBarangMasukKeluar>[].obs;
  var finalTempScanData = [].obs;
  var idTrx = "";
  var fromBranch = "";
  var userName = "";
  var levelUser = "";
  late TextEditingController asset, desc, searchController;
  late StokInData dataSource;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    fromBranch = dataUser.kodeCabang!;
    userName = dataUser.nama!;
    // print(userName);
    levelUser = dataUser.levelUser!;
    // getStokInData(dataUser.kodeCabang!);
    dataStokInFiltered.value = dataStokIn;
    // dataSource = StokInData(dataStokIn: dataStokInFiltered);
    asset = TextEditingController();
    getBrand();
    // getAssetByDiv();
    desc = TextEditingController();
    searchController = TextEditingController();
  }

  @override
  void onClose() {
    // asset.dispose();
    super.dispose();
  }

  getBrand() async {
    final response = await ServiceApi().getBrandCabang();
    lstBrand.add(Cabang(brandCabang: 'Pilih Brand'));
    lstBrand.addAll(response);
    return lstBrand;
  }

  getCabang(Map<String, dynamic> brand) async {
    final response = await ServiceApi().getCabang(brand);
    lstBranch.value = response;
    return lstBranch;
  }

  getStokInData(String kodeCabang, String level) async {
    var data = {'type': '', 'to': kodeCabang, 'level_user': level};
    // print(data);
    final response = await ServiceApi().stokIn(data);

    dataStokIn.value = response;
    isLoading.value = false;
    return dataStokIn;
  }

  bool get canSubmit {
    final hasAnyTemp = tempScanData.isNotEmpty;
    final hasAnyDetail = detailStokIn.isNotEmpty;

    final hasPositiveQtyInTemp = tempScanData.any(
      (e) =>
          int.tryParse(e.qtyIn.toString()) != null &&
          int.parse(e.qtyIn.toString()) > 0,
    );
    final hasPositiveQtyInDetail = detailStokIn.any(
      (e) =>
          int.tryParse(e.qtyIn.toString()) != null &&
          int.parse(e.qtyIn.toString()) > 0,
    );

    return (hasAnyTemp || hasAnyDetail) &&
        (hasPositiveQtyInTemp || hasPositiveQtyInDetail);
  }

  filterDataStokIn(String val) {
    List<BarangKeluarMasuk> result = [];
    if (val.isEmpty) {
      result = dataStokIn;
    } else {
      result =
          dataStokIn
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.pengirim.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.desc.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.createdAt.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    dataStokInFiltered.value = result;
  }

  // Future fetchAsset(String? barcode) async {
  //   // isLoading.value = true;
  //   var data = {"type": "", "asset_code": barcode};
  //   final response = await ServiceApi().getAsset(data);
  //   // isLoading.value = false;
  //   return tempAssetData.value = response;
  // }

  Future<List<DetailBarangMasukKeluar>> getAssetByDiv() async {
    var data = {"type": "", "group": levelUser.split(' ')[0]};
    final response = await ServiceApi().getAsset(data);
    // print(data);
    return tempAssetData.value = response!.detailBarangMasukKeluar;
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idTrx = 'INV/URB/$generateNum';
  }

  saveDataIn(
    String id,
    String type,
    String? kodePenerima,
    String? kodePengirim,
  ) async {
    var amount =
        detailStokIn.isNotEmpty
            ? detailStokIn
                .map((e) => e.qtyIn)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyIn)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": kodePengirim != "" ? kodePengirim : fromBranch,
      "to": kodePenerima != "" ? kodePenerima : fromBranch,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "created_by": userName,
    };

    // print(data);
    await ServiceApi().stokIn(data);

    for (var lstData in detailStokIn.isNotEmpty ? detailStokIn : tempScanData) {
      var detailData = {
        "type": "add_detail_stokIn",
        "from": kodePengirim != "" ? kodePengirim : fromBranch,
        "to": kodePenerima != "" ? kodePenerima : fromBranch,
        "id": id != "" ? id : idTrx,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_in": lstData.qtyIn.value,
        "qty_new": lstData.neww.value,
        "qty_sec": lstData.sec.value,
        "qty_bad": lstData.bad.value,
        "status": "OPEN",
        "created_by": userName,
      };
      // print(detailData);
      await ServiceApi().stokIn(detailData);
    }
    await getStokInData(fromBranch, levelUser.split(' ')[0]);
    generateNumbId();
    asset.clear();
    tempScanData.clear();
    detailStokIn.clear();

    Get.back();
    dialogMsgScsUpd('Info', 'Sukses');
  }

  submitDataIn(
    String id,
    String type,
    String? kodePenerima,
    String? kodePengirim,
    String? description,
    String? auth,
  ) async {
    var amount =
        detailStokIn.isNotEmpty
            ? detailStokIn
                .map((e) => e.qtyIn)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyIn)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));

    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": kodePengirim != "" ? kodePengirim : fromBranch,
      "to": kodePenerima != "" ? kodePenerima : fromBranch,
      "desc": desc.text != "" ? desc.text : description!,
      "qty_amount": amount.toString(),
      "status": "CLOSED",
      "created_by": (auth == null || auth.trim().isEmpty) ? userName : auth,
      "updated_by": userName,
    };
    // print(data);
    await ServiceApi().stokIn(data);

    for (var lstData in detailStokIn.isNotEmpty ? detailStokIn : tempScanData) {
      var detailData = {
        "type": "add_detail_stokIn",
        "id": id != "" ? id : idTrx,
        "from": kodePengirim != "" ? kodePengirim : fromBranch,
        "to": kodePenerima != "" ? kodePenerima : fromBranch,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_in": lstData.qtyIn.value,
        "qty_new": lstData.neww.value,
        "qty_sec": lstData.sec.value,
        "qty_bad": lstData.bad.value,
        "status": "CLOSED",
        "created_by": (auth == null || auth.trim().isEmpty) ? userName : auth,
        "updated_by": userName,
      };
      // print(detailData);
      await ServiceApi().stokIn(detailData);
    }
    // var getStock = {"type": "", "cabang": fromBranch};
    // await ServiceApi().stokCRUD(getStock);
    await getStokInData(fromBranch, levelUser.split(' ')[0]);
    generateNumbId();
    asset.clear();
    tempScanData.clear();
    detailStokIn.clear();
    Get.back();
    dialogMsgScsUpd('Info', 'Sukses');
  }

  rejectDataIn(String id) async {
    var data = {"type": "reject_data", "id": id};
    await ServiceApi().stokIn(data);
    await getStokInData(fromBranch, levelUser.split(' ')[0]);
    filterDataStokIn("");
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
    Get.back();
  }

  editDataIn(String idStokIn) async {
    var data = {"type": "get_detail_stokIn", "id": idStokIn};
    final response = await ServiceApi().stokIn(data);
    return detailStokIn.value = response;
  }

  deleteStokIn(String id) async {
    var data = {"type": "delete_stokIn", "id": id};
    await ServiceApi().stokIn(data);
    await getStokInData(fromBranch, levelUser.split(' ')[0]);
    filterDataStokIn("");
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
  }
}
