import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../MapPickerScreen/MapPickerScreen.dart';
import '../UploadPrescriptionScreen/PrescriptionController/PrescriptionController.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final List<File> images;
  final String description;

  const DeliveryDetailsScreen({
    super.key,
    required this.images,
    required this.description,
  });

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final PrescriptionController controller = Get.find<PrescriptionController>();

  // Controllers for all fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  // Brand Colors
  final Color primaryColor = const Color(0xFFEB9F3F);
  final Color lightBg = const Color(0xFFFEF5E7);

  @override
  void dispose() {
    _addressController.dispose();
    _instructionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  /// This function now handles the "Enter Current Location" action by opening the Map
  Future<void> _openMapPicker() async {
    final initialPosition = (_latController.text.isNotEmpty &&
        _lngController.text.isNotEmpty)
        ? LatLng(double.tryParse(_latController.text) ?? 0.0,
        double.tryParse(_lngController.text) ?? 0.0)
        : null;

    final result = await Get.to(
          () => MapPickerScreen(
        initialPosition: initialPosition,
        themeColor: primaryColor,
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _latController.text = result.latitude.toStringAsFixed(6);
        _lngController.text = result.longitude.toStringAsFixed(6);
      });
    }
  }

  void _submit() {
    if (_addressController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Delivery address is required',
          backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat == null || lng == null) {
      Get.snackbar('Coordinates Required', 'Please enter your location using the map.',
          backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    controller.submitPrescription(
      images: widget.images,
      description: widget.description,
      address: _addressController.text.trim(),
      latitude: lat,
      longitude: lng,
      specialInstruction: _instructionController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Delivery Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Decorative Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.local_shipping, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    "Almost there! Tell us where to deliver.",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: ADDRESS ---
                  _buildSectionTitle("Shipping Address"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    cursorColor: primaryColor,
                    maxLines: 2,
                    decoration: _inputDecoration(
                        "Full Delivery Address *", Icons.home_outlined),
                  ),
                  const SizedBox(height: 20),

                  // --- SECTION: LOCATION PICKER ---
                  _buildSectionTitle("GPS Location"),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCoordinateItem("Latitude",
                                  _latController.text.isEmpty ? 'Not Set' : _latController.text),
                            ),
                            Container(
                                width: 1,
                                height: 30,
                                color: primaryColor.withOpacity(0.2)),
                            Expanded(
                              child: _buildCoordinateItem("Longitude",
                                  _lngController.text.isEmpty ? 'Not Set' : _lngController.text),
                            ),
                          ],
                        ),
                        const Divider(),

                        // Updated Button Logic: "Enter Current Location" opens map
                        TextButton.icon(
                          onPressed: _openMapPicker,
                          icon: Icon(Icons.my_location, color: primaryColor),
                          label: Text(
                            "Enter Current Location",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SECTION: INSTRUCTIONS ---
                  _buildSectionTitle("Notes for Rider"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _instructionController,
                    maxLines: 2,
                    cursorColor: primaryColor,
                    decoration: _inputDecoration(
                        "Special Instructions (Optional)",
                        Icons.note_add_outlined),
                  ),
                  const SizedBox(height: 40),

                  // --- CONFIRM BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "CONFIRM & SUBMIT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
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

  // --- UI HELPER METHODS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildCoordinateItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey.shade50,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}