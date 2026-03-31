import 'package:get/get.dart';
import '../PrescriptionController/PrescriptionController.dart';

class PrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrescriptionController>(() => PrescriptionController());
  }
}
