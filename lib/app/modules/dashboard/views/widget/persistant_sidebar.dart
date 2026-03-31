import 'package:assets_management/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:assets_management/app/modules/dashboard/views/widget/desktop_layout.dart';
import 'package:assets_management/app/modules/dashboard/views/widget/mobile_layout.dart';
import 'package:assets_management/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/login_model.dart';

class PersistentSidebarLayout extends StatelessWidget {
  PersistentSidebarLayout({super.key, this.userData});
  final navController = Get.put(DashboardController(), permanent: true);
  final auth = Get.put(LoginController());
  final Data? userData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        // final sideMenuKey = ValueKey(isWideScreen);

        if (isWideScreen) {
          return DesktopLayout(
            navController: navController,
            isWideScreen: isWideScreen,
            userData: userData,
          );
        } else {
          return MobileLayout(navController: navController, userData: userData);
        }
      },
    );
  }
}
