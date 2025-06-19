import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/models/assets_model.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/modules/master_barang/views/kategori_view.dart';
import 'package:barcode/barcode.dart';
// import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker_web/image_picker_web.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/login_model.dart';
import '../views/assets_view.dart';

class MasterBarangController extends GetxController {
  var catName = TextEditingController();
  var deskripsi = TextEditingController();
  var asset = TextEditingController();
  var price = TextEditingController();
  var dateTimeNow = "";
  var branchCode = "";
  var dataCatAssets = <CategoryAssets>[].obs;
  var checkCatAssets = CategoryAssets().obs;
  var dataCatAssetsFiltered = RxList<CategoryAssets>([]);
  var dataAssets = <AssetsModel>[].obs;
  var dataAssetsFiltered = RxList<AssetsModel>([]);
  var isLoading = true.obs;
  var catSelected = "".obs;
  var assetsGroup = ["", "IT", "Brand", "Merchandise"];
  var assetsUnit = ["", "PCS", "UNIT", "SET"];
  var assetsSelected = "".obs;
  Rx<CategoryAssets?> catSelectedObj = Rx<CategoryAssets?>(null);
  var unitSelected = "".obs;
  final formKeyCat = GlobalKey<FormState>();
  final formKeyAsset = GlobalKey<FormState>();
  Uint8List? webImage;
  String? ext;
  // FilePickerResult? fileResult;
  PlatformFile? files;
  File? file;
  // List<MultipartFile> multipartFiles = [];

  RxString imagePath = ''.obs;
  RxBool isUploading = false.obs;
  var rowsPerPage = 10;
  late AssetData dataSource;
  late Mydata dataSourceMydata;

  @override
  void onInit() async {
    super.onInit();
    // getCatAssets({"type": "", "group": ""});
    // getAssets();
    updateDateTime();
    // Update the time every second
    Timer.periodic(const Duration(seconds: 1), (Timer t) => updateDateTime());
    SharedPreferences pref = await SharedPreferences.getInstance();
    var dataUser = Data.fromJson(jsonDecode(pref.getString('userDataLogin')!));
    branchCode = dataUser.kodeCabang!;

    dataAssetsFiltered.value = dataAssets;
    dataCatAssetsFiltered.value = dataCatAssets;

    // dataSource = AssetData(dataAsset: dataAssetsFiltered);
  }

  @override
  void onClose() {
    super.onClose();
    // catName.dispose();
    // deskripsi.dispose();
    // asset.dispose();
    // price.dispose();
  }

  void updateDateTime() {
    final now = DateTime.now();

    dateTimeNow = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }

  getCatAssets(Map<String, dynamic> data) async {
    // var data = {"type": "", "group": assetsSelected.value};
    final response = await ServiceApi().assetsCatCRUD(data);
    dataCatAssets.value = response;
    isLoading.value = false;
    return dataCatAssets;
  }

  // FutureOr<List<String>?> getSuggestions(String query) {
  //   return dataCatAssets
  //       .where(
  //         (asset) => asset.catName!.toUpperCase().contains(query.toUpperCase()),
  //       )
  //       .map((asset) => asset.catName!) // Konversi ke String
  //       .toList(); // Konversi Iterable ke List
  // }

  getAssets() async {
    var data = {"type": ""};
    final response = await ServiceApi().assetsCRUD(data);
    dataAssets.value = response;
    isLoading.value = false;
    return dataAssets;
  }

  verifiedAssetCat(String category) async {
    var data = {"type": "get_kategori", "cat_name": category};
    return checkCatAssets.value = await ServiceApi().assetsCatCRUD(data);
  }

  assetsCatSubmit(String? type, String? id) async {
    var idUpdate = id != "" ? id : "";
    var data = {
      "type": type!,
      "cat_name": catName.text,
      "group": assetsSelected.value,
      "desc": deskripsi.text,
      "created_at": dateTimeNow,
      "id": idUpdate,
    };
    await ServiceApi().assetsCatCRUD(data);
    isLoading.value = true;
    assetsSelected.value = "";
    catName.clear();
    deskripsi.clear();
    await getCatAssets({"type": "", "group": ""});
  }

  void deleteAssetCategories(String id) async {
    var data = {"type": "delete_kategori", "id": id};
    await ServiceApi().assetsCatCRUD(data);
    isLoading.value = true;
    await getCatAssets({"type": "", "group": assetsSelected.value});
  }

  void deleteAsset(String id, String image) async {
    var data = {"type": "delete_asset", "id": id, "image": image};
    await ServiceApi().assetsCRUD(data);
    // isLoading.value = true;
    await getAssets();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    dataSource.notifyListeners();
  }

  assetsSubmit(String? type, String? id, String? imageOld, bool isWideScreen) async {
    Get.back();
    loadingDialog("Menyimpan data...", "");
    var idUpdate = id != "" ? id : "";
    var generateBarcode = Random().nextInt(1000000000);
    var defaultIMage =
        (await rootBundle.load(
          'assets/image/no-image.jpg',
        )).buffer.asUint8List();

    final formData = FormData({
      'image':
          id == ""
              ? MultipartFile(
                webImage ?? defaultIMage,
                filename:
                    webImage != null
                        ? '${asset.text}.$ext'
                        : '${asset.text}.jpg',
              )
              : id != "" && webImage != null
              ? MultipartFile(
                webImage ?? defaultIMage,
                filename:
                    webImage != null
                        ? '${asset.text}.$ext'
                        : '${asset.text}.jpg',
              )
              : '',
      "type": type!,
      "asset_name": asset.text,
      "asset_code":
          'INV/URB/${assetsSelected.value.contains('Brand') ? 'BR' : assetsSelected.value}/${generateBarcode.toString()}',
      "category": catSelected.value,
      "purchase_date": "",
      "price": price.text,
      "unit": unitSelected.value,
      // "image": files!,
      // .isNotEmpty
      //     ? webImage
      // : (await rootBundle.load('assets/image/no-image.jpg'))
      //     .buffer
      //     .asUint8List(),
      "group": assetsSelected.value,
      "created_at": dateTimeNow,
      "id": idUpdate,
      "image_old": webImage != null ? imageOld : '',
    });
    // print(formData.fields);
    // print(formData.files);
    try {
      final response = await GetConnect()
          .post(
            // 'http://localhost/asset_management/api/asset', // Ganti sesuai endpoint CodeIgniter-mu
            'http://103.156.15.61/asset_management/api/asset', // Ganti sesuai endpoint CodeIgniter-mu
            formData,
            headers: {'Content-Type': 'multipart/form-data'},
          )
          .timeout(const Duration(minutes: 1));
      switch (response.statusCode) {
        case 200:
          assetsSelected.value = "";
          catSelected.value = "";
          catSelectedObj.value = null;
          unitSelected.value = "";
          asset.clear();
          price.clear();
          webImage = null;
          showToast('Asset berhasil ditambahkan', 'green');
          await getAssets();
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          dataSource.notifyListeners();
          // await getCatAssets({"type": ""});
          Get.back();
          break;
        default:
          throw Exception(response.status);
      }
    } on Exception catch (e) {
      failedDialog(Get.context!, 'ERROR', e.toString(), isWideScreen);
    }

    // await ServiceApi().assetsCRUD(data);
    // isLoading.value = true;
  }

  void pickAndUploadImage() async {
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

  Future<void> uploadImage(String filename, Uint8List bytes) async {
    isUploading.value = true;
    final formData = FormData({
      'image': MultipartFile(bytes, filename: filename),
    });

    final response = await GetConnect().post(
      'http://localhost/asset_management/api/test_upload', // Ganti sesuai endpoint CodeIgniter-mu
      formData,
      headers: {'Content-Type': 'multipart/form-data'},
    );

    if (response.statusCode == 200) {
      // print(response.body);
      imagePath.value = response.body['path'].toString(); // Path dari backend
    }
    isUploading.value = false;
  }

  filterDataCatAsset(String val) {
    List<CategoryAssets> result = [];
    if (val.isEmpty) {
      result = dataCatAssets;
    } else {
      result =
          dataCatAssets
              .where(
                (e) =>
                    e.catName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.assetsGroup.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    dataCatAssetsFiltered.value = result;
  }

  filterDataAsset(String val) {
    List<AssetsModel> result = [];
    if (val.isEmpty) {
      result = dataAssets;
    } else {
      result =
          dataAssets
              .where(
                (e) =>
                    e.assetName.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.assetsCode.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ) ||
                    e.category.toString().toLowerCase().contains(
                      val.toLowerCase(),
                    ),
              )
              .toList();
    }
    dataAssetsFiltered.value = result;
  }

  printDocument(String? barcode, String? assetName) async {
    final svg = Barcode.code128().toSvg(
      barcode.toString(),
      width: 160,
      height: 50,
    );
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.SvgImage(svg: svg, width: 160, height: 50),
                pw.Text(assetName!, style: const pw.TextStyle(fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
