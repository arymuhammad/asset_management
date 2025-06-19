import 'package:get/get.dart';

import '../controllers/master_barang_controller.dart';

class MasterBarangBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasterBarangController>(
      () => MasterBarangController(),
    );
  }
}
