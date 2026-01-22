import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF4CAF50), // Green
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFF44336), // Red
      icon: Icons.error_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFFF9800), // Orange
      icon: Icons.warning_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF2196F3), // Blue
      icon: Icons.info_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      duration: const Duration(seconds: 3),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // Custom method for specific app scenarios
  static void showScanResult(
      BuildContext context, String disease, double confidence) {
    final isHealthy = disease.toLowerCase().contains('healthy');

    _showSnackBar(
      context,
      isHealthy
          ? '✅ Plant is healthy! (${(confidence * 100).toStringAsFixed(1)}% confidence)'
          : '⚠️ Detected: $disease (${(confidence * 100).toStringAsFixed(1)}% confidence)',
      backgroundColor:
          isHealthy ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
      icon: isHealthy ? Icons.eco_rounded : Icons.health_and_safety_rounded,
    );
  }

  static void showNetworkError(BuildContext context) {
    _showSnackBar(
      context,
      '📡 Please check your internet connection',
      backgroundColor: const Color(0xFFF44336),
      icon: Icons.wifi_off_rounded,
    );
  }

  static void showProcessing(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Analyzing plant image...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF2196F3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      duration: const Duration(seconds: 2),
      elevation: 6,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
