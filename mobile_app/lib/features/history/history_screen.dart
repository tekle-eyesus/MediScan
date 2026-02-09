import 'package:flutter/material.dart';
import 'package:medScan_AI/core/snackbar/custom_snackbar.dart';
import 'package:medScan_AI/features/history/history_detail_screen.dart';
import 'package:medScan_AI/language_classes/language_constants.dart';
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
    _loadRecords();
  }

  void _loadRecords() {
    // Load data when screen opens
    Future.microtask(() =>
        Provider.of<HistoryProvider>(context, listen: false).loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).historyTitle),
        foregroundColor: Colors.white,
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
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadRecords,
          )
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        translation(context).noRecordsFound,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
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

                    return Dismissible(
                      key: Key(record['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Call the delete function
                        Provider.of<HistoryProvider>(context, listen: false)
                            .deleteRecord(record['id']);

                        CustomSnackBar.showInfo(
                          context,
                          translation(context).recordDeleted,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPneumonia
                                ? Colors.red[100]
                                : Colors.green[100],
                            child: Icon(
                              isPneumonia ? Icons.warning : Icons.check,
                              color: isPneumonia ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            "${translation(context).patientPrefix}${record['patient_id']}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "${translation(context).doctorPrefix}${record['doctor_id']} • $formattedDate"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                record['prediction'],
                                style: TextStyle(
                                  color:
                                      isPneumonia ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${translation(context).confidencePrefix}${(record['confidence'] * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoryDetailScreen(record: record),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
