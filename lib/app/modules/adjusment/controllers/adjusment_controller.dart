import 'dart:convert';
import 'dart:math';

import 'package:assets_management/app/data/models/adj_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Repo/service_api.dart';
import '../../../data/models/detail_adj_model.dart';
import '../../../data/models/login_model.dart';
import '../views/adjusment_in.dart';
import '../views/adjusment_out.dart';

class AdjusmentController extends GetxController {
  var isLoading = true.obs;
  int rowsPerPage = 10;
  var dataAdjIn = <AdjModel>[].obs;
  var detailAdjIn = <DetailAdjModel>[].obs;
  var dataAdjInFiltered = RxList<AdjModel>([]);
  var dataAdjOut = <AdjModel>[].obs;
  var detailAdjOut = <DetailAdjModel>[].obs;
  var dataAdjOutFiltered = RxList<AdjModel>([]);
  late TextEditingController asset, desc, searchController;
  late AdjInDataSource dtAdjSource;
  late AdjOutDataSource dtAdjSourceOut;
  var idTrx = "";
  final formKey = GlobalKey<FormState>();
  var fromBranch = "";
  var levelUser = "";
  var author = "";
  var tempAssetData = <DetailAdjModel>[].obs;
  var tempScanData = <DetailAdjModel>[].obs;

  @override
  void onInit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    fromBranch = dataUser.kodeCabang!;
    levelUser = dataUser.levelUser!;
    author = dataUser.nama!;
    dataAdjInFiltered.value = dataAdjIn;
    dataAdjOutFiltered.value = dataAdjOut;
    asset = TextEditingController();
    // getAssetByDiv();
    desc = TextEditingController();
    searchController = TextEditingController();

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  generateNumbId({required bool adjIn}) {
    var generateNum = Random().nextInt(1000000000);

    return idTrx = 'INV/URB/ADJ-${adjIn?'IN':'OUT'}/$generateNum';
  }

  getAdjInData(String kodeCabang) async {
    var data = {'type': '', 'branch': kodeCabang};
    // print(data);
    final response = await ServiceApi().adjIn(data);

    dataAdjIn.value = response;
    isLoading.value = false;
    return dataAdjIn;
  }
  
  getAdjOutData(String kodeCabang) async {
    var data = {'type': '', 'branch': kodeCabang};
    // print(data);
    final response = await ServiceApi().adjOut(data);

    dataAdjOut.value = response;
    isLoading.value = false;
    return dataAdjOut;
  }

  editAdjIn(String idAdjIn) async {
    var data = {"type": "get_detail_adjIn", "id": idAdjIn};
    final response = await ServiceApi().adjIn(data);
    return detailAdjIn.value = response;
  }
  
  editAdjOut(String idAdjOut) async {
    var data = {"type": "get_detail_adjOut", "id": idAdjOut};
    final response = await ServiceApi().adjOut(data);
    return detailAdjOut.value = response;
  }

  bool get canSubmit {
    final hasAnyTemp = tempScanData.isNotEmpty;
    final hasAnyDetail = detailAdjIn.isNotEmpty;

    final hasPositiveQtyInTemp = tempScanData.any(
      (e) =>
          int.tryParse(e.qtyAdj.toString()) != null &&
          int.parse(e.qtyAdj.toString()) > 0,
    );
    final hasPositiveQtyInDetail = detailAdjIn.any(
      (e) =>
          int.tryParse(e.qtyAdj.toString()) != null &&
          int.parse(e.qtyAdj.toString()) > 0,
    );

    return (hasAnyTemp || hasAnyDetail) &&
        (hasPositiveQtyInTemp || hasPositiveQtyInDetail);
  }
 
  bool get canSubmitOut {
    final hasAnyTemp = tempScanData.isNotEmpty;
    final hasAnyDetail = detailAdjOut.isNotEmpty;

    final hasPositiveQtyInTemp = tempScanData.any(
      (e) =>
          int.tryParse(e.qtyAdj.toString()) != null &&
          int.parse(e.qtyAdj.toString()) > 0,
    );
    final hasPositiveQtyInDetail = detailAdjOut.any(
      (e) =>
          int.tryParse(e.qtyAdj.toString()) != null &&
          int.parse(e.qtyAdj.toString()) > 0,
    );

    return (hasAnyTemp || hasAnyDetail) &&
        (hasPositiveQtyInTemp || hasPositiveQtyInDetail);
  }

  filterAdjIn(String val) {
    List<AdjModel> result = [];
    if (val.isEmpty) {
      result = dataAdjIn;
    } else {
      result =
          dataAdjIn
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.branchName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.desc.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.date.toString().toLowerCase().contains(val.toLowerCase()),
              )
              .toList();
    }
    dataAdjInFiltered.value = result;
  }

  filterAdjOut(String val) {
    List<AdjModel> result = [];
    if (val.isEmpty) {
      result = dataAdjOut;
    } else {
      result =
          dataAdjOut
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.branchName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.desc.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.date.toString().toLowerCase().contains(val.toLowerCase()),
              )
              .toList();
    }
    dataAdjOutFiltered.value = result;
  }

  Future<List<DetailAdjModel>> getAssetByDiv() async {
    var data = {"type": "", "group": levelUser.split(' ')[0]};
    final response = await ServiceApi().getAsset(data);
    return tempAssetData.value = response!.detailAdj;
  }

  Future fetchStockAsset(String? barcode) async {
    // isLoading.value = true;
    var data = {
      "type": "get_asset",
      "barcode": barcode,
      "branch_code": fromBranch,
    };
    // print(data);
    final response = await ServiceApi().getStockAsset(data);
    // isLoading.value = false;
    return tempAssetData.value = response!.detailAdj;
  }

  saveAdjIn(String id, String type) async {
    var amount =
        detailAdjIn.isNotEmpty
            ? detailAdjIn
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": fromBranch,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "${id != "" ? "updated" : "created"}_by": author,
    };
    // print(data);
    await ServiceApi().adjIn(data);

    for (var lstData in detailAdjIn.isNotEmpty ? detailAdjIn : tempScanData) {
      var detailData = {
        "type": "add_detail_adjIn",
        "id": id != "" ? id : idTrx,
        "branch_code": fromBranch,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "qty_adj_in": lstData.qtyAdj.value,
        "status": "OPEN",
        "created_by": author,
      };
      // print(detailData);
      await ServiceApi().adjIn(detailData);
    }

    await getAdjInData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSource.notifyListeners();
    Get.back();
  }
 
  saveAdjOut(String id, String type) async {
    var amount =
        detailAdjOut.isNotEmpty
            ? detailAdjOut
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": fromBranch,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "${id != "" ? "updated" : "created"}_by": author,
    };
    // print(data);
    await ServiceApi().adjOut(data);

    for (var lstData in detailAdjOut.isNotEmpty ? detailAdjOut : tempScanData) {
      var detailData = {
        "type": "add_detail_adjOut",
        "id": id != "" ? id : idTrx,
        "branch_code": fromBranch,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "qty_adj_out": lstData.qtyAdj.value,
        "status": "OPEN",
        "created_by": author,
      };
      // print(detailData);
      await ServiceApi().adjOut(detailData);
    }

    await getAdjOutData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSourceOut.notifyListeners();
    Get.back();
  }

  submitAdjIn(String id, String type, String? desc, String? auth) async {
    var amount =
        detailAdjIn.isNotEmpty
            ? detailAdjIn
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));

    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": fromBranch,
      "desc": desc,
      "qty_amount": amount.toString(),
      "status": "Waiting for review",
      "created_by": (auth == null || auth.trim().isEmpty) ? author : auth,
      "updated_by": author,
    };
    await ServiceApi().adjIn(data);

    for (var lstData in detailAdjIn.isNotEmpty ? detailAdjIn : tempScanData) {
      var detailData = {
        "type": "add_detail_adjIn",
        "id": id != "" ? id : idTrx,
        "branch_code": fromBranch,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "qty_adj_in": lstData.qtyAdj.value,
        "status": "Waiting for review",
        "created_by": (auth == null || auth.trim().isEmpty) ? author : auth,
      };
      // print(detailData);
      await ServiceApi().adjIn(detailData);
    }
    await getAdjInData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSource.notifyListeners();
    Get.back();
  }
  
  submitAdjOut(String id, String type, String? desc, String? auth) async {
    var amount =
        detailAdjOut.isNotEmpty
            ? detailAdjOut
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyAdj)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));

    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": fromBranch,
      "desc": desc,
      "qty_amount": amount.toString(),
      "status": "Waiting for review",
      "created_by": (auth == null || auth.trim().isEmpty) ? author : auth,
      "updated_by": author,
    };
    await ServiceApi().adjOut(data);

    for (var lstData in detailAdjOut.isNotEmpty ? detailAdjOut : tempScanData) {
      var detailData = {
        "type": "add_detail_adjOut",
        "id": id != "" ? id : idTrx,
        "branch_code": fromBranch,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "qty_adj_out": lstData.qtyAdj.value,
        "status": "Waiting for review",
        "created_by": (auth == null || auth.trim().isEmpty) ? author : auth,
      };
      // print(detailData);
      await ServiceApi().adjOut(detailData);
    }
    await getAdjOutData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSourceOut.notifyListeners();
    Get.back();
  }

  deleteAdjIn(String id) async {
    var data = {"type": "delete_adjIn", "id": id};
    await ServiceApi().adjIn(data);
    await getAdjInData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSource.notifyListeners();
  }
 
  deleteAdjOut(String id) async {
    var data = {"type": "delete_adjOut", "id": id};
    await ServiceApi().adjOut(data);
    await getAdjOutData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSourceOut.notifyListeners();
  }

  rejectAdjIn(String id, String usr) async {
    var data = {"type": "reject_data", "updated_by": usr, "id": id};
    await ServiceApi().adjIn(data);
    await getAdjInData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSource.notifyListeners();
    resetForm();
    Get.back();
  }
 
  rejectAdjOut(String id, String usr) async {
    var data = {"type": "reject_data", "updated_by": usr, "id": id};
    await ServiceApi().adjOut(data);
    await getAdjOutData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSourceOut.notifyListeners();
    resetForm();
    Get.back();
  }

  acceptAdjIn(String id, String usr) async {
    var data = {"type": "accept_data", "updated_by": usr, "id": id};
    await ServiceApi().adjIn(data);
    await getAdjInData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSource.notifyListeners();
    resetForm();
    Get.back();
  }
 
  acceptAdjOut(String id, String usr) async {
    var data = {"type": "accept_data", "updated_by": usr, "id": id};
    await ServiceApi().adjOut(data);
    await getAdjOutData(fromBranch);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dtAdjSourceOut.notifyListeners();
    resetForm();
    Get.back();
  }

  void resetForm() {
    tempScanData.clear();
    detailAdjIn.clear();
    detailAdjOut.clear();
    desc.clear();
    filterAdjIn("");
    filterAdjOut("");
    // detailAdjIn.clear();
  }

}
