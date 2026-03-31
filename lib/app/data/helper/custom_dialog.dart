import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../modules/login/controllers/login_controller.dart';
import 'const.dart';

final auth = Get.put(LoginController());

defaultSnackBar(context, message) {
  var snackBar = SnackBar(
    content: Text(message),
    // backgroundColor:
    //     status == "E" ? Colors.redAccent[700] : Colors.greenAccent[700],
    duration: const Duration(milliseconds: 2000),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

snackbarCopy({required String item}) async {
  await Clipboard.setData(ClipboardData(text: item));
  Get.snackbar(
    'Copied',
    'ID $item berhasil disalin ke clipboard!',
    snackPosition: SnackPosition.BOTTOM,
    maxWidth: 400, // Batasi lebar maksimal snackbar
    margin: const EdgeInsets.only(
      right: 20,
      bottom: 20,
    ), // Margin kanan dan bawah
    borderRadius: 8,
    backgroundColor: Colors.black87,
    colorText: Colors.white,
    snackStyle: SnackStyle.FLOATING, // Floating agar tidak melebar penuh
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(seconds: 2),
  );
}

showToast(String message, String bgcolor) {
  Fluttertoast.showToast(
    msg: message,
    // backgroundColor: Colors.grey[700],
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    webBgColor: bgcolor == 'green' ? '#0bbd17' : '#d90d02',
    timeInSecForIosWeb: 2,
    webPosition: 'right',
  );
}

dialogMsg(title, msg) {
  Get.defaultDialog(
    title: title,
    middleText: msg,
    confirmTextColor: Colors.white,
    textConfirm: 'Tutup',
    onConfirm: () => Get.back(),
    barrierDismissible: false,
  );
}

dialogMsgScsUpd(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    textConfirm: 'Tutup',
    onConfirm: () {
      Get.back();
      Get.back();
    },
    barrierDismissible: false,
  );
}

void dialogMsgCncl(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    textCancel: 'Tutup',
    onCancel: () {
      // auth.selected(0);
      Future.delayed(const Duration(milliseconds: 300));
      Get.back();
    },
    barrierDismissible: false,
  );
}

void dialogMsgAbsen(code, msg) {
  Get.defaultDialog(
    title: code,
    middleText: msg,
    confirmTextColor: Colors.white,
    onConfirm: () {
      // Get.to(() => HomeView());
      // auth.selected(0);
      Future.delayed(const Duration(milliseconds: 300));
      Get.back();
      // Get.back();
      // Get.back();
      // Get.back();
    },
    barrierDismissible: false,
  );
}

succesDialog(
  BuildContext context,
  String desc,
  DialogType type,
  String title,
  bool isWideScreen,
) {
  AwesomeDialog(
    useRootNavigator: true,
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: type,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    width:
        isWideScreen
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width,
    title: title,
    desc: desc,
    btnOkOnPress: () {
      Get.back();
    },
    btnOkIcon: Icons.check_circle,
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

failedDialog(
  BuildContext context,
  String title,
  String desc,
  bool isWideScreen,
) {
  AwesomeDialog(
    useRootNavigator: true,
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.error,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    width:
        isWideScreen
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width,
    title: title,
    desc: desc,
    btnOkOnPress: () {},
    btnOkIcon: Icons.cancel,
    btnOkText: 'Tutup',
    btnOkColor: Colors.redAccent[700],
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

infoDialog(
  BuildContext context,
  String title,
  String desc,
  String confirmText,
  Function()? btnOkOnPress,
) {
  AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.info,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    width: MediaQuery.of(context).size.width * 0.3,
    title: title,
    desc: desc,
    btnOkOnPress: btnOkOnPress,
    btnOkIcon: Icons.camera_front,
    btnOkText: confirmText,
    btnOkColor: mainColor,
    onDismissCallback: (type) {
      debugPrint('Dialog Dissmiss from callback $type');
    },
  ).show();
}

void warningDialog(
  BuildContext context,
  String? title,
  String? desc,
  Function()? btnOkOnPress,
  bool? isWideScreen,
) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    width:
        isWideScreen!
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width,
    title: title,
    desc: desc,
    btnCancelOnPress: () {},
    btnOkOnPress: btnOkOnPress,
    btnCancelColor: Colors.redAccent[700],
    btnCancelIcon: Icons.cancel,
    btnOkColor: Colors.blueAccent[700],
    btnOkIcon: Icons.check_circle_rounded,
  ).show();
}

void promptDialog(
  BuildContext context,
  String? title,
  String? desc,
  Function()? btnOkOnPress,
  bool? isWideScreen,
) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.question,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    width:
        isWideScreen!
            ? MediaQuery.of(context).size.width * 0.3
            : MediaQuery.of(context).size.width,
    title: title,
    desc: desc,
    btnCancelOnPress: () {},
    btnOkOnPress: btnOkOnPress,
    btnCancelColor: Colors.redAccent[700],
    btnCancelIcon: Icons.cancel,
    btnOkColor: Colors.blueAccent[700],
    btnOkIcon: Icons.check_circle_rounded,
  ).show();
}

loadingDialog(msg, String? msg2) {
  Get.defaultDialog(
    title: '',
    onWillPop: () async {
      return false;
    },
    content: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(msg),
          Text(msg2!),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}

// loadingWithIcon() {
//   SmartDialog.showLoading(
//     backDismiss: false,
//     animationType: SmartAnimationType.scale,
//     builder: (_) => Stack(alignment: Alignment.center, children: [
//       Image.asset(
//         'assets/image/selfie.png',
//         height: 50,
//         width: 50,
//       ),
//       // Lottie.asset('assets/image/loader.json', repeat: true)
//       RotationTransition(
//         alignment: Alignment.center,
//         turns: auth.ctrAnimated,
//         child: Image.asset(
//           'assets/image/circle_loading.png',
//           height: 80,
//           width: 80,
//         ),
//       ),
//     ]),
//   );
// }
void getDefaultSnackbar({
  required String title,
  required String desc,
  required bool success,
}) {
  Get.snackbar(
    title,
    desc,
    colorText: Colors.white,
    backgroundColor: success ? Colors.green[700] : Colors.red[700],
    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    maxWidth: 300, // Batasi lebar maksimal snackbar
    margin: const EdgeInsets.only(
      left: 1000,
      bottom: 20,
    ), // Margin kanan dan bawah
    borderRadius: 8,
    showProgressIndicator: true,
    progressIndicatorBackgroundColor: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    snackStyle: SnackStyle.FLOATING, // Floating agar tidak melebar penuh
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(seconds: 1, milliseconds: 100),
    isDismissible: true,
  );
}
