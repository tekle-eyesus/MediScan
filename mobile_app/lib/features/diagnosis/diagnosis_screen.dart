import 'dart:convert'; // For decoding the Heatmap
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medScan_AI/core/widgets/full_screen_image.dart';
import 'package:medScan_AI/features/diagnosis/widgets/confidence_chart.dart';
import 'package:provider/provider.dart';
import 'diagnosis_provider.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _showHeatmap = true;
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

  // Widget _buildResultCard(DiagnosisProvider provider) {
  Widget _buildResultCard(DiagnosisProvider provider) {
    final result = provider.diagnosisResult!;
    final String prediction = result['prediction'];
    final double confidence = result['confidence'];
    final String? heatmapBase64 = result['heatmap_base64'];
    final isPneumonia = prediction == "PNEUMONIA";

    return Column(
      children: [
        // 1. IMAGE OVERLAY SECTION
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // The Image Container
            GestureDetector(
              onTap: () {
                // Open Full Screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FullScreenImage(
                              imageFile: provider.selectedImage,
                              tag: "diagnosis_image",
                            )));
              },
              child: Hero(
                tag: "diagnosis_image",
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black,
                    image: DecorationImage(
                      image: FileImage(provider.selectedImage!),
                      fit: BoxFit.cover, // Ensure it fills the box
                    ),
                  ),
                  child: (_showHeatmap && heatmapBase64 != null)
                      ? Opacity(
                          opacity: 0.6, // Semi-transparent overlay
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              base64Decode(heatmapBase64),
                              fit: BoxFit.cover, // MUST match the parent fit
                              gaplessPlayback: true,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Toggle Switch
            if (heatmapBase64 != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Heatmap",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _showHeatmap,
                        activeColor: Colors.blueAccent,
                        onChanged: (val) {
                          setState(() {
                            _showHeatmap = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. DIAGNOSIS INFO CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              // Left: Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Diagnosis Result",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      prediction,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isPneumonia ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPneumonia
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPneumonia ? "Abnormality Detected" : "Healthy Lungs",
                        style: TextStyle(
                          color: isPneumonia ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Chart
              ConfidenceChart(confidence: confidence, isPneumonia: isPneumonia),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. GENERATE REPORT BUTTON
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text("GENERATE MEDICAL REPORT"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {},
            // onPressed: () => _generatePdfReport(provider),
          ),
        ),
      ],
    );
  }
}
