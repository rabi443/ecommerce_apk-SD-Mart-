import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FoodService/FoodService.dart'; // Adjust import path if needed

class FoodController extends GetxController {
  final FoodService _foodService = FoodService();

  var allMenuItems = <dynamic>[].obs;
  var foodCategories = <dynamic>[].obs;
  var isLoading = false.obs;
  var isCategoryLoading = false.obs;

  var categoryItems = <dynamic>[].obs;
  var isCategoryItemLoading = false.obs;

  var selectedProductDetails = {}.obs;
  var isDetailLoading = false.obs;

  // Source of truth for the cart.
  // Explicitly defined as Map<String, dynamic> to securely mutate quantities
  var cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    await fetchCategories();
    await fetchAllFood();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoryLoading(true);
      var data = await _foodService.getFoodCategories();
      foodCategories.assignAll(data);
    } finally {
      isCategoryLoading(false);
    }
  }

  Future<void> fetchAllFood() async {
    try {
      isLoading(true);
      var items = await _foodService.getAllFoodItems();
      allMenuItems.assignAll(items);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchItemsByCategory(String id) async {
    try {
      isCategoryItemLoading(true);
      categoryItems.clear();
      var items = await _foodService.getFoodByCategory(id);
      categoryItems.assignAll(items);
    } finally {
      isCategoryItemLoading(false);
    }
  }

  Future<void> fetchItemDetails(String id) async {
    try {
      isDetailLoading(true);
      selectedProductDetails.clear();
      var details = await _foodService.getFoodItemDetails(id);
      selectedProductDetails.value = details;
    } catch (e) {
      debugPrint("Detail Error: $e");
    } finally {
      isDetailLoading(false);
    }
  }

  // --- CART METHODS ---

  void addToCart(dynamic product) {
    // 1. Get the ID reliably based on your API response keys
    String id = (product['menuItemId'] ?? product['id'] ?? product['_id'] ?? "").toString();

    // 2. Check if the item is already in the cart
    int existingIndex = cartItems.indexWhere((item) {
      String itemId = (item['menuItemId'] ?? item['id'] ?? item['_id'] ?? "").toString();
      return itemId == id;
    });

    if (existingIndex != -1) {
      // 3. If exists, just increment the quantity
      cartItems[existingIndex]['quantity'] += 1;
      cartItems.refresh(); // Crucial: Tells GetX to update the UI
      Get.snackbar(
        "Updated Cart",
        "${product['name']} quantity increased",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 1),
      );
    } else {
      // 4. If it doesn't exist, add it with quantity = 1
      Map<String, dynamic> newItem = Map<String, dynamic>.from(product);
      newItem['quantity'] = 1;
      cartItems.add(newItem);

      Get.snackbar(
        "Added to Cart",
        "${product['name']} added",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // Called from FoodCartScreen when clicking '+'
  void incrementItem(int index) {
    cartItems[index]['quantity']++;
    cartItems.refresh();
  }

  // Called from FoodCartScreen when clicking '-'
  void decrementItem(int index) {
    if (cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity']--;
      cartItems.refresh();
    }
  }

  // Called from FoodCartScreen when clicking the trash/close icon
  void removeCartItem(int index) {
    cartItems.removeAt(index);
  }

  // Dynamically calculates the subtotal for Cart and Checkout screens
  double get subtotal {
    return cartItems.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int qty = item['quantity'] ?? 1;
      return sum + (price * qty);
    });
  }

  void clearCart() {
    cartItems.clear();
  }
}