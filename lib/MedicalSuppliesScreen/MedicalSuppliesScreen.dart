import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'MedicalController/MedicalController.dart';
import '../CategoryProductScreen/CategoryProductsScreen.dart';
import '../MedicalCartScreen/MedicalCartScreen.dart';
import 'MedicalDescriptionScreen/MedicalDescriptionScreen.dart';
import '../UploadPrescriptionScreen/UploadPrescriptionScreen.dart';

class MedicalSuppliesScreen extends StatefulWidget {
  const MedicalSuppliesScreen({super.key});
  @override
  State<MedicalSuppliesScreen> createState() => _MedicalSuppliesScreenState();
}

class _MedicalSuppliesScreenState extends State<MedicalSuppliesScreen> {
  final MedicalController controller = Get.put(MedicalController(), permanent: true);
  final TextEditingController _searchController = TextEditingController();
  final RxString _query = "".obs;
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background like Daraz
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Medical Supplies", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Obx(() => IconButton(
            icon: Badge(
              label: Text(controller.cartItems.length.toString()),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
            onPressed: () => Get.to(() => MedicalCartScreen(
                cartItems: controller.cartItems,
                onCartUpdated: () => setState(() {}))),
          ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 Search Bar
            Container(
              color: primaryColor,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => _query.value = val,
                decoration: InputDecoration(
                  hintText: "Search for medicine",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🖼️ Carousel
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/carousel1.png",
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  /// 📁 Categories List
                  SizedBox(
                    height: 100,
                    child: Obx(() => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) => categoryItem(controller.categories[index]),
                    )),
                  ),

                  const SizedBox(height: 20),

                  /// ➕ Add Prescription Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => const UploadPrescriptionScreen()),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Prescription", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text("Just For You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  /// 🔄 Product Menu (Daraz Grid Style)
                  Obx(() {
                    var filteredList = controller.allAvailableMedicines.where((p) =>
                        p['name'].toString().toLowerCase().contains(_query.value.toLowerCase())).toList();

                    if (controller.isLoading.value && filteredList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row like Daraz
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72, // Adjust aspect ratio for vertical card
                      ),
                      itemBuilder: (context, index) => darazProductCard(filteredList[index]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryItem(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () => Get.to(() => CategoryProductsScreen(category: cat)),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8), width: 85,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    cat['imageUrl'] ?? "",
                    height: 40, width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(Icons.category, color: primaryColor))),
            const SizedBox(height: 5),
            Text(cat['name'] ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  /// DARAZ STYLE GRID CARD
  Widget darazProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Get.to(() => MedicalDescriptionScreen(
          product: product,
          cartItems: controller.cartItems,
          onCartUpdated: () => controller.cartItems.refresh()
      )),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image (Top)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Image.network(
                      product['imageUrl'] ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.medication, color: primaryColor, size: 50)),
                ),
              ),
            ),
            // Product Details (Bottom)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? "Unknown",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs. ${product['price'] ?? 0}",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => controller.addToCart(product),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                      ),
                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}