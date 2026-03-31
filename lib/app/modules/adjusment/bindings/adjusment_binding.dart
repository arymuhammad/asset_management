import 'package:get/get.dart';

import '../controllers/adjusment_controller.dart';

class AdjusmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdjusmentController>(
      () => AdjusmentController(),
    );
  }
}
