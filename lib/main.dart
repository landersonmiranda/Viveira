import 'package:flutter/material.dart';
import 'package:projeto_viviera/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Viveira App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), 
      darkTheme: ThemeData.dark(), 
      themeMode: isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light, 
      home: Home(),
      localizationsDelegates: [
         GlobalMaterialLocalizations.delegate
       ],
       supportedLocales: [
         const Locale('en'),
         const Locale('pt', 'BR')
       ],
    );
  }
}
