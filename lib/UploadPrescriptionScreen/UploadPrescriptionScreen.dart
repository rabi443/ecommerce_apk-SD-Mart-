import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../DeliveryDetailsScreen/DeliveryDetailsScreen.dart';
import '../MedicalSuppliesScreen/MedicalSuppliesScreen.dart';
import 'PrescriptionController/PrescriptionController.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({super.key});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  final ImagePicker _picker = ImagePicker();
  final Color primaryColor = const Color(0xFFEB9F3F);
  final Color lightBgColor = const Color(0xFFFEF5E7);

  final PrescriptionController _controller =
  Get.put(PrescriptionController(), permanent: true);

  final TextEditingController _medicineController = TextEditingController();
  final List<XFile> _selectedFiles = [];
  final Map<String, double> _uploadProgress = {};

  @override
  void initState() {
    super.initState();
    _medicineController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _medicineController.removeListener(_handleTextChange);
    _medicineController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final text = _medicineController.text;
    if (text.isEmpty) return;

    final lines = text.split('\n').map((line) {
      final match = RegExp(r'^\d+\. ').firstMatch(line);
      return match != null ? line.substring(match.group(0)!.length) : line;
    }).toList();

    String newText = '';
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      newText += '${i + 1}. ${lines[i]}';
      if (i != lines.length - 1) newText += '\n';
    }

    _medicineController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryColor),
              title: const Text("Take a photo"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(source: ImageSource.camera);
                if (file != null) _addFile(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryColor),
              title: const Text("Choose from gallery"),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) _addFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addFile(XFile file) {
    setState(() {
      _selectedFiles.add(file);
      _uploadProgress[file.path] = 0.0;
    });
  }

  void _goToDeliveryDetails() {
    if (_selectedFiles.isEmpty && _medicineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload prescription or enter medicine names")),
      );
      return;
    }

    Get.to(() => DeliveryDetailsScreen(
      images: _selectedFiles.map((e) => File(e.path)).toList(),
      description: _medicineController.text.trim(),
    ));
  }

  InputDecoration _medicineInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      hintText: "Enter medicine names...",
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MedicalSuppliesScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Upload Prescription",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Upload Your Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: lightBgColor,
                      border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_file, size: 50, color: Color(0xFFEB9F3F)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Text(
                            "Upload Prescription",
                            style: TextStyle(
                              fontSize: 15,
                              color: primaryColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text("Supported formats: JPEG, PNG, PDF", style: TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 80,
                    child: TextField(
                      controller: _medicineController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _medicineInputDecoration("Medicine Names"),
                      keyboardType: TextInputType.multiline,
                      onTap: () {
                        if (_medicineController.text.isEmpty) {
                          _medicineController.text = '1. ';
                          _medicineController.selection = TextSelection.fromPosition(TextPosition(offset: _medicineController.text.length));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedFiles.isNotEmpty) ...[
                    Text("Uploading - ${_selectedFiles.length}/${_selectedFiles.length} files", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Column(
                      children: _selectedFiles.map((file) {
                        final progress = _uploadProgress[file.path] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(file.path), height: 40, width: 40, fit: BoxFit.cover)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(file.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: Colors.grey.shade200, color: primaryColor),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => setState(() { _selectedFiles.remove(file); _uploadProgress.remove(file.path); })),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: ElevatedButton(
              onPressed: _goToDeliveryDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}