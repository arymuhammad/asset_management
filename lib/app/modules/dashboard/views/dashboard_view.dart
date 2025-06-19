import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../data/models/login_model.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key, this.userData});
  final Data? userData;

  @override
  Widget build(BuildContext context) {
  
    print(userData!.id!);
    return Center(
      child: Text(userData!.nama!),
    );
  }
}
