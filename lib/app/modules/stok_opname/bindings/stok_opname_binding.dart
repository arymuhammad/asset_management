import 'package:get/get.dart';

import '../controllers/stok_opname_controller.dart';

class StokOpnameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StokOpnameController>(
      () => StokOpnameController(),
    );
  }
}
