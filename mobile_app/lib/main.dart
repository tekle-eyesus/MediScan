import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medScan_AI/features/diagnosis/diagnosis_provider.dart';
import 'package:medScan_AI/features/history/history_provider.dart';
import 'package:medScan_AI/features/home/home_screen.dart';
import 'package:medScan_AI/features/settings/settings_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:medScan_AI/language_classes/language_constants.dart';

void main() {
  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => DiagnosisProvider()),
        provider.ChangeNotifierProvider(create: (_) => HistoryProvider()),
        provider.ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends ConsumerState<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedScan AI',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
