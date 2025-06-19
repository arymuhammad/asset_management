import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Repo/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/barang_masuk_keluar_model.dart';
import '../../../data/models/cabang_model.dart';
import '../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../data/models/login_model.dart';
import '../views/stok_out_view.dart';

class BarangKeluarController extends GetxController {
  var isLoading = true.obs;
  var dataStokOut = <BarangKeluarMasuk>[].obs;
  var detailStokOut = <DetailBarangMasukKeluar>[].obs;
  var dataStokOutFiltered = RxList<BarangKeluarMasuk>([]);
  int rowsPerPage = 10;
  var lstBrand = <Cabang>[].obs;
  var brand = "".obs;
  var lstBranch = <Cabang>[].obs;
  var toBranch = "".obs;
  final formKey = GlobalKey<FormState>();
  var tempAssetData = <DetailBarangMasukKeluar>[].obs;
  var tempScanData = [].obs;
  var finalTempScanData = [].obs;
  var idTrx = "";
  var fromBranch = "";
  var author = "";
  late TextEditingController scanInput, desc;
  late StokOutData dataSource;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    fromBranch = dataUser.kodeCabang!;
    author = dataUser.nama!;
    // super.onInit();
    getStokOutData(dataUser.kodeCabang!);
    dataStokOutFiltered.value = dataStokOut;
    // dataSource = StokOutData(dataStokOut: dataStokOutFiltered);
    getBrand();
    scanInput = TextEditingController();
    desc = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
    // scanInput.dispose();
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

  getStokOutData(String kodeCabang) async {
    var data = {'type': '', 'from': kodeCabang};
    final response = await ServiceApi().stokOut(data);
    dataStokOut.value = response;
    isLoading.value = false;
    return dataStokOut;
  }

  filterDataStokOut(String val) {
    List<BarangKeluarMasuk> result = [];
    if (val.isEmpty) {
      result = dataStokOut;
    } else {
      result =
          dataStokOut
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.penerima.toString().toLowerCase().contains(
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
    dataStokOutFiltered.value = result;
  }

  Future fetchStockAsset(String? barcode) async {
    // isLoading.value = true;
    var data = {
      "type": "get_asset",
      "barcode": barcode,
      "branch_code": fromBranch,
    };
    final response = await ServiceApi().getStockAsset(data);
    // isLoading.value = false;
    return tempAssetData.value = response;
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idTrx = 'INV/URB/$generateNum';
  }

  saveDataIn(String id, String type) async {
    Get.back();
    loadingDialog("Mengirim data", "");

    var amount =
        detailStokOut.isNotEmpty
            ? detailStokOut
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty!))
            : tempScanData
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty));
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.value,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "created_by": author,
    };

    // print(data);
    await ServiceApi().stokOut(data);

    for (var lstData
        in detailStokOut.isNotEmpty ? detailStokOut : tempScanData) {
      var detailData = {
        "type": "add_detail_stokOut",
        "from": fromBranch,
        "to": toBranch.value,
        "id": id != "" ? id : idTrx,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_out": lstData.qtyOut,
        "qty_good": lstData.good,
        "qty_bad": lstData.bad,
        "status": "OPEN",
      };
      // print(detailData);
      await ServiceApi().stokOut(detailData);
    }
    scanInput.clear();
    tempScanData.clear();
    brand.value = "";
    toBranch.value = "";
    detailStokOut.clear();
    desc.clear();

    Get.back();
    dialogMsgScsUpd('Info', 'Sukses\nData tersimpan');
  }

  submitDataIn(String id, String type) async {
    Get.back();
    loadingDialog("Mengirim data", "");

    var amount =
        detailStokOut.isNotEmpty
            ? detailStokOut
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty!))
            : tempScanData
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty));

    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.value,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "CLOSED",
      "created_by": author,
    };

    var dataIn = {
      "type": "add_stokIn",
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.value,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "created_by": author,
    };
    // print(data);
    await ServiceApi().stokOut(data);
    await ServiceApi().stokIn(dataIn);

    for (var lstData
        in detailStokOut.isNotEmpty ? detailStokOut : tempScanData) {
      var detailData = {
        "type": "add_detail_stokOut",
        "id": id != "" ? id : idTrx,
        "from": fromBranch,
        "to": toBranch.value,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_out": lstData.qtyOut,
        "qty_good": lstData.good,
        "qty_bad": lstData.bad,
        "status": "CLOSED",
      };

      var detailDataIn = {
        "type": "add_detail_stokIn",
        "id": id != "" ? id : idTrx,
        "from": fromBranch,
        "to": toBranch.value,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_in": lstData.qtyOut,
        "qty_good": lstData.good,
        "qty_bad": lstData.bad,
        "status": "OPEN",
      };
      // print(detailData);
      await ServiceApi().stokOut(detailData);
      await ServiceApi().stokIn(detailDataIn);
    }
    // var getStock = {"type": "", "cabang": fromBranch};
    // await ServiceApi().stokCRUD(getStock);

    Get.back();
    dialogMsgScsUpd('Info', 'Sukses\nData tersimpan');
  }

  editDataOut(String idStokOut) async {
    var data = {"type": "get_detail_stokOut", "id": idStokOut};
    final response = await ServiceApi().stokOut(data);
    return detailStokOut.value = response;
  }

  deleteStokOut(String id) async {
    var data = {"type": "delete_stokOut", "id": id};
    await ServiceApi().stokOut(data);
  }
}
