import 'dart:convert';
import 'dart:math';

import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/currency_format.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/models/request_model.dart';
import 'package:assets_management/app/modules/request_form/views/request_form_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/helper/format_waktu.dart';
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
  var subTotal = 0.obs;
  var grandTotal = 0.obs;
  var branchCode = "";
  var author = "";
  var tempData = <RequestDetailModel>[].obs;
  var tempAssetData = <RequestDetailModel>[].obs;
  var detailRequest = <RequestDetailModel>[].obs;
  var idReq = "";
  var catSelected = "".obs;

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

  getDetailRequest(String reqId) async {
    var data = {"type": "detail_request", "req_id": reqId};
    final response = await ServiceApi().request(data);
    detailRequest.value = response;
    return detailRequest;
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
    Get.back();
    loadingDialog("Mengirim data", "");
    var idUpdate = id != "" ? id : "";
    var data = {
      "type": type,
      "request_id": idReq,
      "branch": branchCode,
      "cat": catSelected.value,
      "desc": requestTitle.text,
      "created_by": author,
      "id": idUpdate,
    };
    // print(data);
    await ServiceApi().request(data);

    for (var lstData in tempData) {
      if (lstData.qtyReq != "0") {
        int price = int.tryParse(lstData.price ?? '0') ?? 0;
        int qtyReq = int.tryParse(lstData.qtyReq ?? '0') ?? 0;
        int total = price * qtyReq;
        var dataList = {
          "type": "add_detail_request",
          "request_id": id != "" ? id : idReq,
          "asset_code": lstData.assetCode,
          "asset_name": lstData.assetName,
          "image": lstData.image,
          "qty_stock": lstData.qtyStock,
          "qty_req": lstData.qtyReq,
          "unit": lstData.unit,
          "price": lstData.price,
          "total": total.toString(),
        };

        // print(dataList);
        await ServiceApi().request(dataList);
      }
    }

    // requestTitle.clear();
    // tempScanData.clear();
    await getDataRequest();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    requestData.notifyListeners();
    // Get.back();
  }

  getReqItem(String val) async {
    tempData.clear();
    var data = {"type": "get_item_request", "branch": branchCode, "cat": val};
    final response = await ServiceApi().request(data);
    tempAssetData.value = response;
    isLoading.value = false;
    return tempAssetData;
  }

  void printReqForm() async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.TableRow> rows = await _loadData();
    final List<pw.Row> header = await _loadHeader();
    final List<pw.Container> footer = await _loadFooter();

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
                  'Request Form',
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
              pw.Column(children: footer),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  _loadData() async {
    List<pw.TableRow> rows = [];

    String autoNewLine(String input, {int maxChar = 30}) {
      if (input.length <= maxChar) return input;
      StringBuffer buffer = StringBuffer();
      for (int i = 0; i < input.length; i += maxChar) {
        int end = (i + maxChar < input.length) ? i + maxChar : input.length;
        buffer.write(input.substring(i, end));
        if (end != input.length) buffer.write('\n');
      }
      return buffer.toString();
    }

    final font = await PdfGoogleFonts.nunitoRegular();

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue700),
        children: [
          pw.Text(
            'Image',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Description',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Qty Stock',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Qty Req',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Price',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Sub Total',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
        ],
      ),
    );
    for (var data in detailRequest) {
      var img1 = await http
          .get(Uri.parse('${ServiceApi().baseUrl}${data.image!}'))
          .then((value) => value.bodyBytes);
      pw.MemoryImage image = pw.MemoryImage(img1);

      int price = int.tryParse(data.price ?? '0') ?? 0;
      int qtyReq = int.tryParse(data.qtyReq ?? '0') ?? 0;
      subTotal.value = qtyReq * price;
      grandTotal.value = tempData.fold(
        0,
        (prev, item) =>
            prev +
            ((int.tryParse(item.price ?? '0') ?? 0) *
                (int.tryParse(item.qtyReq ?? '0') ?? 0)),
      );
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Center(
              child: pw.Container(
                width: 60,
                height: 60,
                child: pw.Image(image),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                autoNewLine(data.assetName!),
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Text(
              data.qtyStock!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              data.qtyReq!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                textAlign: pw.TextAlign.right,
                CurrencyFormat.convertToIdr(int.tryParse(data.price!), 0),
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                textAlign: pw.TextAlign.right,
                CurrencyFormat.convertToIdr(subTotal.value, 0),
                style: pw.TextStyle(font: font),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }

  _loadHeader() {
    List<pw.Row> header = [];
    header.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            detailRequest.isNotEmpty ? detailRequest[0].namaCabang! : '',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            'ID : ${detailRequest[0].id!}',
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Created By')),
          pw.Text(': ${detailRequest[0].createdBy!}'),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Created At')),
          pw.Text(
            ': ${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(detailRequest[0].date!))}',
          ),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Keterangan')),
          pw.Text(': ${detailRequest[0].desc!}'),
        ],
      ),
    );
    return header;
  }

  _loadFooter() {
    List<pw.Container> footer = [];
    grandTotal.value = detailRequest.fold(
      0,
      (prev, item) =>
          prev +
          ((int.tryParse(item.price ?? '0') ?? 0) *
              (int.tryParse(item.qtyReq ?? '0') ?? 0)),
    );
    footer.add(
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black),
          color: PdfColors.grey,
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Total: ${CurrencyFormat.convertToIdr(grandTotal.value, 0)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    return footer;
  }
}
