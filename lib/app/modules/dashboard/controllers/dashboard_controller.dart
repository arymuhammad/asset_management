// import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:assets_management/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var selectedMenu = 0.obs;
  var currentRoute = Routes.DASHBOARD.obs;
  final ScrollController scrollController = ScrollController();
  double scrollPosition = 0;
  double opacity = 0;
  // PageController pageController = PageController();
  // SideMenuController sideMenu = SideMenuController();
    // GlobalKey untuk nested Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onInit() {
    // sideMenu.addListener((index) {
    //   pageController.jumpToPage(index);
    // });
    super.onInit();
    scrollController.addListener(scrollListener);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  scrollListener() {
    scrollPosition = scrollController.position.pixels;
  }
}
