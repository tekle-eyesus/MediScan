import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ConfidenceChart extends StatelessWidget {
  final double confidence; // 0.0 to 1.0
  final bool isPneumonia;

  const ConfidenceChart(
      {super.key, required this.confidence, required this.isPneumonia});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    final color = isPneumonia ? Colors.red : Colors.green;

    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: confidence * 100,
                  color: color,
                  radius: 25,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: (1 - confidence) * 100,
                  color: Colors.grey.shade200,
                  radius: 20,
                  showTitle: false,
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 0,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$percentage%",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const Text("Confidence",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
