import 'dart:convert'; // For decoding the Heatmap
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'diagnosis_provider.dart';

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiagnosisProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MediScan AI",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.clearImage,
              tooltip: "Reset",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGE PREVIEW AREA
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: provider.selectedImage == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Upload X-Ray to Analyze",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        provider.selectedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // 2. INPUT BUTTONS (Camera & Gallery)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. ANALYZE BUTTON
            if (provider.selectedImage != null &&
                provider.diagnosisResult == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : provider.analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("RUN AI DIAGNOSIS",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

            // 4. ERROR MESSAGE
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            // 5. RESULT DISPLAY (The "Wow" Factor)
            if (provider.diagnosisResult != null) _buildResultCard(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(DiagnosisProvider provider) {
    final result = provider.diagnosisResult!;
    final String prediction = result['prediction'];
    final double confidence = result['confidence'];
    final String? heatmapBase64 = result['heatmap_base64'];

    final isPneumonia = prediction == "PNEUMONIA";

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPneumonia
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle,
                  color: isPneumonia ? Colors.red : Colors.green,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  prediction,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPneumonia ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 30),

            // HEATMAP DISPLAY
            if (heatmapBase64 != null) ...[
              const Text(
                "AI Visual Explanation (Heatmap)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(heatmapBase64), // Decode the string from Python
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Red areas indicate where the AI detected abnormalities.",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
