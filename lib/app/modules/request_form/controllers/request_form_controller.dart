import 'dart:convert';
import 'dart:math';

import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/models/request_model.dart';
import 'package:assets_management/app/modules/request_form/views/request_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../data/models/login_model.dart';

class RequestFormController extends GetxController {
  var isLoading = true.obs;
  var rowsPerPage = 10;
  var catAsset = <CategoryAssets>[].obs;
  var lstRequest = <RequestModel>[].obs;
  var dataRequestFiltered = RxList<RequestModel>([]);
  final searchController = TextEditingController();
  final requestTitle = TextEditingController();
  // final scanController = TextEditingController();
  late RequestData requestData;
  var total = 0.obs;
  var branchCode = "";
  var author = "";
  var tempData = <RequestDetailModel>[].obs;
  var tempAssetData = <RequestDetailModel>[].obs;
  var idReq = "";

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    branchCode = dataUser.kodeCabang!;
    getDataRequest();
    author = dataUser.nama!;
    requestData = RequestData(dataRequest: dataRequestFiltered);
    dataRequestFiltered.value = lstRequest;
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  getDataRequest() async {
    // Simulate a network request
    // await Future.delayed(Duration(seconds: 2));
    var data = {"type": "", "branch": branchCode};
    final response = await ServiceApi().request(data);
    lstRequest.value = response;
    isLoading.value = false;
    return lstRequest;
  }

  Future fetchCatAsset() async {
    var data = {"type": "get_cat_asset"};
    final response = await ServiceApi().getCatAsset(data);
    // isLoading.value = false;
    return catAsset.value = response;
  }

  void filterDataRequest(String val) {
    List<RequestModel> result = [];
    if (val.isEmpty) {
      result = lstRequest;
    } else {
      result =
          lstRequest
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.branch.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.date.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.desc.toString().toLowerCase().contains(val.toLowerCase()),
              )
              .toList();
    }
    dataRequestFiltered.value = result;
  }

  generateId() {
    var generateNum = Random().nextInt(1000000000);
    return idReq = 'URB/RF/$generateNum';
  }

  requestSubmit(String type, String? id) async {
    loadingDialog("Mengirim data", "");
    var idUpdate = id != "" ? id : "";
    var data = {
      "type": type,
      "request_id": idReq,
      "branch": branchCode,
      "desc": requestTitle.text,
      "created_by": author,
      "id": idUpdate,
    };
    // print(data);
    await ServiceApi().request(data);

    for (var lstData in tempData) {
      var dataList = {
        "type": "add_detail_request",
        "request_id": idReq,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "image": lstData.image,
        "qty_stock": lstData.qtyStock,
        "qty_req": lstData.qtyReq,
        "unit": lstData.unit,
        "price": lstData.price,
        "total":
            ((int.tryParse(lstData.price ?? '0') ?? 0) *
                    (int.tryParse(lstData.qtyReq ?? '0') ?? 0))
                .toString(),
      };

      // print(dataList);
      await ServiceApi().request(dataList);
    }

    // requestTitle.clear();
    // tempScanData.clear();
    await getDataRequest();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    requestData.notifyListeners();
    Get.back();
  }

  getReqItem(String val) async {
    tempData.clear();
    var data = {"type": "get_item_request", "branch": branchCode, "cat": val};
    final response = await ServiceApi().request(data);
    tempAssetData.value = response;
    isLoading.value = false;
    return tempAssetData;
  }
}
