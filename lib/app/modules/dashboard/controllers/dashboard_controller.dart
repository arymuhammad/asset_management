// import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var currentPageIndex = 0.obs;
  // var expandedMaster = false.obs;
  late PageController pageController;
  late SideMenuController sideMenu;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    sideMenu = SideMenuController();
    // Listener sideMenu untuk sinkronisasi ke pageController
    sideMenu.addListener((int index) {
      final pageIndex =
          pageController.hasClients ? pageController.page?.round() ?? 0 : 0;
      if (index != pageIndex) {
        pageController.jumpToPage(index);
      }
    });

    // Listener pageController untuk sinkronisasi ke sideMenu
    pageController.addListener(() {
      if (!pageController.hasClients) return;

    final pageIndex = pageController.page?.round() ?? 0;
    if (sideMenu.currentPage != pageIndex) {
      sideMenu.changePage(pageIndex);
    }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    sideMenu.dispose();
    super.dispose();
  }
}
