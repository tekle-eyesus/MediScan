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
}
