// import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'dart:convert';

import 'package:assets_management/app/data/models/summreportstat_model.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/Repo/service_api.dart';

class DashboardController extends GetxController {
  var currentPageIndex = 0.obs;
  // var expandedMaster = false.obs;
  late PageController pageController;
  // late SideMenuController sideMenu;
  var isReady = false.obs;
  bool _isAnimating = false;
  // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  var selectedIndex = 0.obs;
  var expandedIndex = (-1).obs;
  var isCollapsed = false.obs;

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
    _initControllers()
        .then((_) {
          ever(currentPageIndex, saveLastPageIndex); // Auto-save
        })
        .catchError((e) {
          print('Init error: $e');
          isReady.value = true; // Fallback
        });
  }

  Future<void> _initControllers() async {
    // ambil index terakhir dulu
    try {
      final lastPage = await getLastPageIndex();
      currentPageIndex.value = lastPage;

      pageController = PageController(initialPage: lastPage);
      // baru buat controller dengan initialPage yang benar
      // sideMenu = SideMenuController();
      // sideMenu.changePage(lastPage);

      // listener sideMenu -> pageController
      // sideMenu.addListener((int index) {
      //   if (_isAnimating) return;
      //   _isAnimating = true;
      //   pageController
      //       .animateToPage(
      //         index,
      //         duration: const Duration(milliseconds: 300),
      //         curve: Curves.easeInOut,
      //       )
      //       .then((_) => _isAnimating = false);
      //   currentPageIndex.value = index;
      //   saveLastPageIndex(index);
      // });

      // listener pageController -> sideMenu (kalau perlu)
      // pageController.addListener(() {
      //   if (_isAnimating) return;
      //   final p = pageController.page?.round() ?? 0;
      //   if (sideMenu.currentPage != p) {
      //     sideMenu.changePage(p);
      //     currentPageIndex.value = p;
      //     saveLastPageIndex(p);
      //   }
      // });

      isReady.value = true;
    } catch (e) {
      print('Controller init failed: $e');
      isReady.value = true; // Prevent stuck loading
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    // sideMenu.dispose();
    super.onClose();
  }

  /// simpan expansion yang sedang terbuka
  final expandedMenu = (-1).obs;

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  void toggleSidebar() {
    isCollapsed.value = !isCollapsed.value;
  }

  void changePage(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
    // sideMenu.changePage(index);
    expandedMenu.value = -1; // collapse semua saat pindah page
    currentPageIndex.value = index;
    saveLastPageIndex(index); // simpan index halaman saat ini
  }

  // void loadLastPage() async {
  //   int lastPage = await getLastPageIndex();
  //   sideMenu.changePage(lastPage);
  // }

  Stream<SummReportStat> getSummReportStat(Map<String, dynamic> param) async* {
    while (true) {
      final response = await http.post(
        Uri.parse('${ServiceApi().baseUrl}summ_dashboard'),
        body: param,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        SummReportStat result = SummReportStat.fromJson(data);
        yield result;
      }
      await Future.delayed(const Duration(seconds: 60));
    }
  }

  // Simpan halaman terakhir
  Future<void> saveLastPageIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPageIndex', index);
  }

  // Ambil halaman terakhir
  Future<int> getLastPageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastPageIndex') ??
        0; // default ke halaman dashboard (0)
  }
}
