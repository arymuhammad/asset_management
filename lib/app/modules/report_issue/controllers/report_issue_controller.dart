import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:assets_management/app/data/models/report_by_store_model.dart';
import 'package:flutter/scheduler.dart';
import 'package:image/image.dart' as img;
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
// import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/login_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import '../views/widget/report_list.dart';

enum ReportViewMode { list, detail }

class ReportIssueController extends GetxController {
  var isLoading = true.obs;
  var isEdit = false.obs;
  var isUpdate = false.obs;
  var isExpanded = false.obs;
  int rowsPerPage = 10;
  var branchCode = "";
  var levelId = "";
  var div = "";
  var userId = "";
  var author = "";
  var createdAt = "";
  var dateNow = TextEditingController();
  var dataReport = <Report>[].obs;
  var dataReportByStore = <ReportByStore>[].obs;
  var detailDataReport = <Report>[].obs;
  var listPriority = ["", "P1", "P2", "P3"];
  var priorSelected = "".obs;
  var listStatus = ["", "FU", "DONE", "ON PRGS", "RE SCHE"];
  var statusSelected = "".obs;
  var reportDiv = ["", "Brand", "IT"];
  var selectedReportDiv = "".obs;
  var dataReportFiltered = RxList<Report>([]);
  var dataReportByStoreFiltered = RxList<ReportByStore>([]);
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
  var idReport = TextEditingController();
  var uId = "";
  var tempListReport = <Report>[].obs;
  Offset tapPosition = Offset.zero;
  Map<String, Uint8List?> webImage2Map = {};
  StreamSubscription<MouseEvent>? contextMenuSubscription;
  var initDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
            ),
          )
          .obs;
  var endDate =
      DateFormat('yyyy-MM-dd')
          .format(
            DateTime.parse(
              DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ).toString(),
            ),
          )
          .obs;

  var datePeriode = TextEditingController();
  var isReady = false.obs;
  late ReportData dataSource;
  ReportListStore? dataListStore;

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    branchCode = dataUser.kodeCabang!;
    levelId = dataUser.level!;
    div = dataUser.levelUser!.split(' ')[0];
    userId = dataUser.id!;
    author = dataUser.nama!;
    await getReportListStore();
    await getReport(branchCode);
    dataReportFiltered.value = dataReport;
    dataReportByStoreFiltered.value = dataReportByStore;
    dataSource = ReportData(dataReport: dataReportFiltered, dataUser: dataUser);
    dataListStore = ReportListStore(
      dataListStore: dataReportByStoreFiltered,
      userData: dataUser,
    );
    isReady.value = true;
    // dataSource.notifyListeners();
  }

  // Method untuk disable klik kanan (menambah listener)
  void disableRightClick() {
    // Cek agar listener tidak double pasang
    contextMenuSubscription ??= document.onContextMenu.listen((
      MouseEvent event,
    ) {
      event.preventDefault(); // mematikan klik kanan default
    });
  }

  // Method untuk enable klik kanan (menghapus listener)
  void enableRightClick() {
    contextMenuSubscription?.cancel();
    contextMenuSubscription = null;
  }

  @override
  void onClose() {
    // Pastikan listener dihapus saat controller dihapus (lifecycle cleanup)
    enableRightClick();
    super.onClose();
  }

  final viewMode = ReportViewMode.list.obs;

  // data detail yang dipilih
  Rx<ReportByStore?> selectedStore = Rx<ReportByStore?>(null);

  void showDetail(ReportByStore store) {
    selectedStore.value = store;
    viewMode.value = ReportViewMode.detail;
  }

  void backToList() {
    selectedStore.value = null;
    viewMode.value = ReportViewMode.list;
  }

  generateNumbId() {
    var generateNum = Random().nextInt(1000000000);
    return idReport.text = 'URB/RPT/$generateNum';
  }

  generateUid() {
    var uid = const Uuid();
    return uId = 'UID_${uid.v4()}';
  }

  getReportListStore() async {
    var data = {
      "div": div,
      // "type": "rekap_by_branch",
      "type": "branches",
      "branch": branchCode,
      "level_id": levelId,
      "user_id": userId,
      // "date1": initDate.value,
      // "date2": endDate.value,
    };
    final response = await ServiceApi().report(data);
    // print(data);
    dataReportByStore.value = response;
    isLoading.value = false;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // dataSource.notifyListeners();
    return dataReportByStore;
  }

  getReport(branch) async {
    var data = {
      "div": div,
      "type": "",
      "branch": branch,
      "level_id": levelId,
      "user_id": userId,
      // "date1": initDate.value,
      // "date2": endDate.value,
    };
    final response = await ServiceApi().report(data);
    // print(data);
    dataReport.value = response;
    isLoading.value = false;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    // dataSource.notifyListeners();
    return dataReport;
  }

  getReportBySts(String sts, String branch) async {
    var data = {
      "type": "get_by_sts",
      "div": div,
      "branch": branch,
      "sts": sts,
      "level_id": levelId,
      "user_id": userId,
    };
    final response = await ServiceApi().report(data);
    // print(data);
    dataReport.value = response;
    isLoading.value = false;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
    return dataReport;
  }

  getDetailReport(String userBranch, String reportBranch, String uid) async {
    var data = {
      "type": "detail_report",
      "div": div,
      "user_branch": userBranch,
      "report_branch": reportBranch,
      "uid": uid,
    };
    // print(data);
    final response = await ServiceApi().report(data);
    detailDataReport.value = response;
    return detailDataReport;
  }

  // Fungsi kecil untuk kompres gambar
  Uint8List compressImage(
    Uint8List originalBytes, {
    int maxWidth = 800,
    int quality = 100,
  }) {
    img.Image? image = img.decodeImage(originalBytes);
    if (image == null) return originalBytes;

    // Resize image dengan menjaga aspect ratio, maxWidth default 800px
    img.Image resized = img.copyResize(image, width: maxWidth);

    // Encode ulang ke JPEG dengan quality rendah (skala 0-100)
    List<int> compressed = img.encodeJpg(resized, quality: quality);

    return Uint8List.fromList(compressed);
  }

  pickAndUploadImage() {
    final uploadInput = FileUploadInputElement()..accept = 'image/*';
    uploadInput.setAttribute(
      'capture',
      'environment',
    ); // atau 'user' untuk kamera depan
    uploadInput.click();

    uploadInput.onChange.listen((_) async {
      file = uploadInput.files?.first;

      if (file != null) {
        final reader = FileReader();
        reader.readAsArrayBuffer(file!);
        reader.onLoadEnd.listen((event) async {
          Uint8List bytes = reader.result as Uint8List;
          // Uint8List compressedBytes = compressImage(bytes);
          webImage = bytes;
          ext = 'jpg';
          update();
          // await uploadImage(file.name, bytes);
        });
      }
    });
  }

  pickAndUploadImageAfter() async {
    final uploadInput2 = FileUploadInputElement()..accept = 'image/*';
    uploadInput2.setAttribute(
      'capture',
      'environment',
    ); // atau 'user' untuk kamera depan
    uploadInput2.click();

    uploadInput2.onChange.listen((_) async {
      file2 = uploadInput2.files?.first;

      if (file2 != null) {
        final reader2 = FileReader();
        reader2.readAsArrayBuffer(file2!);
        reader2.onLoadEnd.listen((event) async {
          Uint8List bytes = reader2.result as Uint8List;
          // Uint8List compressedBytes = compressImage(bytes);
          // webImage2Map[uid] = bytes;
          webImage2 = bytes;
          ext2 = 'jpg';
          update();
          // await uploadImage(file.name, bytes);
        });
      }
    });
  }

  Future<void> downloadImageBf(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // setState(() {
        webImage = response.bodyBytes; // simpan sebagai Uint8List
        // });
        print("Image downloaded, length: ${webImage!.length}");
      } else {
        print("Failed to download image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
  }

  Future<void> downloadImageAf(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // setState(() {
        webImage2 = response.bodyBytes; // simpan sebagai Uint8List
        // });
        print("Image downloaded, length: ${webImage!.length}");
      } else {
        print("Failed to download image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
  }

  submitReport(String type, String? uid, String? kodeCabang) async {
    Get.back();
    loadingDialog("Mengirim data", "");

    try {
      for (var lstData in tempListReport) {
        var formData = FormData(<String, dynamic>{});

        if (uid!.isNotEmpty) {
          String cleanBase64Af =
              (lstData.imageAf ?? '')
                  .replaceAll('\n', '')
                  .replaceAll('\r', '')
                  .trim();
          if (cleanBase64Af.isEmpty) continue;

          Uint8List originalBytesAf = base64Decode(cleanBase64Af);
          Uint8List compressedBytesAf = await Future.delayed(
            const Duration(seconds: 1),
            () => compressImage(originalBytesAf),
          );

          String baseFilenameAf = (lstData.report ?? 'file')
              .substring(
                0,
                (lstData.report?.length ?? 0) > 50
                    ? 30
                    : (lstData.report?.length ?? 0),
              )
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .replaceAll(RegExp(r'[\r\n]+'), '');
          if (baseFilenameAf.isEmpty) baseFilenameAf = 'file';

          String filenameAf = 'update_report_img_$baseFilenameAf.$ext2';

          FormData formData = FormData({
            "type": "update_report",
            "report_id": lstData.id,
            "branch": kodeCabang,
            "priority": lstData.priority,
            "status": lstData.status,
            "keterangan": lstData.keterangan,
            "progress": lstData.progress,
            "issue": lstData.issue,
            "uid": lstData.uid,
            "report": lstData.report,
            "updated_by": author,
            'report_image_after': MultipartFile(
              compressedBytesAf,
              filename: filenameAf,
            ),
          });

          await ServiceApi().updateReportWithImgAf(formData);
          // print(lstData.imageAf);
          // print(type);
          // String cleanBase64Af =
          //     (lstData.imageAf ?? '')
          //         .replaceAll('\n', '')
          //         .replaceAll('\r', '')
          //         .trim();
          // if (cleanBase64Af.isEmpty) continue;

          // Uint8List originalBytesAf = base64Decode(cleanBase64Af);
          // Uint8List compressedBytesAf = await Future.delayed(
          //   const Duration(seconds: 1),
          //   () => compressImage(originalBytesAf),
          // );

          // String baseFilenameAf = (lstData.report ?? 'file')
          //     .substring(
          //       0,
          //       (lstData.report?.length ?? 0) > 50
          //           ? 30
          //           : (lstData.report?.length ?? 0),
          //     )
          //     .replaceAll(RegExp(r'[^\w\s-]'), '')
          //     .replaceAll(RegExp(r'[\r\n]+'), '');
          if (baseFilenameAf.isEmpty) baseFilenameAf = 'file';

          // String filenameAf = 'update_report_img_$baseFilenameAf.$ext2';

          // formData = FormData({
          //   "type": type,
          //   "report_id": lstData.id,
          //   "status": lstData.status,
          //   "branch": lstData.cabang,
          //   "report_desc": lstData.report,
          //   "uid": lstData.uid,
          //   "report_image_after": MultipartFile(
          //     compressedBytesAf,
          //     filename: filenameAf,
          //   ),
          //   'created_by': author,
          // });
          // print(formData.fields);
        } else {
          String cleanBase64 =
              (lstData.imageBf ?? '')
                  .replaceAll('\n', '')
                  .replaceAll('\r', '')
                  .trim();
          if (cleanBase64.isEmpty) continue;

          Uint8List originalBytes = base64Decode(cleanBase64);
          Uint8List compressedBytes = await Future.delayed(
            const Duration(seconds: 1),
            () => compressImage(originalBytes),
          );

          String baseFilename = (lstData.report ?? 'file')
              .substring(
                0,
                (lstData.report?.length ?? 0) > 50
                    ? 30
                    : (lstData.report?.length ?? 0),
              )
              .replaceAll(RegExp(r'[^\w\s-]'), '')
              .replaceAll(RegExp(r'[\r\n]+'), '');
          if (baseFilename.isEmpty) baseFilename = 'file';
          String filename = '$baseFilename.$ext';

          formData = FormData({
            "type": type,
            "report_id": lstData.id,
            "div": lstData.div,
            "branch": lstData.cabang,
            "report_desc": lstData.report,
            "uid": lstData.uid,
            'report_image': MultipartFile(compressedBytes, filename: filename),
            'created_by': author,
          });
          await ServiceApi().reportDetailSubmit(formData);
        }
      }
    } catch (e) {
      showToast(e.toString(), "red");
      reportTitle.clear();
      selectedReportDiv.value = "";
      statusSelected.value = "";
      webImage = null;
      webImage2 = null;
      await getReport(kodeCabang);
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      dataSource.notifyListeners();
      Get.back();
      return; // hentikan fungsi saat error agar tidak lanjut proses
    }
    selectedReportDiv.value = "";
    statusSelected.value = "";
    reportTitle.clear();
    webImage = null;
    webImage2 = null;
    tempListReport.clear();
    await getReport(kodeCabang);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
    Get.back();
  }

  updateReport(bool isWideScreen, String kodeCabang) async {
    Get.back();
    loadingDialog("Memperbarui data", " ");
    for (var lstData in detailDataReport) {
      if (webImage2 != null) {
        String cleanBase64Af =
            (lstData.imageAf ?? '')
                .replaceAll('\n', '')
                .replaceAll('\r', '')
                .trim();
        if (cleanBase64Af.isEmpty) continue;

        Uint8List originalBytesAf = base64Decode(cleanBase64Af);
        Uint8List compressedBytesAf = await Future.delayed(
          const Duration(seconds: 1),
          () => compressImage(originalBytesAf),
        );

        String baseFilenameAf = (lstData.report ?? 'file')
            .substring(
              0,
              (lstData.report?.length ?? 0) > 50
                  ? 30
                  : (lstData.report?.length ?? 0),
            )
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(RegExp(r'[\r\n]+'), '');
        if (baseFilenameAf.isEmpty) baseFilenameAf = 'file';

        String filenameAf = 'update_report_img_$baseFilenameAf.$ext2';

        FormData formData = FormData({
          "type": "update_report",
          "report_id": lstData.id,
          "branch": kodeCabang,
          "priority": lstData.priority,
          "status": lstData.status,
          "keterangan": lstData.keterangan,
          "progress": lstData.progress,
          "issue": lstData.issue,
          "uid": lstData.uid,
          "report": lstData.report,
          "updated_by": author,
          'report_image_after': MultipartFile(
            compressedBytesAf,
            filename: filenameAf,
          ),
        });

        await ServiceApi().updateReportWithImgAf(formData);
      } else {
        var data = {
          "type": "update_report",
          // "branch": branchCode,
          "report_id": lstData.id,
          "branch": kodeCabang,
          "priority": lstData.priority,
          "status": lstData.status,
          "keterangan": lstData.keterangan,
          "progress": lstData.progress,
          "issue": lstData.issue,
          "uid": lstData.uid,
          "report": lstData.report,
          "updated_by": author,
        };
        // print(data);
        await ServiceApi().report(data);
      }
    }
    Get.back();
    succesDialog(
      Get.context!,
      'Data berhasil diupdate',
      DialogType.success,
      'SUKSES',
      isWideScreen,
    );
    webImage2 = null;
    await getReport(kodeCabang);
    // Get.back();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
  }

  deleteDetailReport(String imageOld, String uid) async {
    var data = {
      "type": "delete_detail_report",
      "image_old": imageOld,
      "uid": uid,
    };
    await ServiceApi().report(data);
  }

  deleteReport(String id, isWideScreen, String kodeCabang) async {
    Get.back();
    loadingDialog("Menghapus data report...", "");
    var images = detailDataReport.map((img) => img.imageBf).toList().join(',');
    var data = {"type": "delete_report", "images": images, "report_id": id};
    // print(img.imageBf!);
    await ServiceApi().report(data);

    // Get.back();
    succesDialog(
      Get.context!,
      'Data berhasil dihapus',
      DialogType.success,
      'SUKSES',
      isWideScreen,
    );
    await getReport(kodeCabang);
    // Get.back();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
  }

  void filterDataReportByStore(String val) async {
    List<ReportByStore> result = [];
    if (val.isEmpty) {
      result = dataReportByStore;
    } else {
      result =
          dataReportByStore
              .where(
                (e) => e.namaCabang.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ),
              )
              .toList();
    }
    dataReportByStoreFiltered.value = result;
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
        case 'ON PRGS':
          return PdfColors.yellow700;
        case 'DONE':
          return PdfColors.green700;
        case 'RE SCHE':
          return PdfColors.red700;
        case 'FU':
          return PdfColors.blue700;
        // case 'OPEN':
        //   return PdfColors.orange;
        default:
          return PdfColors.white;
      }
    }

    // String autoNewLine(String input, {int maxChar = 27}) {
    //   if (input.length <= maxChar) return input;
    //   StringBuffer buffer = StringBuffer();
    //   for (int i = 0; i < input.length; i += maxChar) {
    //     int end = (i + maxChar < input.length) ? i + maxChar : input.length;
    //     buffer.write(input.substring(i, end));
    //     if (end != input.length) buffer.write('\n');
    //   }
    //   return buffer.toString();
    // }

    final font = await PdfGoogleFonts.nunitoRegular();

    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue700),
        children: [
          pw.Text(
            'Date',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Image Bafore',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Image After',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            'Report ',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          pw.Text(
            ' Status ',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: PdfColors.white, font: font),
          ),
          // pw.Text(
          //   'PROGRESS',
          //   textAlign: pw.TextAlign.center,
          //   style: pw.TextStyle(color: PdfColors.white, font: font),
          // ),
          // pw.Text(
          //   'ISSUE',
          //   textAlign: pw.TextAlign.center,
          //   style: pw.TextStyle(color: PdfColors.white, font: font),
          // ),
          pw.Text(
            'NOTE',
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
      pw.MemoryImage imageBf = pw.MemoryImage(img1);

      pw.MemoryImage? imageAf;
      if (data.imageAf!.isNotEmpty) {
        var img2 = await http.get(
          Uri.parse('${ServiceApi().baseUrl}${data.imageAf!}'),
        );
        imageAf = pw.MemoryImage(img2.bodyBytes);
      }

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
                width: 110,
                height: 110,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(child: pw.Image(imageBf, fit: pw.BoxFit.fill)),
                // child: pw.Center(child: pw.Container()),
              ),
            ),
            data.imageAf!.isNotEmpty
                ? pw.Center(
                  child: pw.Container(
                    width: 110,
                    height: 110,
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Center(
                      child: pw.Image(imageAf!, fit: pw.BoxFit.fill),
                    ),
                    // child: pw.Center(child: pw.Container()),
                  ),
                )
                : pw.Container(width: 110, height: 110),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 80,
                child: pw.Text(
                  data.report!.capitalize!,
                  // autoNewLine(data.report!),
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
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
                    textAlign: pw.TextAlign.center,
                    data.status!,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                    ), // menambahkan nomor urut di depan status
                  ),
                ),
              ),
            ),
            // pw.Padding(
            //   padding: const pw.EdgeInsets.all(2),
            //   child: pw.Text(
            //     autoNewLine(data.progress!),
            //     style: pw.TextStyle(font: font),
            //   ),
            // ),
            // pw.Padding(
            //   padding: const pw.EdgeInsets.all(2),
            //   child: pw.Text(
            //     autoNewLine(data.issue!),
            //     style: pw.TextStyle(font: font),
            //   ),
            // ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.SizedBox(
                width: 90,
                child: pw.Text(
                  data.keterangan!.capitalize!,
                  // autoNewLine(data.keterangan!),
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

  Future<void> copyImageToClipboard(
    BuildContext context,
    String imageUrl,
    bool isWideScreen,
  ) async {
    final script = '''
    async function copyImage(url) {
      if (typeof ClipboardItem === 'undefined') {
        return 'failed:ClipboardItem tidak didukung di browser ini.';
      }
      try {
        const img = new Image();
        img.crossOrigin = 'anonymous';
        img.src = url;
        await new Promise((resolve, reject) => {
          img.onload = resolve;
          img.onerror = reject;
        });

        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);

        const blob = await new Promise(resolve => canvas.toBlob(resolve, 'image/png'));

        if (!ClipboardItem.supports('image/png')) {
          return 'failed:Clipboard tidak mendukung tipe image/png.';
        }

        const clipboardItem = new ClipboardItem({'image/png': blob});
        await navigator.clipboard.write([clipboardItem]);

        return 'success';
      } catch (e) {
        return 'failed:Failed to copy image: ' + e;
      }
    }
    copyImage('$imageUrl');
  ''';

    final result = await js_util.promiseToFuture(
      js.context.callMethod('eval', [script]),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (result == 'success') {
        showToast('Image copied to clipboard', 'green');
        // succesDialog(
        //   context,
        //   'Image copied to clipboard',
        //   DialogType.success,
        //   'Sukses',
        //   isWideScreen,
        // );
      } else if (result is String && result.startsWith('failed:')) {
        showToast(result.substring(7), 'red');
        // failedDialog(context, 'Error', result.substring(7), isWideScreen);
      }
    });
  }

  storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  showCustomMenu(
    BuildContext context,
    String imageUrl,
    bool isWideScreen,
  ) async {
    final selected = await showMenu(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      menuPadding: EdgeInsets.zero,
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx,
        tapPosition.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 7),
              Text('Copy this image', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        // const PopupMenuItem(value: 'cut', child: Text('Cut')),
        // const PopupMenuItem(value: 'paste', child: Text('Paste')),
      ],
      elevation: 8.0,
    );
    if (selected != null) {
      if (!context.mounted) return;
      copyImageToClipboard(context, imageUrl, isWideScreen);
      enableRightClick();
      Get.back();
      // print('Selected option: $selected');
    }
  }
}
