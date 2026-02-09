import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medScan_AI/features/settings/settings_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/full_screen_image.dart';
import '../diagnosis/widgets/confidence_chart.dart';
import 'package:pdf/widgets.dart' as pw;

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const HistoryDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final String prediction = record['prediction'];
    final double confidence = record['confidence'];
    final String? heatmapBase64 = record['heatmap_base64'];
    final String patientId = record['patient_id'];
    final String doctorId = record['doctor_id'];
    final String dateStr = record['created_at'];

    final bool isPneumonia = prediction == "PNEUMONIA";
    final DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final String formattedDate =
        DateFormat('MMMM d, yyyy • h:mm a').format(date);

    Future<void> _generatePdf(BuildContext context) async {
      final pdf = pw.Document();

      // 1. Get Data from the Record
      final String patientId = record['patient_id'];
      final String prediction = record['prediction'];
      final double confidence = record['confidence'];
      final String dateStr = record['created_at'];
      final String? heatmapBase64 = record['heatmap_base64'];

      // 2. Get Data from Settings (Hospital Name, Current Doctor printing it)
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      // 3. Prepare Image (Decode Base64)
      pw.MemoryImage? pdfImage;
      if (heatmapBase64 != null) {
        final Uint8List bytes = base64Decode(heatmapBase64);
        pdfImage = pw.MemoryImage(bytes);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("MediScan Medical Report",
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          "Generated: ${DateTime.now().toString().split(' ')[0]}"),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // PATIENT & DOCTOR INFO BOX
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Patient ID: $patientId",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Scan Date: $dateStr"),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Doctor: ${record['doctor_id']}"),
                          pw.Text("Facility: ${settings.hospitalName}"),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // MAIN IMAGE (HEATMAP)
                if (pdfImage != null)
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text("AI Visual Analysis (Heatmap)",
                            style: const pw.TextStyle(fontSize: 14)),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          height: 300,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey),
                          ),
                          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                        ),
                      ],
                    ),
                  )
                else
                  pw.Center(child: pw.Text("No Image Data Available")),

                pw.SizedBox(height: 20),

                // DIAGNOSIS RESULTS
                pw.Text("Findings:",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey100,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text("Prediction: "),
                          pw.Text(prediction,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: prediction == "PNEUMONIA"
                                      ? PdfColors.red
                                      : PdfColors.green)),
                        ],
                      ),
                      pw.Text(
                          "AI Confidence: ${(confidence * 100).toStringAsFixed(1)}%"),
                    ],
                  ),
                ),

                pw.Spacer(),

                // FOOTER
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("MediScan Ethiopia - AI Assist",
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey)),
                    pw.Text("Consult a specialist for final diagnosis.",
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Open Print/Share Dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'MediScan_Report_$patientId', //file name
      );
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Scan Details"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF438EA5), Color(0xFF4DA49C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Print Report",
            onPressed: () {
              _generatePdf(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // HEADER INFO (Date & ID)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient ID",
                          style: TextStyle(
                              color: Colors.blue.shade900, fontSize: 12)),
                      Text(patientId,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Scan Date",
                          style: TextStyle(
                              color: Colors.blue.shade900, fontSize: 12)),
                      Text(formattedDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // HEATMAP IMAGE (Clickable)
            if (heatmapBase64 != null)
              GestureDetector(
                onTap: () {
                  // Reuse our FullScreenImage widget
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                                base64Image:
                                    heatmapBase64, // Pass base64 instead of file
                                tag: "history_hero_${record['id']}",
                              )));
                },
                child: Hero(
                  tag: "history_hero_${record['id']}",
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5))
                      ],
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(heatmapBase64)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      child:
                          const Icon(Icons.zoom_out_map, color: Colors.white),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Text("No Image Saved"),
              ),

            const SizedBox(height: 20),

            // DIAGNOSIS CARD (Reusing logic)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Diagnosis Result",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
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
                            isPneumonia
                                ? "Abnormality Detected"
                                : "Healthy Lungs",
                            style: TextStyle(
                              color: isPneumonia ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reuse the Chart Widget
                  ConfidenceChart(
                      confidence: confidence, isPneumonia: isPneumonia),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DOCTOR INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5))
                ],
              ),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Diagnosed by: Dr. $doctorId"),
                subtitle: const Text("Recorded in local database"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
