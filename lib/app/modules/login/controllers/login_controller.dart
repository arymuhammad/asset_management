import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Repo/service_api.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../../data/models/login_model.dart';

class LoginController extends GetxController {
  late TextEditingController username, password;

  var isLoading = false.obs;
  var dataUser = Login().obs;
  var isAuth = false.obs;
  // var selected = 0.obs;
  var logUser = Data().obs;
  var isPassHide = true.obs;

  @override
  void onInit() {
    super.onInit();
    username = TextEditingController();
    password = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    username.dispose();
    password.dispose();
  }

  login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = {"username": username.text, "password": password.text};
    loadingDialog('Loading...', "");
    var response = await ServiceApi().loginUser(data);
    Get.back();
    dataUser.value = response;
    if (dataUser.value.success! == true) {
      await pref.setString(
          'userDataLogin',
          jsonEncode(Data(
              id: dataUser.value.data!.id,
              nama: dataUser.value.data!.nama,
              namaCabang: dataUser.value.data!.namaCabang,
              noTelp: dataUser.value.data!.noTelp,
              levelUser: dataUser.value.data!.levelUser,
              foto: dataUser.value.data!.foto,
              lat: dataUser.value.data!.lat,
              long: dataUser.value.data!.long,
              kodeCabang: dataUser.value.data!.kodeCabang,
              level: dataUser.value.data!.level,
              username: dataUser.value.data!.username)));

      var tempUser = pref.getString('userDataLogin');
      logUser.value = Data.fromJson(jsonDecode(tempUser!));
      isAuth.value = await pref.setBool("is_login", true);

      showToast('Selamat datang ${dataUser.value.data!.nama}', 'green');
      username.clear();
      password.clear();
      Get.back();
    } else {
      showToast(
          "User tidak ditemukan\nHarap periksa username dan password", 'red');
    }
  }

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // await pref.setBool("is_login", false);
    // await pref.remove('userDataLogin');

    await pref.clear();
    logUser.value = Data();
    isAuth.value = false;
    // selected.value = 0;
    // Get.delete<MasterBarangController>(force: true);
    // Get.delete<StokController>(force: true);
    // Get.delete<BarangMasukController>(force: true);
    // Get.delete<BarangKeluarController>(force: true);
    // Get.offAllNamed(Routes.LOGIN);
    // Get.back();
    // Get.offAll(() => LoginView());
    // Get.offAllNamed(Routes.LOGIN);
    showToast("Logout Berhasil", 'green');
  }
}
