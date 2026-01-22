import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _apiService.fetchRecentRecords();
    } catch (e) {
      _errorMessage = e.toString();
      _records = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(int id) async {
    final index = _records.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    final removed = _records.removeAt(index);
    notifyListeners();

    try {
      await _apiService.deleteRecord(id);
    } catch (e) {
      // Roll back if the API call fails
      _records.insert(index, removed);
      _errorMessage = "Failed to delete: $e";
      notifyListeners();
    }
  }
}
