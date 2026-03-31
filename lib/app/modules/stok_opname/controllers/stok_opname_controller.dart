import 'dart:convert';
import 'dart:math';
import 'package:assets_management/app/data/models/so_detail_model.dart';
import 'package:assets_management/app/data/models/so_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/cabang_model.dart';
import '../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../data/models/login_model.dart';
import '../views/stok_opname_view.dart';

class StokOpnameController extends GetxController {
  var isLoading = true.obs;
  var dataSo = <SoModel>[].obs;
  var detailSo = <SoDetailModel>[].obs;
  var dataSoFiltered = RxList<SoModel>([]);
  var tempAssetData = <DetailBarangMasukKeluar>[].obs;
  var tempScanData = <SoDetailModel>[].obs;
  int rowsPerPage = 10;
  var fromBranch = "";
  var userName = "";
  var idTrx = "";
  var brand = "".obs;
  var levelUser = "";
  var lstBrand = <Cabang>[].obs;
  var lstBranch = <Cabang>[].obs;
  var branchCode = "".obs;
  var branchName = "".obs;
  late TextEditingController asset, desc, brnch, searchController;
  late SoDataSource dtSo;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    fromBranch = dataUser.kodeCabang!;
    userName = dataUser.nama!;
    levelUser = dataUser.levelUser!;
    desc = TextEditingController();
    searchController = TextEditingController();
    asset = TextEditingController();
    brnch = TextEditingController();
    dataSoFiltered.value = dataSo;
    getBrand();
    super.onInit();
  }

  @override
  void onClose() {
    super.dispose();
  }

  getBrand() async {
    final response = await ServiceApi().getBrandCabang();
    lstBrand.add(Cabang(brandCabang: 'Pilih Kelompok'));
    lstBrand.addAll(response);
    return lstBranch;
  }

  Future<List<Cabang>> getCabang(Map<String, dynamic> brand) async {
    final response = await ServiceApi().getCabang(brand);
    lstBranch.value = response;
    return lstBranch;
  }

  Future<List<DetailBarangMasukKeluar>> getAssetByDiv() async {
    var data = {"type": "", "group": ""};
    final response = await ServiceApi().getAsset(data);
    return tempAssetData.value = response!.detailBarangMasukKeluar;
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idTrx = 'INV/URB/SO/$generateNum';
  }

  Future fetchStockAsset(String barcode, String branchCode) async {
    // isLoading.value = true;
    var data = {
      "type": "get_asset",
      "barcode": barcode,
      "branch_code": branchCode,
    };
    // print(data);
    final response = await ServiceApi().getStockAsset(data);
    // isLoading.value = false;
    return tempAssetData.value = response!.detailBarangMasukKeluar;
  }

  getSoData() async {
    var data = {'type': ''};
    // print(data);
    final response = await ServiceApi().so(data);

    dataSo.value = response;
    isLoading.value = false;
    return dataSo;
  }

  editSo(String idSo) async {
    var data = {"type": "get_detail_so", "id": idSo};
    final response = await ServiceApi().so(data);
    return detailSo.value = response;
  }

  filterDataSo(String val) {
    List<SoModel> result = [];
    if (val.isEmpty) {
      result = dataSo;
    } else {
      result =
          dataSo
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.branchName.toString().toLowerCase().contains(
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
    dataSoFiltered.value = result;
  }

  bool get canSubmit {
    final hasAnyTemp = tempScanData.isNotEmpty;
    final hasAnyDetail = detailSo.isNotEmpty;

    final hasPositiveQtyInTemp = tempScanData.any(
      (e) =>
          int.tryParse(e.qtyNew.toString()) != null &&
              int.parse(e.qtyNew.toString()) > 0 ||
          int.tryParse(e.qtySec.toString()) != null &&
              int.parse(e.qtySec.toString()) > 0 ||
          int.tryParse(e.qtyBad.toString()) != null &&
              int.parse(e.qtyBad.toString()) > 0,
    );
    final hasPositiveQtyInDetail = detailSo.any(
      (e) =>
          int.tryParse(e.qtyNew.toString()) != null &&
              int.parse(e.qtyNew.toString()) > 0 ||
          int.tryParse(e.qtySec.toString()) != null &&
              int.parse(e.qtySec.toString()) > 0 ||
          int.tryParse(e.qtyBad.toString()) != null &&
              int.parse(e.qtyBad.toString()) > 0,
    );

    return (hasAnyTemp || hasAnyDetail) &&
        (hasPositiveQtyInTemp || hasPositiveQtyInDetail);
  }

  saveDataSo(String id, String type) async {
    var ttlInitQty =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.initStock.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.initStock.value) ?? 0),
            );

    var amount =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) =>
                  prev +
                  (int.tryParse(e.qtyNew.value) ?? 0) +
                  (int.tryParse(e.qtySec.value) ?? 0) +
                  (int.tryParse(e.qtyBad.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) =>
                  prev +
                  (int.tryParse(e.qtyNew.value) ?? 0) +
                  (int.tryParse(e.qtySec.value) ?? 0) +
                  (int.tryParse(e.qtyBad.value) ?? 0),
            );

    var diffQty =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.diffQty.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.diffQty.value) ?? 0),
            );
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": branchCode.value,
      "desc": desc.text,
      "ttl_init_qty": ttlInitQty.toString(),
      "scanned_qty": amount.toString(),
      "diff_qty": diffQty.toString(),
      "status": "OPEN",
      "created_by": userName,
    };

    // print(data);
    await ServiceApi().so(data);

    for (var lstData in detailSo.isNotEmpty ? detailSo : tempScanData) {
      var detailData = {
        "type": "add_detail_so",
        "id": id != "" ? id : idTrx,
        "branch_code": branchCode.value,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_init": lstData.initStock.value,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "diff": lstData.diffQty.value,
        "status": "OPEN",
        "created_by": userName,
      };
      // print(detailData);
      await ServiceApi().so(detailData);
    }
    await getSoData();
    generateNumbId();
    resetForm();

    Get.back();
    dialogMsgScsUpd('Info', 'Sukses');
  }

  processDataSo(String id, String type) async {
    var ttlInitQty =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.initStock.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.initStock.value) ?? 0),
            );

    var amount =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) =>
                  prev +
                  (int.tryParse(e.qtyNew.value) ?? 0) +
                  (int.tryParse(e.qtySec.value) ?? 0) +
                  (int.tryParse(e.qtyBad.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) =>
                  prev +
                  (int.tryParse(e.qtyNew.value) ?? 0) +
                  (int.tryParse(e.qtySec.value) ?? 0) +
                  (int.tryParse(e.qtyBad.value) ?? 0),
            );

    var diffQty =
        detailSo.isNotEmpty
            ? detailSo.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.diffQty.value) ?? 0),
            )
            : tempScanData.fold(
              0,
              (prev, e) => prev + (int.tryParse(e.diffQty.value) ?? 0),
            );
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "branch_code": branchCode.value,
      "desc": desc.text,
      "ttl_init_qty": ttlInitQty.toString(),
      "scanned_qty": amount.toString(),
      "diff_qty": diffQty.toString(),
      "status": "PROCESSED",
      "created_by": userName,
    };

    // print(data);
    await ServiceApi().so(data);

    for (var lstData in detailSo.isNotEmpty ? detailSo : tempScanData) {
      var detailData = {
        "type": "add_detail_so",
        "id": id != "" ? id : idTrx,
        "branch_code": branchCode.value,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "qty_init": lstData.initStock.value,
        "qty_new": lstData.qtyNew.value,
        "qty_sec": lstData.qtySec.value,
        "qty_bad": lstData.qtyBad.value,
        "diff": lstData.diffQty.value,
        "status": "PROCESSED",
        "created_by": userName,
      };
      // print(detailData);
      await ServiceApi().so(detailData);
    }
    await getSoData();
    generateNumbId();
    resetForm();

    Get.back();
    dialogMsgScsUpd('Info', 'Sukses');
  }

  void resetForm() {
    desc.clear();
    tempScanData.clear();
    detailSo.clear();
    brand.value = "";
    branchName.value = "";
    branchCode.value = "";
    brnch.clear();
    lstBranch.clear();
    asset.clear();
  }

  deleteSo(String id) async {
    var data = {"type": "delete_so", "id": id};
    await ServiceApi().so(data);
  }
}
