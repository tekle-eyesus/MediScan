class ApiConstants {
  // need to update base url when ngrok restarts
  static const String baseUrl =
      "https://nonmythological-nonemulously-charlette.ngrok-free.dev";

  // Endpoints
  static const String analyzeEndpoint = "$baseUrl/api/v1/analyze";
  static const String historyEndpoint = "$baseUrl/api/v1/history";
  static const String recentRecordsEndpoint = "$baseUrl/api/v1/records/recent";
}
