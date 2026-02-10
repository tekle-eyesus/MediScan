import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiagnosisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _diagnosisResult;
  String? _errorMessage;
  String _doctorName = "Dr. Unknown";

  // Getters
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get diagnosisResult => _diagnosisResult;
  String? get errorMessage => _errorMessage;

  // 1. Pick Image (Handles both Camera and Gallery)
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Compress slightly for faster upload
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _diagnosisResult = null; // Reset previous result
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to pick image: $e";
      notifyListeners();
    }
  }

  // 2. Clear Image (Reset)
  void clearImage() {
    _selectedImage = null;
    _diagnosisResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  //  Load from Storage
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _doctorName = prefs.getString('doctorName') ?? "Dr. Unknown";
    notifyListeners();
  }

  // 3. Analyze Image (Call Backend)
  Future<void> analyzeImage() async {
    if (_selectedImage == null) return;
    await _loadPreferences(); // Ensure we have the latest doctor name
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // image check before upload if it is the snan image ( negative case) or not (positive case)

      final result = await _apiService.uploadXray(
        imageFile: _selectedImage!,
        patientId:
            "ETH-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}",
        doctorId: "DR-${_doctorName.replaceAll(' ', '').toUpperCase()}",
      );

      _diagnosisResult = result;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
