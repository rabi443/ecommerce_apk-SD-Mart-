import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/BaseUrl.dart';

class MedicalController extends GetxController {
  final GetStorage box = GetStorage();

  var isLoading = false.obs;
  var isCategoryLoading = false.obs;
  var isProductLoading = false.obs;

  var products = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;
  var categoryMedicines = <Map<String, dynamic>>[].obs;
  var cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchGeneralMedicines();
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  };

  List<Map<String, dynamic>> get allAvailableMedicines {
    final combined = [...products, ...categoryMedicines];
    final seenIds = <dynamic>{};
    return combined.where((item) {
      final id = item['medicineId'] ?? item['id'];
      return id != null && seenIds.add(id);
    }).toList();
  }

  void addToCart(Map<String, dynamic> product) {
    final dynamic id = product['medicineId'] ?? product['id'];
    final index = cartItems.indexWhere((item) => item['id'] == id);

    if (index != -1) {
      cartItems[index]['quantity']++;
      cartItems.refresh();
    } else {
      cartItems.add({...product, "id": id, "quantity": 1});
    }

    Get.snackbar(
      "Cart Updated", "${product['name']} added successfully",
      backgroundColor: const Color(0xFFEB9F3F),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> fetchCategories() async {
    try {
      isCategoryLoading(true);
      final response = await http.get(Uri.parse(BaseUrl.medicineCategories), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        categories.assignAll(data.cast<Map<String, dynamic>>());
      }
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchGeneralMedicines() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(BaseUrl.medicines), headers: _headers);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        products.assignAll(data.cast<Map<String, dynamic>>());
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMedicinesByCategory(String categoryId) async {
    try {
      isProductLoading(true);
      categoryMedicines.clear();
      final response = await http.get(Uri.parse(BaseUrl.getMedicinesByCategory(categoryId)), headers: _headers);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> listToAssign = (data is List) ? data : (data['data'] ?? []);
        categoryMedicines.assignAll(listToAssign.cast<Map<String, dynamic>>());
      }
    } finally {
      isProductLoading(false);
    }
  }
}