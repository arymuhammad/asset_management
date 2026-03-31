import 'package:assets_management/app/data/helper/app_colors.dart';
import 'package:assets_management/app/data/models/login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/shared/rounded_image.dart';
import '../../controllers/dashboard_controller.dart';

class DrawerMenu extends StatelessWidget {
  DrawerMenu({super.key, this.userData});
  final Data? userData;
  final navController = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.itemsBackground),
              accountName: Text(userData?.nama ?? ""),
              accountEmail: Text(userData?.levelUser ?? ""),
              currentAccountPicture: RoundedImage(
                height: 80,
                width: 80,
                foto: userData!.foto!,
                name: userData!.nama!,
                headerProfile: true,
              ),
              // Pakai default image jika kosong
              // onBackgroundImageError: (_, __) {},
              // ),
            ),
            // DrawerHeader(child: Container(child: Text(userData!.nama!))),
            if (![
              "PROJECT",
              "EDITORIAL",
              "AUDIT",
            ].contains(userData?.levelUser!.split(' ')[0]))
              ListTile(
                title: const Text('Dashboard'),
                leading: const Icon(HugeIcons.strokeRoundedHome03),
                onTap: () {
                  // Pindah page, tutup drawer
                  // navController.sideMenu.changePage(0);
                  // navController.pageController.jumpToPage(0);
                  navController.changePage(0);
                  Navigator.pop(context);
                },
              ),
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
              ExpansionTile(
                title: const Text('Master'),
                leading: const Icon(HugeIcons.strokeRoundedMasterCard),
                // initiallyExpanded: expansionState['Master'] ?? false,
                //     onExpansionChanged: (expanded) {
                //       setState(() {
                //         expansionState['Master'] = expanded;
                //       });
                //     },
                children: [
                  ListTile(
                    leading: const Icon(HugeIcons.strokeRoundedCatalogue),
                    title: const Text('Kategori'),
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 150), () {
                        // navController.sideMenu.changePage(1);
                        // navController.pageController.jumpToPage(1);
                        navController.changePage(
                          [
                                "PROJECT",
                                "EDITORIAL",
                                "AUDIT",
                              ].contains(userData?.levelUser!.split(' ')[0])
                              ? 0
                              : 1,
                        );
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(HugeIcons.strokeRoundedAssignments),
                    title: const Text('Asset'),
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 150), () {
                        // navController.sideMenu.changePage(2);
                        // navController.pageController.jumpToPage(2);
                        navController.changePage(
                          [
                                "PROJECT",
                                "EDITORIAL",
                                "AUDIT",
                              ].contains(userData?.levelUser!.split(' ')[0])
                              ? 1
                              : 2,
                        );
                      });
                    },
                  ),
                ],
              ),

            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedTask01),
              title: const Text('Stok'),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  // navController.sideMenu.changePage(3);
                  // navController.pageController.jumpToPage(3);
                  navController.changePage(
                    [
                          "19",
                          "20",
                          "21",
                          "22",
                          "24",
                          "26",
                          "35",
                          "59",
                          "78",
                        ].contains(userData?.level)
                        ? 1
                        : [
                          "PROJECT",
                          "EDITORIAL",
                          "AUDIT",
                        ].contains(userData?.levelUser!.split(' ')[0])
                        ? 2
                        : 3,
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedShippingLoading),
              title: const Text('Barang Masuk'),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  // navController.sideMenu.changePage(4);
                  // navController.pageController.jumpToPage(4);
                  navController.changePage(
                    [
                          "19",
                          "20",
                          "21",
                          "22",
                          "24",
                          "26",
                          "35",
                          "59",
                          "78",
                        ].contains(userData?.level)
                        ? 2
                        : [
                          "PROJECT",
                          "EDITORIAL",
                          "AUDIT",
                        ].contains(userData?.levelUser!.split(' ')[0])
                        ? 3
                        : 4,
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedShippingTruck01),
              title: const Text('Barang Keluar'),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  // navController.sideMenu.changePage(5);
                  // navController.pageController.jumpToPage(5);
                  navController.changePage(
                    [
                          "19",
                          "20",
                          "21",
                          "22",
                          "24",
                          "26",
                          "35",
                          "59",
                          "78",
                        ].contains(userData?.level)
                        ? 3
                        : [
                          "PROJECT",
                          "EDITORIAL",
                          "AUDIT",
                        ].contains(userData?.levelUser!.split(' ')[0])
                        ? 4
                        : 5,
                  );
                });
              },
            ),
            if ([
              "IT",
              "AUDIT",
            ].contains(userData?.levelUser!.split(' ')[0]))ListTile(
              leading: const Icon(HugeIcons.strokeRoundedBookEdit),
              title: const Text('Stok Opname'),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  // navController.sideMenu.changePage(5);
                  // navController.pageController.jumpToPage(5);
                  navController.changePage(
                    6,
                  );
                });
              },
            ),
            if (![
              "PROJECT",
              "EDITORIAL",
              "AUDIT",
            ].contains(userData?.levelUser!.split(' ')[0]))
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedPropertyView),
                title: const Text('Report Maintenance'),
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 150), () {
                    // navController.sideMenu.changePage(6);
                    // navController.pageController.jumpToPage(6);
                    navController.changePage(
                      [
                            "19",
                            "20",
                            "21",
                            "22",
                            "24",
                            "26",
                            "35",
                            "59",
                            "78",
                          ].contains(userData?.level)
                          ? 4
                          : 7,
                    );
                  });
                },
              ),
            if (![
              "PROJECT",
              "EDITORIAL",
              "AUDIT",
            ].contains(userData?.levelUser!.split(' ')[0]))
              ListTile(
                leading: const Icon(HugeIcons.strokeRoundedFolderImport),
                title: const Text('Request Form'),
                onTap: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 150), () {
                    // navController.sideMenu.changePage(7);
                    // navController.pageController.jumpToPage(7);
                    navController.changePage(
                      [
                            "19",
                            "20",
                            "21",
                            "22",
                            "24",
                            "26",
                            "35",
                            "59",
                            "78",
                          ].contains(userData?.level)
                          ? 5
                          : 8,
                    );
                  });
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              onTap: () {
                promptDialog(
                  context,
                  'Confirm',
                  'Anda yakin ingin keluar?',
                  () => auth.logout(),
                  false,
                  // isWideScreen,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
