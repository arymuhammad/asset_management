import 'package:assets_management/app/modules/stok/views/stock_view.dart';
import 'package:get/get.dart';

import '../modules/barang_keluar/bindings/barang_keluar_binding.dart';
import '../modules/barang_keluar/views/stok_out_view.dart';
import '../modules/barang_masuk/bindings/barang_masuk_binding.dart';
import '../modules/barang_masuk/views/stok_in_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/master_barang/bindings/master_barang_binding.dart';
import '../modules/master_barang/views/assets_view.dart';
import '../modules/master_barang/views/kategori_view.dart';
import '../modules/report_issue/bindings/report_issue_binding.dart';
import '../modules/report_issue/views/report_issue_view.dart';
import '../modules/request_form/bindings/request_form_binding.dart';
import '../modules/request_form/views/request_form_view.dart';
import '../modules/stok/bindings/stok_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.STOK,
      page: () => StockView(),
      binding: StokBinding(),
    ),
    GetPage(
      name: _Paths.BARANG_MASUK,
      page: () => StokInView(),
      binding: BarangMasukBinding(),
    ),
    GetPage(
      name: _Paths.BARANG_KELUAR,
      page: () => StokOutView(),
      binding: BarangKeluarBinding(),
    ),
    GetPage(
      name: _Paths.KATEGORI,
      page: () => KategoriView(),
      binding: MasterBarangBinding(),
    ),
    GetPage(
      name: _Paths.ASSET,
      page: () => AssetsView(),
      binding: MasterBarangBinding(),
    ),
    GetPage(
      name: _Paths.REPORT_ISSUE,
      page: () => ReportIssueView(),
      binding: ReportIssueBinding(),
    ),
    GetPage(
      name: _Paths.REQUEST_FORM,
      page: () => RequestFormView(),
      binding: RequestFormBinding(),
    ),
  ];
}
