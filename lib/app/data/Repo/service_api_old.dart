import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:assets_management/app/data/models/adj_model.dart';
import 'package:assets_management/app/data/models/assets_model.dart';
import 'package:assets_management/app/data/models/barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/category_assets_model.dart';
import 'package:assets_management/app/data/models/detail_barang_masuk_keluar_model.dart';
import 'package:assets_management/app/data/models/detail_summ_model.dart';
import 'package:assets_management/app/data/models/report_by_store_model.dart';
import 'package:assets_management/app/data/models/report_model.dart';
import 'package:assets_management/app/data/models/request_detail_model.dart';
import 'package:assets_management/app/data/models/so_detail_model.dart';
import 'package:assets_management/app/data/models/so_model.dart';
import 'package:assets_management/app/data/models/stock_detail_model.dart';
import 'package:assets_management/app/data/models/stok_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helper/custom_dialog.dart';
import '../models/cabang_model.dart';
import '../models/detail_adj_model.dart';
import '../models/login_model.dart';
import '../models/request_model.dart';
import '../models/stock_response.dart';
import 'app_exceptions.dart';
import 'package:http_parser/http_parser.dart';

class ServiceApi {
  // var baseUrl = "https://assets.urbanco.id/api/";
  var baseUrl = "http://103.156.15.61/asset_management.bak/api/";
  // var baseUrl = "http://192.168.101.190/asset_management/api/";
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
          showToast('$e', 'red');
        }
        break;
      default:
        try {
          final response = await http
              .post(Uri.parse('${baseUrl}assets_cat'), body: data)
              .timeout(const Duration(minutes: 1));

          switch (response.statusCode) {
            case 200:
              List<dynamic> result = json.decode(response.body)['data'];

              List<CategoryAssets> data =
                  result.map((e) => CategoryAssets.fromJson(e)).toList();
              return data;
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
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
        } on Exception catch (e) {
          Get.back();
          showToast('$e', 'red');
        }
        break;
      case 'get_asset':
        try {
          final response = await http
              .post(Uri.parse('${baseUrl}asset'), body: data)
              .timeout(const Duration(minutes: 1));
          switch (response.statusCode) {
            case 200:
              dynamic result = json.decode(response.body)['data'];
              AssetsModel data = AssetsModel.fromJson(result);
              return data;
            default:
              throw Exception(response.reasonPhrase);
          }
        } on Exception catch (e) {
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

  Future<DetailSummModel?> stokCRUD(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock'), body: payload)
          .timeout(const Duration(minutes: 1));

      if (response.statusCode != 200) {
        throw Exception(response.reasonPhrase);
      }

      final decoded = json.decode(response.body);

      final List<dynamic>? rawData = decoded['data'];

      if (rawData == null || rawData.isEmpty) {
        return null;
      }

      final String type = payload['type'] ?? '';

      /// ================= STOCK IN / OUT =================
      if (['stock_in', 'stock_out'].contains(type)) {
        final result = rawData.map((e) => StockDetail.fromJson(e)).toList();

        return DetailSummModel(stockDetail: result);
      }

      /// ================= ADJ IN / OUT =================
      if (['adj_in', 'adj_out'].contains(type)) {
        final result = rawData.map((e) => DetailAdjModel.fromJson(e)).toList();

        return DetailSummModel(adjDetail: result);
      }

      /// ================= DEFAULT =================
      final result = rawData.map((e) => Stok.fromJson(e)).toList();

      return DetailSummModel(stock: result);
    } on TimeoutException {
      showToast('Request timeout', 'red');
      return null;
    } catch (e) {
      showToast(e.toString(), 'red');
      return null;
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
      // print('${baseUrl}stock_in');
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
            // print(result);
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
          Get.back();
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
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }

  Future<StockResponse?> getAsset(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}asset'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          final body = json.decode(response.body);

          List<dynamic> resultDetailBarang = body['data'];
          List<DetailBarangMasukKeluar> detailBarang =
              resultDetailBarang
                  .map((e) => DetailBarangMasukKeluar.fromJson(e))
                  .toList();

          List<dynamic> resultDetailAdj = body['data'];
          List<DetailAdjModel> detailAdj =
              resultDetailAdj.map((e) => DetailAdjModel.fromJson(e)).toList();

          return StockResponse(
            detailBarangMasukKeluar: detailBarang,
            detailAdj: detailAdj,
          );

        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } catch (e) {
      Get.back();
      showToast('$e', 'red');
    }
    return null;
  }

  Future<StockResponse?> getStockAsset(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock'), body: data)
          .timeout(const Duration(minutes: 1));

      switch (response.statusCode) {
        case 200:
          final body = json.decode(response.body);

          List<dynamic> resultDetailBarang = body['data'];
          List<DetailBarangMasukKeluar> detailBarang =
              resultDetailBarang
                  .map((e) => DetailBarangMasukKeluar.fromJson(e))
                  .toList();

          List<dynamic> resultDetailAdj = body['data'];
          List<DetailAdjModel> detailAdj =
              resultDetailAdj.map((e) => DetailAdjModel.fromJson(e)).toList();

          return StockResponse(
            detailBarangMasukKeluar: detailBarang,
            detailAdj: detailAdj,
          );

        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on TimeoutException catch (e) {
      showToast('$e', 'red');
    } catch (e) {
      Get.back();
      showToast('$e', 'red');
    }
    return null;
  }

  report(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}report'), body: data)
          .timeout(const Duration(minutes: 1));
      if (response.statusCode == 200) {
        switch (data['type']) {
          case "add_report":
            showToast("Report berhasil dibuat", "green");
            return true;
          case "update_report":
            // showToast("Data berhasil diupdate", "green");
            return true;
          case "delete_detail_report":
            showToast("Item berhasil dihapus", "green");
            return true;
          case "delete_report":
            showToast("Report berhasil dihapus", "green");
            return true;
          default:
            final jsonResult = json.decode(response.body)['data'];
            if (data['type'] == "rekap_by_branch") {
              List<ReportByStore> listData =
                  (jsonResult as List)
                      .map((e) => ReportByStore.fromJson(e))
                      .toList();
              return listData;
            } else {
              List<Report> listData =
                  (jsonResult as List).map((e) => Report.fromJson(e)).toList();
              return listData;
            }
        }
      } else {
        showToast("Gagal menerima data: ${response.statusCode}", "red");
        return null;
      }
    } on Exception catch (e) {
      Get.back();
      showToast(e.toString(), "red");
    }
  }

  updateReportWithImgAf(FormData formData) async {
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
          // showToast("Report berhasil dibuat", "green");
          // Get.back();

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
          // showToast("Report berhasil dibuat", "green");
          // Get.back();

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
          } else if (data['type'] == 'add_detail_request' ||
              data['type'] == 'accept_item_req' ||
              data['type'] == 'cancel_item_req') {
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

  adjIn(Map<String, dynamic> data) async {
    // switch (data['type']) {
    //   case 'add_stokIn':
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}adj_in'), body: data)
          .timeout(const Duration(minutes: 1));
      // print('${baseUrl}adj_in');
      // print(data);
      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_adjIn') {
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_data') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'add_detail_adjIn') {
          } else if (data['type'] == 'delete_adjIn') {
            showToast("Data berhasil dihapus", "green");
          } else if (data['type'] == 'reject_data') {
            showToast("Data berhasil direject", "green");
          } else if (data['type'] == 'accept_data') {
            showToast("Data berhasil disetujui", "green");
          } else {
            List<dynamic> result = json.decode(response.body)['data'];
            // print(result);
            if (data['type'] == 'get_detail_adjIn') {
              if (json.decode(response.body)['success'] == false) {
                // stop loading dialog before
                Get.back();
                showToast(
                  'This data is invalid, there are no item details in it',
                  'red',
                );
              } else {
                List<DetailAdjModel> data =
                    result.map((e) => DetailAdjModel.fromJson(e)).toList();
                return data;
              }
            } else {
              List<AdjModel> data =
                  result.map((e) => AdjModel.fromJson(e)).toList();
              return data;
            }
          }
        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }

  adjOut(Map<String, dynamic> data) async {
    // switch (data['type']) {
    //   case 'add_stokIn':
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}adj_out'), body: data)
          .timeout(const Duration(minutes: 1));
      // print('${baseUrl}adj_in');
      // print(data);
      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_adjOut') {
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_data') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'add_detail_adjOut') {
          } else if (data['type'] == 'delete_adjOut') {
            showToast("Data berhasil dihapus", "green");
          } else if (data['type'] == 'reject_data') {
            showToast("Data berhasil direject", "green");
          } else if (data['type'] == 'accept_data') {
            showToast("Data berhasil disetujui", "green");
          } else {
            List<dynamic> result = json.decode(response.body)['data'];
            // print(result);
            if (data['type'] == 'get_detail_adjOut') {
              if (json.decode(response.body)['success'] == false) {
                // stop loading dialog before
                Get.back();
                showToast(
                  'This data is invalid, there are no item details in it',
                  'red',
                );
              } else {
                List<DetailAdjModel> data =
                    result.map((e) => DetailAdjModel.fromJson(e)).toList();
                return data;
              }
            } else {
              List<AdjModel> data =
                  result.map((e) => AdjModel.fromJson(e)).toList();
              return data;
            }
          }
        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }

  so(Map<String, dynamic> data) async {
    // switch (data['type']) {
    //   case 'add_stokIn':
    try {
      final response = await http
          .post(Uri.parse('${baseUrl}stock_opname'), body: data)
          .timeout(const Duration(minutes: 1));
      // print('${baseUrl}adj_in');
      // print(data);
      switch (response.statusCode) {
        case 200:
          if (data['type'] == 'add_so') {
            showToast("Data tersimpan", "green");
          } else if (data['type'] == 'update_data') {
            Get.back();
            dialogMsgScsUpd('Info', 'Data berhasil diupdate');
          } else if (data['type'] == 'add_detail_so') {
          } else if (data['type'] == 'delete_so') {
            showToast("Data berhasil dihapus", "green");
          } else if (data['type'] == 'reject_data') {
            showToast("Data berhasil direject", "green");
          } else if (data['type'] == 'accept_data') {
            showToast("Data berhasil disetujui", "green");
          } else {
            List<dynamic> result = json.decode(response.body)['data'];
            // print(result);
            if (data['type'] == 'get_detail_so') {
              if (json.decode(response.body)['success'] == false) {
                // stop loading dialog before
                Get.back();
                showToast(
                  'This data is invalid, there are no item details in it',
                  'red',
                );
              } else {
                List<SoDetailModel> data =
                    result.map((e) => SoDetailModel.fromJson(e)).toList();
                return data;
              }
            } else {
              if (result == []) return null;
              List<SoModel> data =
                  result.map((e) => SoModel.fromJson(e)).toList();
              return data;
            }
          }
        default:
          Get.back();
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      // rethrow;
      showToast('$e', 'red');
      Get.back();
    }
  }
}
