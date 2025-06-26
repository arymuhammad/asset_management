// import 'package:assets_management/app/data/helper/custom_dialog.dart';
// import 'package:assets_management/app/data/models/login_model.dart';
// import 'package:assets_management/app/data/shared/rounded_image.dart';
// import 'package:assets_management/app/modules/barang_masuk/views/stok_in_view.dart';
// import 'package:assets_management/app/modules/dashboard/controllers/dashboard_controller.dart';
// import 'package:assets_management/app/modules/dashboard/views/dashboard_view.dart';
// import 'package:assets_management/app/modules/stok/views/stock_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_admin_scaffold/admin_scaffold.dart';
// import 'package:get/get.dart';
// import 'package:hugeicons/hugeicons.dart';
// import '../../../routes/app_pages.dart';
// import '../../barang_keluar/views/stok_out_view.dart';

// class NavBarView extends StatelessWidget {
//   NavBarView({super.key, required this.userData});

//   final Data userData;
//   final dashboardC = Get.put(DashboardController());

//   final List<AdminMenuItem> sideBarItems = const [
//     AdminMenuItem(
//       title: 'Dashboard',
//       route: Routes.DASHBOARD,
//       icon: HugeIcons.strokeRoundedHome03,
//     ),
//     AdminMenuItem(
//       title: 'Master',
//       icon: HugeIcons.strokeRoundedMasterCard,
//       children: [
//         AdminMenuItem(
//           title: 'Kategori',
//           route: Routes.KATEGORI,
//           icon: HugeIcons.strokeRoundedCatalogue,
//         ),
//         AdminMenuItem(
//           title: 'Asset',
//           route: Routes.ASSET,
//           icon: HugeIcons.strokeRoundedAssignments,
//         ),
//       ],
//     ),
//     AdminMenuItem(
//       title: 'Stok',
//       route: Routes.STOK,
//       icon: HugeIcons.strokeRoundedTask01,
//     ),
//     AdminMenuItem(
//       title: 'Barang Masuk',
//       route: Routes.BARANG_MASUK,
//       icon: HugeIcons.strokeRoundedShippingLoading,
//     ),
//     AdminMenuItem(
//       title: 'Barang Keluar',
//       route: Routes.BARANG_KELUAR,
//       icon: HugeIcons.strokeRoundedShippingTruck01,
//     ),
//     AdminMenuItem(
//       title: 'Report Maintenance',
//       route: Routes.REPORT_ISSUE,
//       icon: HugeIcons.strokeRoundedPropertyView,
//     ),
//     AdminMenuItem(
//       title: 'Request Form',
//       route: Routes.REQUEST_FORM,
//       icon: HugeIcons.strokeRoundedFolderImport,
//     ),
//     AdminMenuItem(
//       title: 'Log Out',
//       route: Routes.LOGIN,
//       icon: Icons.logout_rounded,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isWideScreen = constraints.maxWidth >= 800;
//         return Obx(
//           () => AdminScaffold(
//             appBar: AppBar(title: const Text('Asset Management')),
//             sideBar: SideBar(
//               items: sideBarItems,
//               selectedRoute: dashboardC.currentRoute.value,
//               activeBackgroundColor: Colors.black26,
//               borderColor: const Color(0xFFE7E7E7),
//               activeIconColor: Colors.blue,
//               textStyle: const TextStyle(
//                 color: Color(0xFF337ab7),
//                 fontSize: 13,
//               ),
//               activeTextStyle: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//               ),
//               header: Container(
//                 height: 80,
//                 width: double.infinity,
//                 color: const Color(0xff444444),
//                 child: Row(
//                   children: [
//                     RoundedImage(
//                       height: 80,
//                       width: 80,
//                       foto: userData.foto!,
//                       name: userData.nama!,
//                       headerProfile: true,
//                     ),
//                     const SizedBox(width: 5),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(userData.nama!),
//                         Text(userData.levelUser!),
//                         Text(userData.namaCabang!),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               onSelected: (item) {
//                 if (item.route != null &&
//                     item.route != dashboardC.currentRoute.value) {
//                   if (item.route == Routes.LOGIN) {
//                     promptDialog(
//                       context,
//                       'LOG OUT',
//                       'Anda yakin ingin keluar?',
//                       () {
//                         dashboardC.currentRoute.value = Routes.DASHBOARD;
//                         auth.logout();
//                         // Get.offAllNamed(Routes.LOGIN);
//                       },
//                       isWideScreen,
//                     );
//                   } else {
//                     dashboardC.currentRoute.value = item.route!;
//                     // Navigasi dengan pushReplacement agar halaman lama dan controller dihapus
//                     dashboardC.navigatorKey.currentState?.pushReplacement(
//                       GetPageRoute(
//                         routeName: item.route!,
//                         page: () => _getPage(item.route!),
//                         binding: _getBinding(item.route!),
//                         // settings: RouteSettings(
//                         //   name: item.route!,
//                         //   arguments: userData,
//                         // ),
//                         transition: Transition.noTransition,
//                       ),
//                     );
//                   }
//                 }
//               },
//             ),
//             body: Navigator(
//               key: dashboardC.navigatorKey,
//               initialRoute: dashboardC.currentRoute.value,
//               onGenerateRoute: (settings) {
//                 return GetPageRoute(
//                   settings: settings,
//                   page: () => _getPage(settings.name!),
//                   binding: _getBinding(settings.name!),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Helper untuk mendapatkan halaman sesuai route
//   Widget _getPage(String route) {
//     final page = AppPages.routes.firstWhereOrNull((p) => p.name == route)?.page;
//     if (page != null) {
//       if (route == Routes.DASHBOARD) {
//         return DashboardView(userData: userData);
//       } else if (route == Routes.STOK) {
//         return StockView(userData: userData);
//       } else if (route == Routes.BARANG_MASUK) {
//         return StokInView(userData: userData);
//       } else if (route == Routes.BARANG_KELUAR) {
//         return StokOutView(userData: userData);
//       }
//       return page();
//     }
//     return const Center(child: Text('Page not found'));
//   }

//   // Helper untuk mendapatkan binding sesuai route
//   Bindings? _getBinding(String route) {
//     return AppPages.routes.firstWhereOrNull((p) => p.name == route)?.binding;
//   }
// }
