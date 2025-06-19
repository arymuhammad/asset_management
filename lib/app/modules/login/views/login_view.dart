// import 'package:absensi/app/modules/profil/views/verifikasi_update_password.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../data/helper/custom_dialog.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.grey[600],
      child: Center(
        child: Container(
          width: 350,
          height: 530,
          decoration: BoxDecoration(
              // gradient: const LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomCenter,
              //     colors: [Colors.white60, Colors.white10]),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35),
                Center(
                  child: ClipOval(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      child: Image.asset(
                        "assets/image/bg_lg.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 22),
                  ),
                ),const SizedBox(height: 5),
                const Center(
                  child: Text(
                    'Gunakan akun URBAN&CO SPOT untuk login',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 45,
                    width: 270,
                    child: TextField(
                      controller: controller.username,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          prefixIcon: Icon(HugeIcons.strokeRoundedUser03)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => Center(
                    child: SizedBox(
                      height: 45,
                      width: 270,
                      child: TextField(
                        controller: controller.password,
                        obscureText: controller.isPassHide.value,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Password',
                            prefixIcon: const Icon(HugeIcons.strokeRoundedLockKey),
                            suffixIcon: InkWell(
                                onTap: () {
                                  controller.isPassHide.value =
                                      !controller.isPassHide.value;
                                },
                                child: Icon(controller.isPassHide.value
                                    ? Icons.visibility
                                    : Icons.visibility_off))),
                        onSubmitted: (v) => controller.login(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: SizedBox(
                    height: 45,
                    width: 125,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            fixedSize: Size(Get.mediaQuery.size.width, 50)),
                        onPressed: () {
                          if (controller.username.text == "" ||
                              controller.password.text == "") {
                            showToast(
                                "Username dan Password tidak boleh kosong",
                                'red');
                          } else {
                            controller.login();
                          }
                        },
                        child: const Text('LOGIN')),
                  ),
                ),
                const SizedBox(height: 20),
                // TextButton(
                //     onPressed: () {
                //       Get.to(() => VerifyUpdatePasswordView(),
                //           transition: Transition.cupertino);
                //     },
                //     child: const Text('Lupas Password?')),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
