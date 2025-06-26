import 'dart:async';
import 'dart:typed_data';
import 'package:assets_management/app/data/models/stock_detail_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/models/assets_model.dart';
import '../../../data/models/category_assets_model.dart';
import '../views/stock_view.dart';

class StokController extends GetxController {
  // late TextEditingController asset, ok, bad, stokAwal;
  final formKeyStok = GlobalKey<FormState>();
  var dateTimeNow = "";
  var branchCode = "";
  var dataCatAssets = <CategoryAssets>[].obs;
  var dataAssets = <AssetsModel>[].obs;
  var dataStok = <Stok>[].obs;
  var dataStokFiltered = RxList<Stok>([]);
  var dataDetailStok = <StockDetail>[].obs;
  var detailDataFiltered = RxList<StockDetail>([]);
  var isLoading = true.obs;
  var statusSelected = "".obs;
  var assetSelected = "".obs;
  var rowsPerPage = 10;
  var grandTotal = 0.obs;
  var searchDetail = TextEditingController();
  var searchController = TextEditingController();
  // late StokData dataSource;
  late final StokData dataSource;
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
    detailDataFiltered.value = dataDetailStok;
    dataSource = StokData(dataStok: dataStokFiltered);
    // dataSource = StokData(dataStok: dataStokFiltered);
  }

  void updateDateTime() {
    final now = DateTime.now();

    dateTimeNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

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

  Future<List<StockDetail>> getDetailStock(
    String type,
    String branchCode,
    String itemCode,
  ) async {
    var data = {"type": type, "cabang": branchCode, "asset_code": itemCode};
    final response = await ServiceApi().stokCRUD(data);
    // dataDetailStok.value = response;
    // grandTotal.value = dataDetailStok.fold(
    //   0,
    //   (prev, item) => prev + ((int.tryParse(item.qty ?? '0') ?? 0)),
    // );
    for (var item in response) {
      item.type = type; // misal properti type harus ada di StockDetail
    }
    return response;
  }

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
                    e.namaCabang.toString().toLowerCase().contains(
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

  void filterDetailStok(String val) {
    List<StockDetail> result = [];
    if (val.isEmpty) {
      result = dataDetailStok;
    } else {
      result =
          dataDetailStok
              .where(
                (e) =>
                    e.assetName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.cabang.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.qty.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.createdAt.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    detailDataFiltered.value = result;
  }
}
