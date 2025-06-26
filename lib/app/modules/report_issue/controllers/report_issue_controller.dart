import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/helper/format_waktu.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/modules/report_issue/views/report_issue_view.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/login_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html';

class ReportIssueController extends GetxController {
  var isLoading = true.obs;
  var isEdit = false.obs;
  var isUpdate = false.obs;
  int rowsPerPage = 10;
  var branchCode = "";
  var author = "";
  var createdAt = "";
  var dateNow = DateFormat('yyyy-mm-dd').format(DateTime.now());
  var dataReport = <Report>[].obs;
  var detailDataReport = <Report>[].obs;
  var listPriority = ["", "P1", "P2", "P3"];
  var priorSelected = "".obs;
  var listStatus = ["", "DONE", "ON PROGRESS", "FOLLOW UP", "HOLD"];
  var statusSelected = "".obs;
  var dataReportFiltered = RxList<Report>([]);
  late ReportData dataSource;
  final formKeyReport = GlobalKey<FormState>();
  var progress = TextEditingController();
  var reportTitle = TextEditingController();
  var keterangan = TextEditingController();
  var issue = TextEditingController();
  final searchController = TextEditingController();
  File? file;
  Uint8List? webImage;
  String? ext;
  File? file2;
  Uint8List? webImage2;
  String? ext2;
  var idReport = "";
  var uId = "";
  var tempListReport = <Report>[].obs;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    branchCode = dataUser.kodeCabang!;
    author = dataUser.nama!;
    getReport();
    dataSource = ReportData(dataReport: dataReportFiltered);
    dataReportFiltered.value = dataReport;
  }

  @override
  void onClose() {
    super.onClose();
  }

  getReport() async {
    // var formData = FormData({"type": "", "branch":branchCode});

    var data = {"type": "", "branch": branchCode};
    final response = await ServiceApi().report(data);
    dataReport.value = response;
    isLoading.value = false;
    return dataReport;
  }

  getDetailReport(String id) async {
    var data = {"type": "detail_report", "id": id, "branch": branchCode};
    final response = await ServiceApi().report(data);
    detailDataReport.value = response;
    return detailDataReport;
  }

  updateReport(String id, bool isWideScreen) async {
    Get.back();
    loadingDialog("Memperbarui data", " ");
    for (var lstData in detailDataReport) {
      var data = {
        "type": "update_report",
        "branch": branchCode,
        "report_id": id,
        "priority": lstData.priority,
        "status": lstData.status,
        "keterangan": lstData.keterangan,
        "progress": lstData.progress,
        "issue": lstData.issue,
        "uid": lstData.uid,
        "report": lstData.report,
      };
      // print(data);
      await ServiceApi().report(data);
    }
    Get.back();
    succesDialog(
      Get.context,
      'Data berhasil diupdate',
      DialogType.success,
      'SUKSES',
      isWideScreen,
    );
    await getReport();
    // Get.back();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
  }

  void filterDataReport(String val) async {
    List<Report> result = [];
    if (val.isEmpty) {
      result = dataReport;
    } else {
      result =
          dataReport
              .where(
                (e) =>
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.cabang.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.id.toString().toLowerCase().contains(val.toLowerCase()) ||
                    e.report.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.date.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.status.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    dataReportFiltered.value = result;
  }

  pickAndUploadImage() {
    final uploadInput = FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((_) async {
      file = uploadInput.files?.first;

      if (file != null) {
        final reader = FileReader();
        reader.readAsArrayBuffer(file!);
        reader.onLoadEnd.listen((event) async {
          Uint8List bytes = reader.result as Uint8List;
          webImage = bytes;
          ext = uploadInput.files?.first.type.split('/').last;
          update();
          // await uploadImage(file.name, bytes);
        });
      }
    });
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idReport = 'URB/RPT/$generateNum';
  }

  generateUid() {
    var uid = const Uuid();
    return uId = 'UID_${uid.v4()}';
  }

  reportSubmit(String type, String? id) async {
    loadingDialog("Mengirim data", "");

    for (var lstData in tempListReport) {
      final formData = FormData({
        "type": "add_detail_report",
        "report_id": lstData.id,
        "branch": lstData.cabang,
        "report_desc": lstData.report,
        "uid": lstData.uid,
        'report_image':
            id == ""
                ? MultipartFile(
                  // webImage ?? defaultIMage,
                  base64Decode(lstData.imageBf!),
                  filename:
                      // webImage != null
                      //     ? '${report.text}.$ext'
                      //     : '${asset.text}.jpg',
                      '${lstData.report}.$ext',
                )
                : id != "" && lstData.imageBf != null
                ? MultipartFile(
                  base64Decode(lstData.imageBf!),
                  filename: '${lstData.report}.$ext',
                )
                : '',
      });

      // print(formData.fields);
      await ServiceApi().reportDetailSubmit(formData);
    }

    var data = {
      "type": type,
      "id": idReport,
      "branch": branchCode,
      // "status": "ON PROGRESS",
      "created_by": author,
    };
    // print(data);
    await ServiceApi().report(data);

    reportTitle.clear();
    webImage = null;
    tempListReport.clear();
    await getReport();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
    Get.back();
  }

  void printReport() async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.TableRow> rows = await _loadData();
    final List<pw.Row> header = await _loadHeader();

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
                  'Report & Maintenance',
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

  _loadHeader() {
    List<pw.Row> header = [];
    header.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            detailDataReport.isNotEmpty ? detailDataReport[0].cabang! : '',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.Text(
            'ID : ${detailDataReport[0].id!}',
            style: const pw.TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Created By')),
          pw.Text(': ${detailDataReport[0].createdBy!}'),
        ],
      ),
    );
    header.add(
      pw.Row(
        children: [
          pw.SizedBox(width: 90, child: pw.Text('Created At')),
          pw.Text(
            ': ${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(detailDataReport[0].date!))} ${detailDataReport[0].createdAt!}',
          ),
        ],
      ),
    );
    return header;
  }

  _loadData() async {
    List<pw.TableRow> rows = [];

    PdfColor getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'ON PROGRESS':
          return PdfColors.yellow700;
        case 'DONE':
          return PdfColors.green700;
        case 'HOLD':
          return PdfColors.red700;
        // case 'OPEN':
        //   return PdfColors.orange;
        default:
          return PdfColors.blue700;
      }
    }

    String autoNewLine(String input, {int maxChar = 20}) {
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
            'TANGGAL',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'IMAGE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'REPORT',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'PRIORITAS',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'STATUS',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'PROGRESS',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'ISSUE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'KETERANGAN',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
        ],
      ),
    );

    for (var data in detailDataReport) {
      var img1 = await http
          .get(Uri.parse('${ServiceApi().baseUrl}${data.imageBf!}'))
          .then((value) => value.bodyBytes);
      pw.MemoryImage image = pw.MemoryImage(img1);

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Text(
              FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(data.date!)),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Center(
              child: pw.Container(
                width: 40,
                height: 40,
                child: pw.Image(image),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                autoNewLine(data.report!),
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Text(
              data.priority!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: font),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Container(
                // margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  // vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: getStatusColor(data.status!),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    data.status!, // menambahkan nomor urut di depan status
                  ),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                autoNewLine(data.progress!),
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                autoNewLine(data.issue!),
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(2),
              child: pw.Text(
                autoNewLine(data.keterangan!),
                style: pw.TextStyle(font: font),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}
