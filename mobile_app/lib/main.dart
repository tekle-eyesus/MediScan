import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medScan_AI/features/diagnosis/diagnosis_provider.dart';
import 'package:medScan_AI/features/diagnosis/diagnosis_screen.dart';
import 'package:medScan_AI/features/history/history_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiagnosisProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediScan AI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0052cc)), // Medical Blue
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const DiagnosisScreen(),
    );
  }
}
