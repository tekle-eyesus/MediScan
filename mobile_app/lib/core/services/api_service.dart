import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> uploadXray({
    required File imageFile,
    required String patientId,
    required String doctorId,
  }) async {
    try {
      // 1. Prepare the Form Data
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        "patient_id": patientId,
        "doctor_id": doctorId,
      });

      // 2. Send POST Request
      Response response = await _dio.post(
        ApiConstants.analyzeEndpoint,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            // Sometimes ngrok requires a specific header to bypass warning page
            "ngrok-skip-browser-warning": "true",
          },
          receiveTimeout: const Duration(seconds: 60), // AI might take time
        ),
      );

      // 3. Return Data
      return response.data;
    } catch (e) {
      print("Error uploading image: $e");
      if (e is DioException) {
        if (e.response != null) {
          throw Exception(
              "Server Error: ${e.response?.statusCode} - ${e.response?.data}");
        } else {
          throw Exception("Connection Error: Check Ngrok or Internet");
        }
      }
      throw Exception("Unknown Error: $e");
    }
  }
}
