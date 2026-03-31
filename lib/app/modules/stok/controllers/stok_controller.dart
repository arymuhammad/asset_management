import 'dart:async';
import 'dart:typed_data';
import 'package:assets_management/app/data/models/stock_detail_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/Repo/service_api.dart';
import '../../../data/helper/format_waktu.dart';
import '../../../data/models/assets_model.dart';
import '../../../data/models/cabang_model.dart';
import '../../../data/models/category_assets_model.dart';
import '../views/stock_view.dart';
import 'package:collection/collection.dart';

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
  var lstBranch = <Cabang>[].obs;
  var lstBrand = <Cabang>[].obs;
  var brand = "".obs;
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

  late TextEditingController toBranchName;
  FocusNode fcsBrand = FocusNode();
  var selectedBranch = "".obs;
  var divisi = [
    "",
    "Brand",
    "Editorial",
    "General Affair",
    "Gudang MD",
    "Information Technology",
    "Online (Another)",
    "Online (Urban)",
    "Project",
    "Ruang Busdev",
    "Ruang Direktur",
    "Ruang GM",
    "Ruang Kerja Another",
    "Ruang Kerja Audit",
    "Ruang Kerja Brand",
    "Ruang Kerja HRD",
    "Ruang Kerja IT",
    "Ruang Kerja Ops",
    "Ruang Kerja Project",
    "Ruang Kerja Purchasing",
    "Ruang Meeting",
    "Visual Merchandise",
    "Visual Merchandise Fashion",
  ];
  var selectedDivisi = "".obs;

  @override
  void onInit() {
    super.onInit();
    updateDateTime();
    // Update the time every second
    Timer.periodic(const Duration(seconds: 1), (Timer t) => updateDateTime());
    getBrand();
    // getStok();
    dataStokFiltered.value = dataStok;
    detailDataFiltered.value = dataDetailStok;
    dataSource = StokData(dataStok: dataStokFiltered);
    // dataSource = StokData(dataStok: dataStokFiltered);

    toBranchName = TextEditingController();
    // toBranch = TextEditingController();
  }

  @override
  void onClose() {
    super.dispose();
    // toBranch.dispose();
    toBranchName.dispose();
  }

  getBrand() async {
    final response = await ServiceApi().getBrandCabang();
    lstBrand.add(Cabang(brandCabang: 'Pilih Brand'));
    lstBrand.addAll(response);
    return lstBrand;
  }

  void updateDateTime() {
    final now = DateTime.now();

    dateTimeNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  Future<List<Stok>> getStok(String branchCode, String levelUser) async {
    isLoading.value = true;

    final payload = {
      "type": "",
      "kode_cabang": branchCode,
      "level_user": levelUser,
    };
    // print(payload);
    final response = await ServiceApi().stokCRUD(payload);

    if (response?.stock != null) {
      dataStok.assignAll(response!.stock!);
      dataStokFiltered.assignAll(response.stock!);
    } else {
      dataStok.clear();
      dataStokFiltered.clear();
    }

    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
    isLoading.value = false;

    return dataStok;
  }

  Future<List<StockDetail>> getDetailStock(
    String type,
    String branchCode,
    String itemCode,
  ) async {
    final payload = {
      "type": type,
      "kode_cabang": branchCode,
      "asset_code": itemCode,
    };

    final response = await ServiceApi().stokCRUD(payload);

    if (response == null) return [];

    List<StockDetail> result = [];

    /// STOCK IN / OUT
    if (['stock_in', 'stock_out'].contains(type)) {
      result = response.stockDetail ?? [];
    }
    /// ADJ IN / OUT
    else if (['adj_in', 'adj_out'].contains(type)) {
      final adjList = response.adjDetail ?? [];

      result =
          adjList.map((e) {
            return StockDetail(
              id: e.id,
              cabang: type == 'adj_in' ? 'ADJ IN' : 'ADJ OUT',
              assetCode: e.assetCode,
              assetName: e.assetName,
              qty: e.qtyAdj.value,
              createdAt: e.createdAt,
              createdBy: e.createdBy,
            );
          }).toList();
    }

    /// SET TYPE WAJIB
    for (var item in result) {
      item.type = type;
    }

    return result;
  }

  Future<List<Cabang>> getCabang(Map<String, dynamic> brand) async {
    final response = await ServiceApi().getCabang(brand);
    lstBranch.value = response;
    return lstBranch;
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
                    e.assetName!.toLowerCase().contains(val.toLowerCase()) ||
                    e.barcode!.toLowerCase().contains(val.toLowerCase()),
              )
              .toList();
      // dataSource.notifyListeners(); // 🔥
    }
    dataStokFiltered.value = result;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  }

  void filterByDiv(String val) {
    List<Stok> result = [];
    if (val.isEmpty) {
      result = dataStok;
    } else {
      result =
          dataStok
              .where(
                (e) => e.group.toString().toLowerCase().contains(
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

  void printStock(String user, String levelUser) async {
    final doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final List<pw.Column> header = await _loadHeader();
    final List<pw.Widget> groupTables = await loadGroupedTables();
    final List<pw.Column> footer = await _loadFooter(user, levelUser);
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.portrait,
          pageFormat: PdfPageFormat.a4.portrait,
        ),
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  'BERITA ACARA\nSTOCK OPNAME INVENTORY',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Column(
                  // mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: header,
                ),
              ),
              pw.SizedBox(height: 5),
              ...groupTables,
              pw.SizedBox(height: 5),
              pw.Column(children: footer),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  _loadHeader() {
    List<pw.Column> header = [];
    header.add(
      pw.Column(
        children: [
          pw.Text(
            dataStok.isNotEmpty ? dataStok[0].namaCabang! : '',
            style: const pw.TextStyle(fontSize: 14),
          ),
          // pw.Text(
          //   'PERIODE : ${dataStok[0].id!}',
          //   style: const pw.TextStyle(fontSize: 16),
          // ),
        ],
      ),
    );
    // header.add(
    //   // pw.Row(
    //   //   children: [
    //   //     pw.SizedBox(width: 90, child: pw.Text('Created By')),
    //   //     pw.Text(': ${dataStok[0].createdBy!}'),
    //   //   ],
    //   // ),
    // );
    // header.add(
    //   pw.Row(
    //     children: [
    //       pw.SizedBox(width: 90, child: pw.Text('Created At')),
    //       pw.Text(
    //         ': ${FormatWaktu.formatTglBlnThn(tanggal: DateTime.parse(dataStok[0].date!))} ${dataStok[0].createdAt!}',
    //       ),
    //     ],
    //   ),
    // );
    return header;
  }

  Future<List<pw.Widget>> loadGroupedTables() async {
    final font = await PdfGoogleFonts.nunitoRegular();
    // Group data berdasarkan group property
    var groupedData = groupBy(dataStok, (item) => item.group);
    List<pw.Widget> widgets = [];

    for (var entry in groupedData.entries) {
      var group = entry.key;
      var items = entry.value;

      // Judul group di atas tabel
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            group ?? '',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
        ),
      );

      // Buat list future TableRow untuk tiap item agar bisa await image fetching
      final rowsFutures = items.asMap().entries.map((entry) async {
        int index = entry.key + 1; // nomor urut mulai dari 1
        var item = entry.value;
        // int a = int.parse(item.stokIn ?? '0');
        // int b = int.parse(item.stokOut ?? '0');
        int total = int.tryParse(item.total!)!;

        var response = await http.get(
          Uri.parse('${ServiceApi().baseUrl}${item.assetImg!}'),
        );
        var img = response.bodyBytes;
        pw.MemoryImage assetImage = pw.MemoryImage(img);

        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(index.toString(), style: pw.TextStyle(font: font)),
            ),
            pw.Container(
              width: 90,
              height: 90,
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: pw.Image(assetImage, fit: pw.BoxFit.fill),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.SizedBox(
                width: 80,
                child: pw.Text(
                  item.assetName?.capitalize ?? '',
                  style: pw.TextStyle(font: font),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                item.stokIn ?? '',
                style: pw.TextStyle(font: font),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('$total', style: pw.TextStyle(font: font)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('', style: pw.TextStyle(font: font)),
            ),
          ],
        );
      });

      // Tunggu semua proses async selesai dan dapatkan list TableRow
      final rows = await Future.wait(rowsFutures);

      // Tabel per group
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue700),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'No',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'Properti',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'Deskripsi',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'Qty Awal',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'Qty Fisik',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: pw.Text(
                    'Keterangan',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(color: PdfColors.white, font: font),
                  ),
                ),
              ],
            ),
            ...rows,
          ],
        ),
      );
      // Spacer antar tabel group
      widgets.add(pw.SizedBox(height: 25));
    }

    return widgets;
  }

  _loadFooter(String user, String levelUser) async {
    List<pw.Column> footer = [];
    footer.add(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Demikian berita acara ini, stock opname dibuat agar dapat dipergunakan sebagaimana mestinya agar disimpan dengan baik, terima kasih.',
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'Bogor - Sentul, ${FormatWaktu.formatTglBlnThn(tanggal: DateTime.now())}',
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Penanggung Jawab'),
              pw.SizedBox(width: 80, child: pw.Text('Mengetahui')),
            ],
          ),
          pw.SizedBox(height: 60),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    dataStok[0].createdBy!,
                    style: const pw.TextStyle(
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text(' '),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Riki',
                    style: const pw.TextStyle(
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text('Operation Manager'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Diperiksa Oleh'),
              pw.SizedBox(width: 80, child: pw.Text('Mengetahui')),
            ],
          ),
          pw.SizedBox(height: 60),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'Sahar Harianja',
                    style: const pw.TextStyle(
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text('Audit Internal'),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    '',
                    style: const pw.TextStyle(
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.Text('Direktur Ops'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return footer;
  }
}
