import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/modules/stok_opname/views/stok_opname_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/login_model.dart';
import '../../../barang_keluar/views/stok_out_view.dart';
import '../../../barang_masuk/views/stok_in_view.dart';
import '../../../master_barang/views/assets_view.dart';
import '../../../master_barang/views/kategori_view.dart';
import '../../../report_issue/views/report_issue_view.dart';
import '../../../report_issue/views/widget/report_list.dart';
import '../../../request_form/views/request_form_view.dart';
import '../../../stok/views/stock_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../dashboard_view.dart';
import 'drawer_menu.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key, this.userData, required this.navController});
  final Data? userData;
  final DashboardController navController;

  @override
  Widget build(BuildContext context) {
    final level = userData?.levelUser?.split(' ').first;
    List<Widget> pages = [
      if (![
        "PROJECT",
        "EDITORIAL",
        "AUDIT",
      ].contains(level))
        DashboardView(userData: userData),
      if (![
        "19",
        "20",
        "21",
        "22",
        "24",
        "26",
        "35",
        "59",
        "78",
      ].contains(userData?.level))
        KategoriView(userData: userData!,),
      if (![
        "19",
        "20",
        "21",
        "22",
        "24",
        "26",
        "35",
        "59",
        "78",
      ].contains(userData?.level))
        AssetsView(userData: userData!,),
      StockView(userData: userData),
      StokInView(userData: userData),
      StokOutView(userData: userData),
      if (["IT", "AUDIT"].contains(level))
        StokOpnameView(userData: userData),
      if (["BRAND", "IT"].contains(level))
        ReportListView(userData: userData)
      else if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
        ReportIssueView(userData: userData, isHO: false),
      if (![
        "PROJECT",
        "EDITORIAL",
        "AUDIT",
      ].contains(level))
        RequestFormView(),
      const Text('Logout'),
    ];

    return Obx(() {
      if (!navController.isReady.value) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
          title: RichText(
            text: const TextSpan(
              text: 'Assets Management',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: ' v.2601-12',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColors.itemsBackground,
        ),
        drawer: DrawerMenu(userData: userData),
        body: PageView(
          controller: navController.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
      );
    });
  }
}
