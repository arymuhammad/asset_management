import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:assets_management/app/data/models/assets_model.dart';
import 'package:assets_management/app/data/models/barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/models/stock_detail_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:assets_management/app/modules/stok/views/widget/detail_stock.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helper/custom_dialog.dart';
import '../models/cabang_model.dart';
import '../models/login_model.dart';
import '../models/request_model.dart';
import 'app_exceptions.dart';
import 'package:http_parser/http_parser.dart';

class ServiceApi {
  var baseUrl = "http://103.156.15.61/asset_management/api/";
  // var baseUrl = "http://localhost/asset_management/api/";
  var isLoading = false.obs;

  loginUser(data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}auth'), body: data)
          .timeout(
            const Duration(minutes: 1),
            onTimeout: () {
              return timeOut(data);
            },
          );
      switch (response.statusCode) {
        case 200:
          final result = json.decode(response.body);
          return Login.fromJson(result);
        case 400:
        case 401:
        case 402:
        case 404:
          final result = json.decode(response.body);
          throw FetchDataException(result["message"]);
        default:
          throw FetchDataException('Something went wrong.');
      }
    } on FetchDataException catch (_) {
      // print('error caught: ${e.message}');
      showToast("PERINGATAN\nUsername atau Password salah!", 'red');
      isLoading.value = false;
    } on SocketException catch (_) {
      Get.defaultDialog(
        barrierDismissible: false,
        radius: 5,
        title: 'Peringatan',
        content: Column(
          children: [
            const Text('Periksa Koneksi Internet Anda '),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                loginUser(data);
                isLoading.value = true;
                Get.back();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
      isLoading.value = false;
    }
  }

  timeOut(data) {
    Get.defaultDialog(
      radius: 5,
      title: 'Koneksi Terputus',
      content: Column(
        children: [
          const Center(child: Text('Server tidak merespon')),
          ElevatedButton(
            onPressed: () async {
              loginUser(data);
              isLoading.value = true;
              Get.back();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
    isLoading.value = false;
  }

  getBrandCabang() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}brand_cabang'));
      // log('${baseUrl}brand_cabang');
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Cabang> data = result.map((e) => Cabang.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  getCabang(Map<String, dynamic>? data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}cabang'),
        body: data,
      );
      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<Cabang> data = result.map((e) => Cabang.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on SocketException catch (_) {
      rethrow;
    }
  }

  assetsCatCRUD(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'add_kategori':
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}assets_cat'),
            body: data,
          );
          switch (response.statusCode) {
            case 200:
              Get.back();
              dialogMsgScsUpd('Info', 'Sukses');
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      case 'get_kategori':
        try {
          final response = await http
              .post(Uri.parse('${baseUrl}assets_cat'), body: data)
              .timeout(const Duration(minutes: 1));
          switch (response.statusCode) {
            case 200:
              dynamic result = json.decode(response.body)['data'];
              CategoryAssets data = CategoryAssets.fromJson(result);
              return data;
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      case 'update_kategori':
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}assets_cat'),
            body: data,
          );
          switch (response.statusCode) {
            case 200:
              Get.back();
              dialogMsgScsUpd('Info', 'Kategori berhasil diupdate');
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      case 'delete_kategori':
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}assets_cat'),
            body: data,
          );
          switch (response.statusCode) {
            case 200:
              Get.back();
              dialogMsgScsUpd('Info', 'Kategori berhasil dihapus');
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      default:
        try {
          final response = await http
              .post(Uri.parse('${baseUrl}assets_cat'), body: data)
              .timeout(const Duration(minutes: 1));
          //print('${baseUrl}assets_cat');
          switch (response.statusCode) {
            case 200:
              List<dynamic> result = json.decode(response.body)['data'];
              //print(result);
              List<CategoryAssets> data =
                  result.map((e) => CategoryAssets.fromJson(e)).toList();
              return data;
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
    }
  }

  assetsCRUD(Map<String, dynamic> data) async {
    switch (data['type']) {
      case 'add_asset':
        // print(data);
        try {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('${baseUrl}asset'),
          );
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              data["image"].bytes!,
              filename: data["image"].name,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

          request.fields.addAll({
            "asset_name": data["asset_name"],
            "asset_code": data["asset_code"],
            "category": data["category"],
            "purchase_date": data["purchase_date"],
            "price": data["price"],
            "kelompok": data["kelompok"],
            "created_at": data["created_at"],
            "id": data["id"],
          });

          var response = await request.send().timeout(
            const Duration(seconds: 30),
          );
          if (response.statusCode == 200) {
            var respStr = await response.stream.bytesToString();
            var jsonResp = jsonDecode(respStr);
            if (jsonResp['success'] == true) {
              //print(jsonResp);
              //print('Gagal upload 1, status:  ${jsonResp['file_path']}');
            } else {
              //print('Gagal upload 2, status:  ${jsonResp['error']}');
            }
          } else {
            //print('Gagal upload 3, status:  ${response.statusCode}');
          }
          // if (response.statusCode == 200) {
          //   print('Upload berhasil');
          // } else {
          //   print('Gagal upload, status: ${response.statusCode}');
          // }
          //
          // .timeout(const Duration(minutes: 3))
          // .then((val) => showToast('data sukses dikirim', 'green'))

          // final response =
          //     await http.post(Uri.parse('${baseUrl}asset'), body: data);

          // switch (response.statusCode) {
          //   case 200:
          //     Get.back();
          //     dialogMsgScsUpd('Info', 'Sukses');
          //   default:
          //     throw Exception(response.reasonPhrase);
          // }
        } on Exception catch (e) {
          // rethrow;
          Get.back();
          showToast('$e', 'red');
        }
        break;
      case 'update_asset':
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}asset'),
            body: data,
          );
          switch (response.statusCode) {
            case 200:
              Get.back();
              dialogMsgScsUpd('Info', 'Asset berhasil diupdate');
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      case 'delete_asset':
        try {
          final response = await http.post(
            Uri.parse('${baseUrl}asset'),
            body: data,
          );
          switch (response.statusCode) {
            case 200:
              Get.back();
              dialogMsgScsUpd('Info', 'Asset berhasil dihapus');
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
      default:
        try {
          final response = await http
              .post(Uri.parse('${baseUrl}asset'), body: data)
              .timeout(const Duration(minutes: 1));
          switch (response.statusCode) {
            case 200:
              List<dynamic> result = json.decode(response.body)['data'];
              //print(result);
              List<AssetsModel> data =
                  result.map((e) => AssetsModel.fromJson(e)).toList();
              return data;
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
          // rethrow;
          showToast('$e', 'red');
        }
        break;
    }
  }

  stokCRUD(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          if (data['type'] == "stock_in" || data['type'] == "stock_out") {
            List<StockDetail> data =
                result.map((e) => StockDetail.fromJson(e)).toList();
            if (data == []) return null;
            return data;
          } else {
            List<Stok> data = result.map((e) => Stok.fromJson(e)).toList();

            return data;
          }
        //print(result);
        default:
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
    }
  }

  deleteUser(Map<String, String> idUser) async {
    try {
      await http.post(Uri.parse('${baseUrl}delete_user'), body: idUser);
      // switch (response.statusCode) {
      //   case 200:
      //     List<dynamic> result = json.decode(response.body)['data'];
      //     List<Users> dataUser = result.map((e) => Users.fromJson(e)).toList();
      //     return dataUser;
      //   case 400:
      //   case 401:
      //   case 402:
      //   case 404:
      //     final result = json.decode(response.body);
      //     throw FetchDataException(result["message"]);
      //   default:
      //     throw FetchDataException(
      //       'Something went wrong.',
      //     );
      // }
    } on FetchDataException catch (e) {
      // print('error caught: ${e.message}');
      showToast("${e.message}", 'red');
    }
  }

  stokIn(Map<String, dynamic> data) async {
    // switch (data['type']) {
    //   case 'add_stokIn':
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock_in'), body: data)
          .timeout(const Duration(minutes: 1));
      // print('${baseUrl}stok_in');
      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_stokIn') {
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_data') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'add_detail_stokIn') {
          } else if (data['type'] == 'delete_stokIn') {
            showToast("Data berhasil dihapus", "green");
          } else if (data['type'] == 'reject_data') {
            showToast("Data berhasil direject", "green");
          } else {
            List<dynamic> result = json.decode(response.body)['data'];
            //print(result);
            if (data['type'] == 'get_detail_stokIn') {
              List<DetailBarangMasukKeluar> data =
                  result
                      .map((e) => DetailBarangMasukKeluar.fromJson(e))
                      .toList();
              return data;
            } else {
              List<BarangKeluarMasuk> data =
                  result.map((e) => BarangKeluarMasuk.fromJson(e)).toList();
              return data;
            }
          }
        default:
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }

  stokOut(Map<String, dynamic> data) async {
    // switch (data['type']) {
    //   case 'add_stokIn':
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock_out'), body: data)
          .timeout(const Duration(minutes: 1));
      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_stokOut') {
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_data') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'delete_stokOut') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil dihapus');
          } else if (data['type'] == 'add_detail_stokOut') {
          } else {
            List<dynamic> result = json.decode(response.body)['data'];
            //print(result);
            if (data['type'] == 'get_detail_stokOut') {
              List<DetailBarangMasukKeluar> data =
                  result
                      .map((e) => DetailBarangMasukKeluar.fromJson(e))
                      .toList();
              return data;
            } else {
              List<BarangKeluarMasuk> data =
                  result.map((e) => BarangKeluarMasuk.fromJson(e)).toList();
              return data;
            }
          }
        default:
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }

  getAsset(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}asset'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<DetailBarangMasukKeluar> data =
              result.map((e) => DetailBarangMasukKeluar.fromJson(e)).toList();
          return data;
        default:
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
    }
  }

  getStockAsset(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          List<dynamic> result = json.decode(response.body)['data'];
          List<DetailBarangMasukKeluar> data =
              result.map((e) => DetailBarangMasukKeluar.fromJson(e)).toList();
          return data;
        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } on Exception catch (e) {
      // rethrow;
      Get.back();
      showToast('$e', 'red');
    }
  }

  report(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}report'), body: data)
          .timeout(const Duration(minutes: 1));
      switch (response.statusCode) {
        case 200:
          if (data['type'] != "add_report" && data['type'] != "update_report") {
            List<dynamic> result = json.decode(response.body)['data'];
            List<Report> data = result.map((e) => Report.fromJson(e)).toList();
            // Get.snackbar(
            //   "Sukses",
            //   "Data berhasil diambil",
            //   snackPosition: SnackPosition.BOTTOM,
            // );
            return data;
          } else if (data['type'] == "update_report") {
            // Notifikasi sukses update data
            // Get.back();
            // succesDialog(
            //   Get.context,
            //   'Data berhasil diupdate',
            //   DialogType.success,
            //   'SUKSES',
            // );
          } else if (data['type'] == "add_report") {
            // Notifikasi sukses add data
            // Get.back();
            // showToast("Report berhasil dibuat", "green");
            // succesDialog(
            //   Get.context,
            //   "Data berhasil ditambahkan",
            //   DialogType.success,
            //   'SUKSES',
            // );
          }
          break;
      }
    } on Exception catch (e) {
      Get.back();
      showToast(e.toString(), "red");
    }
  }

  reportDetailSubmit(FormData formData) async {
    try {
      final response = await GetConnect()
          .post(
            '${baseUrl}report',
            formData,
            headers: {'Content-Type': 'multipart/form-data'},
          )
          .timeout(const Duration(minutes: 1));
      switch (response.statusCode) {
        case 200:
          showToast("Report berhasil dibuat", "green");
          Get.back();

          break;
        default:
          Get.back();
          throw Exception(response.status);
      }
    } on Exception catch (e) {
      Get.back();
      showToast(e.toString(), "red");
    }
  }

  // getRequestData(Map<String, dynamic> data) async {
  //   try {
  //     final response = await http
  //         .post(Uri.parse('${baseUrl}request'), body: data)
  //         .timeout(const Duration(minutes: 1));
  //     switch (response.statusCode) {
  //       case 200:
  //         List<dynamic> result = json.decode(response.body)['data'];
  //         List<RequestModel> data =
  //             result.map((e) => RequestModel.fromJson(e)).toList();
  //         return data;
  //       default:
  //         throw Exception(response.reasonPhrase);
  //     }
  //   } on Exception catch (e) {
  //     // rethrow;
  //     showToast('$e', 'red');
  //   }
  // }

  getCatAsset(Map<String, String?> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}request'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          dynamic result = json.decode(response.body)['data'];
          if (result != null) {
            List<dynamic> result = json.decode(response.body)['data'];
            List<CategoryAssets> data =
                result.map((e) => CategoryAssets.fromJson(e)).toList();
            return data;
          } else {
            return RequestDetailModel();
          }
        default:
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
    }
  }

  getSOH(Map<String, String?> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}request'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          dynamic result = json.decode(response.body)['data'];
          if (result != null) {
            RequestDetailModel data = RequestDetailModel.fromJson(result);
            return data;
          } else {
            return RequestDetailModel();
          }
        default:
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
    }
  }

  request(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}request'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_request') {
            Get.back();
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_request') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'add_detail_request') {
          } else {
            List<dynamic> result = json.decode(response.body)['data'];

            if (data['type'] == 'detail_request' ||
                data['type'] == 'get_item_request' ||
                data['type'] == 'detail_request') {
              List<RequestDetailModel> data =
                  result.map((e) => RequestDetailModel.fromJson(e)).toList();
              return data;
            } else {
              List<RequestModel> data =
                  result.map((e) => RequestModel.fromJson(e)).toList();
              return data;
            }
          }
        default:
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      Get.back();
      showToast('$e', 'red');
    }
  }
}
