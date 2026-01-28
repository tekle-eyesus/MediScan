import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medScan_AI/core/snackbar/custom_snackbar.dart';
import 'package:medScan_AI/language_classes/language.dart';
import 'package:medScan_AI/language_classes/language_constants.dart';
import 'package:medScan_AI/main.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    Locale locale = await getLocale();
    setState(() {
      _selectedLanguage = Language.languageList()
          .firstWhere((lang) => lang.languageCode == locale.languageCode)
          .name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).welcome,
          style: GoogleFonts.poppins(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF438EA5), Color(0xFF4DA49C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // SECTION 1: DOCTOR PROFILE
          _buildSectionHeader("Doctor Profile"),
          _buildListTile(
            context,
            icon: Icons.person,
            title: "Doctor Name",
            subtitle: settings.doctorName,
            onTap: () => _showEditDialog(context, "Doctor Name",
                settings.doctorName, (val) => settings.setDoctorName(val)),
          ),
          _buildListTile(
            context,
            icon: Icons.badge,
            title: "Doctor ID",
            subtitle: settings.doctorId,
            onTap: () => _showEditDialog(context, "Doctor ID",
                settings.doctorId, (val) => settings.setDoctorId(val)),
          ),
          _buildListTile(
            context,
            icon: Icons.local_hospital,
            title: "Hospital / Clinic",
            subtitle: settings.hospitalName,
            onTap: () => _showEditDialog(context, "Hospital Name",
                settings.hospitalName, (val) => settings.setHospitalName(val)),
          ),
          const Divider(),

          // SECTION 2: APP PREFERENCES
          _buildSectionHeader("App Preferences"),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: const Text("Language"),
            subtitle: Text(settings.language),
            trailing: DropdownButton<String>(
              value: settings.language,
              underline: Container(), // Hide underline
              items: Language.languageList()
                  .map(
                    (language) => DropdownMenuItem<String>(
                      value: language.name,
                      child: Text(language.name),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) async {
                Locale _locale = await setLocale(
                  newValue == "English" ? "en" : "am",
                );

                MyApp.setLocale(context, _locale);

                CustomSnackBar.showSuccess(
                  context,
                  "$newValue ${"language changed successfully"}",
                );
              },
            ),
          ),
          /* 
          // FUTURE: Theme Switcher
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.purple),
            title: const Text("Dark Mode"),
            value: settings.isDarkMode,
            onChanged: (val) => settings.toggleTheme(val),
          ),
          */

          const Divider(),

          // SECTION 3: ABOUT
          _buildSectionHeader("About"),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text("Version"),
            subtitle: Text("1.0.0 (Beta)"),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.grey),
            title: Text("Privacy Policy"),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Section Headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Helper Widget for List Tiles
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
      trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Helper Dialog for Editing Text
  void _showEditDialog(BuildContext context, String title, String currentValue,
      Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
