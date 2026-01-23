import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _doctorName = "Dr. Unknown";
  String _hospitalName = "General Hospital";
  String _doctorId = "DOC-001";
  String _language = "English";
  bool _isDarkMode = false;

  String get doctorName => _doctorName;
  String get hospitalName => _hospitalName;
  String get doctorId => _doctorId;
  String get language => _language;
  bool get isDarkMode => _isDarkMode;

  // Constructor (Load data immediately)
  SettingsProvider() {
    _loadPreferences();
  }

  //  Load from Storage
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _doctorName = prefs.getString('doctorName') ?? "Dr. Unknown";
    _hospitalName = prefs.getString('hospitalName') ?? "General Hospital";
    _doctorId = prefs.getString('doctorId') ?? "DOC-001";
    _language = prefs.getString('language') ?? "English";
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  //  Setters (Save to Storage)
  Future<void> setDoctorName(String name) async {
    _doctorName = name;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('doctorName', name);
    notifyListeners();
  }

  Future<void> setHospitalName(String name) async {
    _hospitalName = name;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('hospitalName', name);
    notifyListeners();
  }

  Future<void> setDoctorId(String id) async {
    _doctorId = id;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('doctorId', id);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isOn);
    notifyListeners();
  }
}
