import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserController extends GetxController {
  final GetStorage box = GetStorage();

  RxString name = "User".obs;
  RxString role = "Customer".obs;

  @override
  void onInit() {
    super.onInit();
    name.value = box.read('name') ?? "User";
    role.value = box.read('role') ?? "Customer";
  }

  void setUser({required String name, required String role}) {
    this.name.value = name;
    this.role.value = role;
    box.write('name', name);
    box.write('role', role);
  }

  void clearUser() {
    name.value = "User";
    role.value = "Customer";
    box.erase();
  }
}