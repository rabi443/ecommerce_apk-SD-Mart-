import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../MapPickerScreen/MapPickerScreen.dart';
import '../FoodOrderController/FoodOrderController.dart';

class FoodCheckoutDeliveryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> preparedItems;
  final double totalAmount;

  FoodCheckoutDeliveryScreen({super.key, required this.preparedItems, required this.totalAmount})
      : controller = Get.put(FoodOrderController());

  final FoodOrderController controller;
  final Color primaryColor = const Color(0xFFEB9F3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Delivery Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("Full Address"),
                  TextField(
                    controller: controller.addressController,
                    cursorColor: primaryColor, // Added primary color to cursor
                    decoration: _inputStyle("House No, Street, Area", Icons.home),
                  ),
                  const SizedBox(height: 20),
                  _title("Pin Map Location"),
                  _buildMapCard(context),
                  const SizedBox(height: 20),
                  _title("Notes for Rider"),
                  TextField(
                    controller: controller.instructionController,
                    cursorColor: primaryColor, // Added primary color to cursor
                    decoration: _inputStyle("E.g. Call when arrived", Icons.note_add),
                  ),
                  const SizedBox(height: 30),
                  _summaryCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmBtn(),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 25),
    decoration: BoxDecoration(color: primaryColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
    child: const Column(children: [Icon(Icons.delivery_dining, color: Colors.white, size: 40), SizedBox(height: 10), Text("Deliver Food To?", style: TextStyle(color: Colors.white))]),
  );

  Widget _buildMapCard(BuildContext context) => Obx(() => Container(
    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
    child: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _coord("Lat", controller.latitude.value),
        _coord("Lng", controller.longitude.value),
      ])),
      const Divider(height: 1),
      TextButton.icon(
        // FIXED: Applied primary color to the Map Picker button
        style: TextButton.styleFrom(foregroundColor: primaryColor),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          final result = await Get.to(() => MapPickerScreen(themeColor: primaryColor));
          if (result != null && result is LatLng) {
            controller.latitude.value = result.latitude;
            controller.longitude.value = result.longitude;
          }
        },
        icon: const Icon(Icons.map_rounded),
        label: const Text("OPEN MAP PICKER", style: TextStyle(fontWeight: FontWeight.bold)),
      )
    ]),
  ));

  Widget _buildConfirmBtn() => Padding(
    padding: const EdgeInsets.all(20),
    child: Obx(() => ElevatedButton(
      onPressed: controller.isPlacingOrder.value ? null : () => controller.submitOrder(preparedItems),
      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: controller.isPlacingOrder.value
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("CONFIRM FOOD ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    )),
  );

  Widget _title(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _coord(String label, double? val) => Column(children: [Text(label, style: const TextStyle(fontSize: 10)), Text(val?.toStringAsFixed(4) ?? "None", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor))]);

  Widget _summaryCard() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFFF9F2), borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Payable", style: TextStyle(fontWeight: FontWeight.bold)), Text("Rs. ${totalAmount.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor))]));

  // FIXED: Applied focusedBorder so the input field outline changes to #eb9f3f instead of default blue when typing
  InputDecoration _inputStyle(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: primaryColor),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
  );
}