import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto_viviera/providers/dark_mode_notifier.dart';
import 'package:projeto_viviera/screens/estudantes/listar.dart';
import 'package:projeto_viviera/screens/turmas/listar.dart';


class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final backgroundColor = isDarkMode ? Colors.black : Colors.green.shade200;
    final gradientColors = isDarkMode
        ? [Colors.black, Colors.grey.shade800]
        : [Colors.green.shade200, Colors.green.shade700];
    final appBarColor = isDarkMode ? Colors.grey.shade900 : Colors.green.shade700;
    final buttonTextColor = Colors.white;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          title: Center(
            child: Text(
              "Viveira",
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    context, 
                    "Estudantes", 
                    Icons.school, 
                    isDarkMode ? Colors.blueGrey : Colors.blue.shade400, 
                    buttonTextColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListarEstudantePage()),
                    ),
                  ),
                  SizedBox(width: 20),
                  _buildMenuButton(
                    context, 
                    "Turmas", 
                    Icons.group, 
                    isDarkMode ? Colors.orange.shade700 : Colors.orange.shade400, 
                    buttonTextColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListarTurmaPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, Color color, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(160, 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: color,
        elevation: 5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: textColor),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(fontFamily: 'Courier New', fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}
