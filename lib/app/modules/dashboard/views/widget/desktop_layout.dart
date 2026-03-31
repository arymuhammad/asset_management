import 'package:assets_management/app/modules/adjusment/views/adjusment_in.dart';
import 'package:assets_management/app/modules/adjusment/views/adjusment_out.dart';
import 'package:assets_management/app/modules/report_issue/views/report_issue_view.dart';
import 'package:assets_management/app/modules/report_issue/views/widget/report_list.dart';
import 'package:assets_management/app/modules/stok_opname/views/stok_opname_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/helper/app_colors.dart';
import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/helper/sidebar_helper.dart';
import '../../../../data/models/login_model.dart';
import '../../../barang_keluar/views/stok_out_view.dart';
import '../../../barang_masuk/views/stok_in_view.dart';
import '../../../master_barang/views/assets_view.dart';
import '../../../master_barang/views/kategori_view.dart';
import '../../../request_form/views/request_form_view.dart';
import '../../../stok/views/stock_view.dart';
import '../../controllers/dashboard_controller.dart';
import '../dashboard_view.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({
    super.key,
    this.userData,
    required this.navController,
    required this.isWideScreen,
  });
  final Data? userData;
  final DashboardController navController;
  final bool isWideScreen;

  @override
  Widget build(BuildContext context) {
    final level = userData?.levelUser?.split(' ').first;
    // print(level);
    List<Widget> pages = [
      if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
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
        KategoriView(userData:userData),
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
        AssetsView(userData: userData),
      StokInView(userData: userData),
      StokOutView(userData: userData),
      AdjusmentIn(userData: userData),
      AdjusmentOut(userData: userData),
      StockView(userData: userData),
      if (["IT", "AUDIT", "BRAND"].contains(level))
        StokOpnameView(userData: userData),

      if (["BRAND", "IT"].contains(level))
        ReportListView(userData: userData)
      else if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
        ReportIssueView(userData: userData, isHO: false),

      if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level)) RequestFormView(),
      const Text('Logout'),
    ];

    return Obx(() {
      if (!navController.isReady.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      // final expandedIndex = navController.expandedMenu.value;

      // final List<SideMenuItemType> items = [
      //   if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
      //     SideMenuItem(
      //       title: 'Dashboard',
      //       onTap: (index, _) {
      //         // navController.sideMenu.changePage(index);
      //         navController.changePage(index);
      //       },
      //       icon: const Icon(HugeIcons.strokeRoundedHome03),
      //     ),
      //   if (![
      //     "19",
      //     "20",
      //     "21",
      //     "22",
      //     "24",
      //     "26",
      //     "35",
      //     "59",
      //     "78",
      //   ].contains(userData?.level)) // Hanya tampilkan jika levelUser 1
      //     SideMenuExpansionItem(
      //       key: ValueKey("master_$expandedIndex"),
      //       title: "Master",
      //       icon: const Icon(Icons.blinds, color: Colors.white),
      //       onTap:
      //           (index, _, isExpanded) => {
      //             navController.toggleExpansion(0),
      //             // print('$index, expanded $isExpanded'),
      //           },
      //       initialExpanded: expandedIndex == 0,
      //       children: [
      //         SideMenuItem(
      //           title: 'Kategori',
      //           onTap: (index, _) {
      //             // navController.sideMenu.changePage(index);
      //             navController.changePage(index);
      //           },
      //           icon: const Icon(HugeIcons.strokeRoundedCatalogue),
      //         ),
      //         SideMenuItem(
      //           title: 'Asset',
      //           onTap: (index, _) {
      //             // navController.sideMenu.changePage(index);
      //             navController.changePage(index);
      //           },
      //           icon: const Icon(HugeIcons.strokeRoundedAssignments),
      //         ),
      //       ],
      //     ),
      //   SideMenuItem(
      //     title: 'Stok',
      //     onTap: (index, _) {
      //       // navController.sideMenu.changePage(index);
      //       navController.changePage(index);
      //     },
      //     icon: const Icon(HugeIcons.strokeRoundedTask01),
      //   ),
      //   // SideMenuItem(
      //   //   title: 'Barang Masuk',
      //   //   onTap: (index, _) {
      //   //     // navController.sideMenu.changePage(index);
      //   //     navController.changePage(index);
      //   //   },
      //   //   icon: const Icon(HugeIcons.strokeRoundedShippingLoading),
      //   // ),
      //   // SideMenuItem(
      //   //   title: 'Barang Keluar',
      //   //   onTap: (index, _) {
      //   //     // navController.sideMenu.changePage(index);
      //   //     navController.changePage(index);
      //   //   },
      //   //   icon: const Icon(HugeIcons.strokeRoundedShippingTruck01),
      //   // ),
      //   SideMenuExpansionItem(
      //     key: ValueKey("distribusi_$expandedIndex"),
      //     title: "Distribusi",
      //     icon: const Icon(Icons.local_shipping_rounded, color: Colors.white),
      //     onTap:
      //         (index, _, isExpanded) => {
      //           navController.toggleExpansion(1),
      //           // print('$index, expanded $isExpanded'),
      //         },
      //     initialExpanded: expandedIndex == 1,
      //     children: [
      //       SideMenuItem(
      //         title: 'Barang Masuk',
      //         onTap: (index, _) {
      //           // navController.sideMenu.changePage(index);
      //           navController.changePage(index);
      //         },
      //         icon: const Icon(HugeIcons.strokeRoundedCatalogue),
      //       ),
      //       SideMenuItem(
      //         title: 'Barang Keluar',
      //         onTap: (index, _) {
      //           // navController.sideMenu.changePage(index);
      //           navController.changePage(index);
      //         },
      //         icon: const Icon(HugeIcons.strokeRoundedAssignments),
      //       ),
      //     ],
      //   ),
      //   SideMenuExpansionItem(
      //     key: ValueKey("adjusment_$expandedIndex"),
      //     title: "Adjusment",
      //     icon: const Icon(Icons.compare_arrows_outlined, color: Colors.white),
      //     onTap:
      //         (index, _, isExpanded) => {
      //           navController.toggleExpansion(2),
      //           // print('$index, expanded $isExpanded'),
      //         },
      //     initialExpanded: expandedIndex == 2,
      //     children: [
      //       SideMenuItem(
      //         title: 'Adjusment In',
      //         onTap: (index, _) {
      //           // navController.sideMenu.changePage(index);
      //           navController.changePage(index);
      //         },
      //         icon: const Icon(HugeIcons.strokeRoundedCatalogue),
      //       ),
      //       SideMenuItem(
      //         title: 'Adjusment Out',
      //         onTap: (index, _) {
      //           // navController.sideMenu.changePage(index);
      //           navController.changePage(index);
      //         },
      //         icon: const Icon(HugeIcons.strokeRoundedAssignments),
      //       ),
      //     ],
      //   ),
      //   if (["IT", "AUDIT", "BRAND"].contains(level))
      //     SideMenuItem(
      //       title: 'Stok Opname',
      //       onTap: (index, _) {
      //         // navController.sideMenu.changePage(index);
      //         navController.changePage(index);
      //       },
      //       icon: const Icon(HugeIcons.strokeRoundedBookEdit),
      //     ),
      //   if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
      //     SideMenuItem(
      //       title: 'Report Maintenance',
      //       onTap: (index, _) {
      //         // navController.sideMenu.changePage(index);
      //         navController.changePage(index);
      //       },
      //       icon: const Icon(HugeIcons.strokeRoundedPropertyView),
      //     ),
      //   if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
      //     SideMenuItem(
      //       title: 'Request Form',
      //       onTap: (index, _) {
      //         // navController.sideMenu.changePage(index);
      //         navController.changePage(index);
      //       },
      //       icon: const Icon(HugeIcons.strokeRoundedFolderImport),
      //     ),
      //   // SideMenuItem(
      //   //   title: 'Exit',
      //   //   onTap: (index, _) {
      //   //     promptDialog(
      //   //       context,
      //   //       'Confirm',
      //   //       'Anda yakin ingin keluar?',
      //   //       () => auth.logout(),
      //   //       isWideScreen,
      //   //     );
      //   //   },
      //   //   icon: const Icon(Icons.logout_rounded),
      //   // ),
      // ];
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
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
              Visibility(
                visible: isWideScreen ? true : false,
                child: InkWell(
                  onTap: () {
                    promptDialog(
                      context,
                      'Confirm',
                      'Anda yakin ingin keluar?',
                      () => auth.logout(),
                      isWideScreen,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.power,
                          color: Colors.redAccent[700],
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.itemsBackground,
        ),
        body: Row(
          children: [
            buildSidebar(navController, userData, level!),
            // SideMenu(
            //   // key: sideMenuKey, // <--- tambahkan ini
            //   // title: Padding(
            //   //   padding: const EdgeInsets.all(8.0),
            //   //   child: Row(
            //   //     children: [
            //   //       ConstrainedBox(
            //   //         constraints: const BoxConstraints(
            //   //           maxHeight: 100,
            //   //           maxWidth: 100,
            //   //         ),
            //   //         child: RoundedImage(
            //   //           headerProfile: true,
            //   //           foto: userData!.foto!,
            //   //           height: isWideScreen ? 70 : 50,
            //   //           width: isWideScreen ? 70 : 50,
            //   //           name: userData!.nama!,
            //   //         ),
            //   //       ),
            //   //       const SizedBox(width: 5),
            //   //       // const Divider(indent: 8.0, endIndent: 8.0, thickness: 2),
            //   //       Visibility(
            //   //         visible: isWideScreen ? true : false,
            //   //         child: Column(
            //   //           crossAxisAlignment: CrossAxisAlignment.start,
            //   //           children: [
            //   //             Text(
            //   //               userData!.nama!,
            //   //               style: const TextStyle(
            //   //                 color: Colors.white,
            //   //                 fontSize: 14,
            //   //               ),
            //   //             ),
            //   //             SizedBox(
            //   //               width: 90,
            //   //               child: Text(
            //   //                 userData!.levelUser!,
            //   //                 style: const TextStyle(
            //   //                   fontSize: 10,
            //   //                   color: Colors.grey,
            //   //                 ),
            //   //               ),
            //   //             ),
            //   //             // Text(
            //   //             //   userData!.namaCabang!,
            //   //             //   style: const TextStyle(
            //   //             //     fontSize: 12,
            //   //             //     color: Colors.grey,
            //   //             //   ),
            //   //             // ),
            //   //           ],
            //   //         ),
            //   //       ),
            //   //     ],
            //   //   ),
            //   // ),
            //   // footer: Padding(
            //   //   padding: const EdgeInsets.all(8.0),
            //   //   child: Container(
            //   //     decoration: BoxDecoration(
            //   //       color: Colors.lightBlue[50],
            //   //       borderRadius: BorderRadius.circular(12),
            //   //     ),
            //   //     child: Padding(
            //   //       padding: const EdgeInsets.symmetric(
            //   //         vertical: 4,
            //   //         horizontal: 10,
            //   //       ),
            //   //       child: Text(
            //   //         '\u00A9 URBAN&CO ${DateFormat('yyyy').format(DateTime.now())}',
            //   //         style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            //   //       ),
            //   //     ),
            //   //   ),
            //   // ),
            //   controller: navController.sideMenu,
            //   items: items,
            //   style: SideMenuStyle(
            //     displayMode: SideMenuDisplayMode.open, // Otomatis responsive
            //     openSideMenuWidth: 200,
            //     compactSideMenuWidth: 70,
            //     arrowCollapse: AppColors.borderColor,
            //     arrowOpen: AppColors.contentColorWhite,
            //     backgroundColor: AppColors.itemsBackground,
            //     unselectedIconColor: Colors.white70,
            //     selectedIconColor: Colors.white,
            //     selectedColor: AppColors.contentColorBlue.withAlpha(100),
            //     unselectedTitleTextStyle: const TextStyle(
            //       color: Colors.white70,
            //       fontSize: 14,
            //     ),
            //     selectedTitleTextStyle: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 14,
            //     ),
            //     hoverColor: Colors.white12,
            //     showHamburger: true, // Tombol hamburger untuk toggle sidebar
            //   ),
            // ),
            Expanded(
              child: PageView(
                controller: navController.pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // menonaktifkan swipe/drag
                children: pages,
              ),
            ),
          ],
        ),
      );
    });
  }
}

Widget buildSidebar(DashboardController nav, Data? userData, String level) {
  return Obx(() {
    final collapsed = nav.isCollapsed.value;
    final expanded = nav.expandedIndex.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 70 : 240,
      color: AppColors.itemsBackground,
      child: Column(
        children: [
          /// HEADER
          Container(
            height: 60,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child:
                collapsed
                    ? IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: nav.toggleSidebar,
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData!.nama!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                userData.levelUser!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                userData.namaCabang!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: nav.toggleSidebar,
                        ),
                      ],
                    ),
          ),

          const Divider(color: Colors.white24),

          Expanded(
            child: ListView(
              children: [
                /// DASHBOARD
                if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
                  sidebarItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    collapsed: collapsed,
                    index: 0,
                    nav: nav,
                  ),

                /// MASTER
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
                  sidebarExpansion(
                    icon: Icons.inventory_2,
                    title: "Master",
                    index: 0,
                    // collapsed: collapsed,
                    // expandedIndex: expanded,
                    // onTap: () => nav.toggleExpansion(0),
                    children: [
                      sidebarSubItem(
                        icon: HugeIcons.strokeRoundedCatalogue,
                        title: "Kategori",
                        // collapsed: collapsed,
                        index: (["AUDIT"].contains(level)) ? 0 : 1,
                        nav: nav,
                      ),
                      sidebarSubItem(
                        icon: HugeIcons.strokeRoundedAssignments,
                        title: "Asset",
                        // collapsed: collapsed,
                        index: (["AUDIT"].contains(level)) ? 1 : 2,
                        nav: nav,
                      ),
                    ],
                    nav: nav,
                  ),

                /// DISTRIBUSI
                sidebarExpansion(
                  icon: Icons.local_shipping,
                  title: "Distribusi",
                  index: 1,
                  // collapsed: collapsed,
                  // expandedIndex: expanded,
                  // onTap: () => nav.toggleExpansion(1),
                  children: [
                    sidebarSubItem(
                      icon: HugeIcons.strokeRoundedCatalogue,
                      title: "Barang Masuk",
                      // collapsed: collapsed,
                      index:
                          (![
                                    "19",
                                    "20",
                                    "21",
                                    "22",
                                    "24",
                                    "26",
                                    "35",
                                    "59",
                                    "78",
                                  ].contains(userData?.level)) &&
                                  (!["AUDIT"].contains(level))
                              ? 3
                              : (["AUDIT"].contains(level))
                              ? 2
                              : 1,
                      nav: nav,
                    ),
                    sidebarSubItem(
                      icon: HugeIcons.strokeRoundedAssignments,
                      title: "Barang Keluar",
                      // collapsed: collapsed,
                      index:
                          (![
                                    "19",
                                    "20",
                                    "21",
                                    "22",
                                    "24",
                                    "26",
                                    "35",
                                    "59",
                                    "78",
                                  ].contains(userData?.level)) &&
                                  (!["AUDIT"].contains(level))
                              ? 4
                              : (["AUDIT"].contains(level))
                              ? 3
                              : 2,
                      nav: nav,
                    ),
                  ],
                  nav: nav,
                ),

                /// ADJUSTMENT
                sidebarExpansion(
                  icon: Icons.compare_arrows,
                  title: "Adjustment",
                  index: 2,
                  // collapsed: collapsed,
                  // expandedIndex: expanded,
                  // onTap: () => nav.toggleExpansion(2),
                  children: [
                    sidebarSubItem(
                      icon: HugeIcons.strokeRoundedCatalogue,
                      title: "Adjustment In",
                      // collapsed: collapsed,
                      index:
                          (![
                                    "19",
                                    "20",
                                    "21",
                                    "22",
                                    "24",
                                    "26",
                                    "35",
                                    "59",
                                    "78",
                                  ].contains(userData?.level)) &&
                                  (!["AUDIT"].contains(level))
                              ? 5
                              : (["AUDIT"].contains(level))
                              ? 4
                              : 3,
                      nav: nav,
                    ),
                    sidebarSubItem(
                      icon: HugeIcons.strokeRoundedAssignments,
                      title: "Adjustment Out",
                      // collapsed: collapsed,
                      index:
                          (![
                                    "19",
                                    "20",
                                    "21",
                                    "22",
                                    "24",
                                    "26",
                                    "35",
                                    "59",
                                    "78",
                                  ].contains(userData?.level)) &&
                                  (!["AUDIT"].contains(level))
                              ? 6
                              : (["AUDIT"].contains(level))
                              ? 5
                              : 4,
                      nav: nav,
                    ),
                  ],
                  nav: nav,
                ),

                /// STOK
                sidebarItem(
                  icon: HugeIcons.strokeRoundedTask01,
                  title: "Stok",
                  collapsed: collapsed,
                  index:
                      (![
                                "19",
                                "20",
                                "21",
                                "22",
                                "24",
                                "26",
                                "35",
                                "59",
                                "78",
                              ].contains(userData?.level)) &&
                              (!["AUDIT"].contains(level))
                          ? 7
                          : (["AUDIT"].contains(level))
                          ? 6
                          : 5,
                  nav: nav,
                ),

                /// STOK OPNAME
                if (["IT", "AUDIT", "BRAND"].contains(level))
                  sidebarItem(
                    icon: HugeIcons.strokeRoundedBookEdit,
                    title: "Stok Opname",
                    collapsed: collapsed,
                    index: (["AUDIT"].contains(level)) ? 7 : 8,
                    nav: nav,
                  ),

                /// REPORT MAINTENANCE
                if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
                  sidebarItem(
                    icon: HugeIcons.strokeRoundedPropertyView,
                    title: "Report Maintenance",
                    collapsed: collapsed,
                    index:
                        (![
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
                            ? 9
                            : 6,
                    nav: nav,
                  ),

                /// REQUEST FORM
                if (!["PROJECT", "EDITORIAL", "AUDIT"].contains(level))
                  sidebarItem(
                    icon: HugeIcons.strokeRoundedFolderImport,
                    title: "Request Form",
                    collapsed: collapsed,
                    index:
                        (![
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
                            ? 10
                            : 7,
                    nav: nav,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}
