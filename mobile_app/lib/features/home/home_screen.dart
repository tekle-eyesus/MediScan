import 'package:flutter/material.dart';
import 'package:medScan_AI/features/settings/settings_screen.dart';
import 'package:medScan_AI/language_classes/language_constants.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiagnosisScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFF438EA5).withOpacity(0.3),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: translation(context).scan,
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: translation(context).history,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: translation(context).settings,
          ),
        ],
      ),
    );
  }
}
