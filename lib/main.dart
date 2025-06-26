import 'dart:convert';

import 'package:assets_management/app/modules/dashboard/views/dashboard_view.dart';
import 'package:assets_management/app/modules/dashboard/views/navbar.dart';
import 'package:assets_management/app/modules/dashboard/views/widget/persistant_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app/data/models/login_model.dart';
import 'app/data/utils/device/web_material_scroll.dart';
import 'app/modules/login/controllers/login_controller.dart';
import 'app/modules/login/views/login_view.dart';
import 'app/routes/app_pages.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('is_login') ?? false;
  var userDataLogin = prefs.getString('userDataLogin') ?? "";
  final auth = Get.put(LoginController());

  if (auth.isAuth.value == false) {
    auth.isAuth.value = status;
  }
  if (auth.logUser.value.id == null) {
    auth.logUser.value =
        userDataLogin != "" ? Data.fromJson(jsonDecode(userDataLogin)) : Data();
  }

  await initializeDateFormatting('id_ID', "").then(
    (_) => runApp(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Assets Management",
        themeMode: ThemeMode.light,
        theme: ThemeData(fontFamily: 'Nunito', useMaterial3: false),
        darkTheme: ThemeData.dark(),
        scrollBehavior: MyCustomScrollBehavior(),
        home: Obx(
          () =>
              auth.isAuth.value
                  ? 
                  PersistentSidebarLayout(userData: auth.logUser.value)
                  // NavBarView(
                  //   userData: auth.logUser.value,
                  // )
                  : const LoginView(),
        ),
        // localizationsDelegates: const [
        //   MonthYearPickerLocalizations.delegate,
        // ],
        // routerDelegate: router.routerDelegate,
        // routeInformationParser: router.routeInformationParser,
        // routeInformationProvider: router.routeInformationProvider,
        getPages: AppPages.routes,
      ),
    ),
  );
}
