 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';

class HomeLayout extends ConsumerWidget {
  final Widget child;
  final String title;  // Parâmetro para o título

  const HomeLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final backgroundColor = isDarkMode ? Colors.black : Colors.green.shade200;
    final gradientColors = isDarkMode
        ? [Colors.black, Colors.grey.shade800]
        : [Colors.green.shade200, Colors.green.shade700];
    final appBarColor = isDarkMode ? Colors.grey.shade900 : Colors.green.shade700;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Center(
            child: Text(
              title,  // Agora o título é dinâmico
              style: TextStyle(
                fontFamily: 'Courier New',
                color: const Color.fromARGB(255, 240, 146, 58),
                fontSize: 29.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.nightlight : Icons.wb_sunny, color: Colors.white),
              onPressed: () => ref.read(darkModeProvider.notifier).toggleDarkMode(),
            ),
          ],
          backgroundColor: appBarColor,
          elevation: 5,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child, 
      ),
    );
  }
}