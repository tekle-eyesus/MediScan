import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    Future.microtask(() =>
        Provider.of<HistoryProvider>(context, listen: false).loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadRecords,
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.records.isEmpty
              ? const Center(child: Text("No records found."))
              : ListView.builder(
                  itemCount: provider.records.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final record = provider.records[index];
                    final isPneumonia = record['prediction'] == "PNEUMONIA";

                    // Format Date
                    final dateStr = record['created_at'];
                    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                    final formattedDate =
                        DateFormat('MMM d, h:mm a').format(date);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isPneumonia ? Colors.red[100] : Colors.green[100],
                          child: Icon(
                            isPneumonia ? Icons.warning : Icons.check,
                            color: isPneumonia ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(
                          "Patient: ${record['patient_id']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            Text("Dr. ${record['doctor_id']} • $formattedDate"),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              record['prediction'],
                              style: TextStyle(
                                color: isPneumonia ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${(record['confidence'] * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Optional: Navigate to a details view to see the Heatmap again
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
