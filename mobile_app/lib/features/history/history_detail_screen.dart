import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/full_screen_image.dart';
import '../diagnosis/widgets/confidence_chart.dart';

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
            onPressed: () {
              // print pdf like in the home screen
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
