import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Repo/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/models/barang_masuk_keluar_model.dart';
import '../../../data/models/cabang_model.dart';
import '../../../data/models/detail_barang_masuk_keluar_model.dart';
import '../../../data/models/login_model.dart';
import '../views/stok_out_view.dart';

class BarangKeluarController extends GetxController {
  var isEnable = true.obs;
  var isLoading = true.obs;
  var dataStokOut = <BarangKeluarMasuk>[].obs;
  var detailStokOut = <DetailBarangMasukKeluar>[].obs;
  var dataStokOutFiltered = RxList<BarangKeluarMasuk>([]);
  int rowsPerPage = 10;
  var lstBrand = <Cabang>[].obs;
  var brand = "".obs;
  var lstBranch = <Cabang>[].obs;
  // var toBranch = "".obs;
  final formKey = GlobalKey<FormState>();
  var tempAssetData = <DetailBarangMasukKeluar>[].obs;
  var tempScanData = <DetailBarangMasukKeluar>[].obs;
  var finalTempScanData = [].obs;
  var idTrx = "";
  var fromBranch = "";
  var author = "";
  var levelUser = "";
  late TextEditingController asset,
      desc,
      searchController,
      toBranch,
      toBranchName;
  late StokOutData dataSourceOut;

  @override
  Future<void> onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    fromBranch = dataUser.kodeCabang!;
    author = dataUser.nama!;
    levelUser = dataUser.levelUser!;
    // super.onInit();
    // getStokOutData(dataUser.kodeCabang!);
    dataStokOutFiltered.value = dataStokOut;
    // dataSource = StokOutData(dataStokOut: dataStokOutFiltered);
    getBrand();
    asset = TextEditingController();
    desc = TextEditingController();
    searchController = TextEditingController();
    toBranch = TextEditingController();
    toBranchName = TextEditingController();
  }

  getBrand() async {
    final response = await ServiceApi().getBrandCabang();
    lstBrand.add(Cabang(brandCabang: 'Pilih Brand'));
    lstBrand.addAll(response);
    return lstBrand;
  }

  Future<List<Cabang>> getCabang(Map<String, dynamic> brand) async {
    final response = await ServiceApi().getCabang(brand);
    lstBranch.value = response;
    return lstBranch;
  }

  getStokOutData(String kodeCabang, String level) async {
    var data = {'type': '', 'from': kodeCabang, "level_user": level};
    // print(data);
    final response = await ServiceApi().stokOut(data);
    dataStokOut.value = response;
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
                    e.qtyAmount.toString().toLowerCase().contains(
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
    // print(data);
    final response = await ServiceApi().getStockAsset(data);
    // isLoading.value = false;
    return tempAssetData.value = response!.detailBarangMasukKeluar;
  }

  Future<List<DetailBarangMasukKeluar>> getAssetByDiv() async {
    var data = {"type": "", "group": levelUser.split(' ')[0]};
    final response = await ServiceApi().getAsset(data);
    return tempAssetData.value = response!.detailBarangMasukKeluar;
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idTrx = 'INV/URB/$generateNum';
  }

  saveDataOut(String id, String type) async {
    var amount =
        detailStokOut.isNotEmpty
            ? detailStokOut
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));
    // print(amount);
    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.text,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "OPEN",
      "${id != "" ? "updated" : "created"}_by": author,
    };

    // print(data);
    await ServiceApi().stokOut(data);

    for (var lstData
        in detailStokOut.isNotEmpty ? detailStokOut : tempScanData) {
      var detailData = {
        "type": "add_detail_stokOut",
        "from": fromBranch,
        "to": toBranch.text,
        "id": id != "" ? id : idTrx,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "soh": lstData.soh,
        "qty_out": lstData.qtyOut.value,
        "qty_new": lstData.neww.value,
        "qty_sec": lstData.sec.value,
        "qty_bad": lstData.bad.value,
        "status": "OPEN",
        "created_by": author,
      };
      // print(detailData);
      await ServiceApi().stokOut(detailData);
    }
    asset.clear();
    tempScanData.clear();
    brand.value = "";
    toBranch.clear();
    toBranchName.clear();
    detailStokOut.clear();
    desc.clear();

    await getStokOutData(fromBranch, levelUser.split(' ')[0]);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSourceOut.notifyListeners();
    generateNumbId();
    Get.back();
    dialogMsgScsUpd('Info', 'Sukses\nData tersimpan');
  }

  submitDataOut(String id, String type) async {
    var amount =
        detailStokOut.isNotEmpty
            ? detailStokOut
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty.value))
            : tempScanData
                .map((e) => e.qtyOut)
                .fold(0, (prev, qty) => prev + int.parse(qty.value));

    var data = {
      "type": type,
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.text,
      "desc": desc.text,
      "qty_amount": amount.toString(),
      "status": "CLOSED",
      "created_by": author,
    };

    var dataIn = {
      "type": "add_stokIn",
      "id": id != "" ? id : idTrx,
      "from": fromBranch,
      "to": toBranch.text,
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
        "to": toBranch.text,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "soh": lstData.qtyTotal,
        "qty_out": lstData.qtyOut.value,
        "qty_new": lstData.neww.value,
        "qty_sec": lstData.sec.value,
        "qty_bad": lstData.bad.value,
        "status": "CLOSED",
        "created_by": author,
      };

      var detailDataIn = {
        "type": "add_detail_stokIn",
        "id": id != "" ? id : idTrx,
        "from": fromBranch,
        "to": toBranch.text,
        "asset_code": lstData.assetCode,
        "asset_name": lstData.assetName,
        "group": lstData.group,
        "qty_in": lstData.qtyOut.value,
        "qty_new": lstData.neww.value,
        "qty_sec": lstData.sec.value,
        "qty_bad": lstData.bad.value,
        "status": "OPEN",
        "created_by": author,
      };
      // print(detailData);
      await ServiceApi().stokOut(detailData);
      await ServiceApi().stokIn(detailDataIn);
    }
    // var getStock = {"type": "", "cabang": fromBranch};
    // await ServiceApi().stokCRUD(getStock);
    detailStokOut.clear();
    toBranch.clear();
    toBranchName.clear();
    Get.back();
    dialogMsgScsUpd('Info', 'Sukses\nData tersimpan');
    await getStokOutData(fromBranch, levelUser.split(' ')[0]);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSourceOut.notifyListeners();
    generateNumbId();
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

  void printDoc({String? id, String? penerima, String? pembuat}) async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.Row> header = await _loadHeaderDoc(
      id: id,
      penerima: penerima,
      pembuat: pembuat,
    );
    final List<pw.TableRow> rows = await _loadDataDoc();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          pageFormat: PdfPageFormat.a4.landscape,
        ),
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  'Barang Keluar',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Column(children: header),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Table(border: pw.TableBorder.all(), children: rows),
              ),
            ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  _loadHeaderDoc({String? id, String? penerima, String? pembuat}) {
    List<pw.Row> header = [];
    header.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.SizedBox(width: 90, child: pw.Text('Penerima')),
              pw.Text(
                ': $penerima',
                // style: const pw.TextStyle(fontSize: 15)
              ),
            ],
          ),
          pw.Text(
            'ID : $id',
            // style: const pw.TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Nama')),
          pw.Text(': $pembuat'),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Tanggal Buat')),
          pw.Text(
            ': ${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(detailStokOut[0].createdAt!))}',
          ),
        ],
      ),
    );
    return header;
  }

  _loadDataDoc() async {
    final font = await PdfGoogleFonts.nunitoRegular();
    List<pw.TableRow> rows = [];

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue700),
        children: [
          pw.Text(
            'Asset Name',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Asset Code',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Qty New',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Qty Sec',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Qty Bad',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Total',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
        ],
      ),
    );

    for (var data in detailStokOut) {
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                data.assetName!,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: font),
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 90,
                child: pw.Text(
                  data.assetCode!,
                  // autoNewLine(data.report!),
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                data.neww.value,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 40,
                child: pw.Text(
                  data.sec.value,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 40,
                child: pw.Text(
                  data.bad.value,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 30,
                child: pw.Text(
                  data.qtyOut.value,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}
