import 'package:assets_management/app/data/Repo/service_api.dart';
import 'package:assets_management/app/data/helper/custom_dialog.dart';
import 'package:assets_management/app/data/shared/background_image_header.dart';
import 'package:assets_management/app/data/shared/rounded_image.dart';
import 'package:assets_management/app/modules/barang_masuk/views/stok_in_view.dart';
import 'package:assets_management/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:assets_management/app/modules/login/controllers/login_controller.dart';
import 'package:assets_management/app/modules/report_issue/views/report_issue_view.dart';
import 'package:assets_management/app/modules/request_form/views/request_form_view.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/login_model.dart';
import '../../../barang_keluar/views/stok_out_view.dart';
import '../../../master_barang/views/assets_view.dart';
import '../../../master_barang/views/kategori_view.dart';
import '../../../stok/views/stock_view.dart';
import '../dashboard_view.dart';

class PersistentSidebarLayout extends StatelessWidget {
  PersistentSidebarLayout({super.key, this.userData});
  final navController = Get.put(DashboardController());
  final auth = Get.put(LoginController());
  final Data? userData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 800;
        final sideMenuKey = ValueKey(isWideScreen);

        List<SideMenuItemType> items = [
          SideMenuItem(
            title: 'Dashboard',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedHome03),
          ),
          SideMenuExpansionItem(
            title: "Master",
            icon: const Icon(HugeIcons.strokeRoundedMasterCard),
            onTap:
                (index, _, isExpanded) => {
                  print('$index, expanded $isExpanded'),
                },
            children: [
              SideMenuItem(
                title: 'Kategori',
                onTap: (index, _) {
                  navController.sideMenu.changePage(index);
                },
                icon: const Icon(HugeIcons.strokeRoundedCatalogue),
              ),
              SideMenuItem(
                title: 'Asset',
                onTap: (index, _) {
                  navController.sideMenu.changePage(index);
                },
                icon: const Icon(HugeIcons.strokeRoundedAssignments),
              ),
            ],
          ),
          SideMenuItem(
            title: 'Stok',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedTask01),
          ),
          SideMenuItem(
            title: 'Barang Masuk',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedShippingLoading),
          ),
          SideMenuItem(
            title: 'Barang Keluar',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedShippingTruck01),
          ),
          SideMenuItem(
            title: 'Report Maintenance',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedPropertyView),
          ),
          SideMenuItem(
            title: 'Request Form',
            onTap: (index, _) {
              navController.sideMenu.changePage(index);
            },
            icon: const Icon(HugeIcons.strokeRoundedFolderImport),
          ),
          SideMenuItem(
            title: 'Exit',
            onTap: (index, _) {
              promptDialog(
                context,
                'Confirm',
                'Anda yakin ingin keluar?',
                () => auth.logout(),
                isWideScreen,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Report Management'),
                Visibility(
                  visible: isWideScreen ? true : false,
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_rounded, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        'Selamat datang ${userData!.nama}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Row(
            children: [
              SideMenu(
                key: sideMenuKey, // <--- tambahkan ini
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 150,
                          maxWidth: 150,
                        ),
                        child: RoundedImage(
                          headerProfile: true,
                          foto: userData!.foto!,
                          height: isWideScreen? 70:50,
                          width: isWideScreen? 70:50,
                          name: userData!.nama!,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // const Divider(indent: 8.0, endIndent: 8.0, thickness: 2),
                      Visibility(
                        visible: isWideScreen ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!.nama!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(userData!.levelUser!),
                            Text(userData!.namaCabang!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 10,
                      ),
                      child: Text(
                        '\u00A9 URBAN&CO ${DateFormat('yyyy').format(DateTime.now())}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ),
                  ),
                ),
                controller: navController.sideMenu,
                items: items,
                style: SideMenuStyle(
                  displayMode: SideMenuDisplayMode.auto, // Otomatis responsive
                  openSideMenuWidth: 250,
                  compactSideMenuWidth: 70,
                  backgroundColor: Colors.blueGrey,
                  selectedColor: Colors.blue,
                  unselectedIconColor: Colors.white70,
                  selectedIconColor: Colors.white,
                  selectedTitleTextStyle: const TextStyle(color: Colors.white),
                  unselectedTitleTextStyle: const TextStyle(
                    color: Colors.white70,
                  ),
                  hoverColor: Colors.white12,
                  showHamburger: true, // Tombol hamburger untuk toggle sidebar
                ),
              ),
              Expanded(
                child: PageView(
                  controller: navController.pageController,
                  children: [
                    Center(child: DashboardView(userData: userData)),
                    Center(child: KategoriView()),
                    Center(child: AssetsView()),
                    Center(child: StockView(userData: userData)),
                    Center(child: StokInView(userData: userData)),
                    Center(child: StokOutView(userData: userData)),
                    Center(child: ReportIssueView()),
                    Center(child: RequestFormView()),
                    const Center(child: Text('Logout')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
