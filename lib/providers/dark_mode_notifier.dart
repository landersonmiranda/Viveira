import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final darkModeFutureProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('darkMode') ?? false;
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier(bool initialState) : super(initialState);

  Future<void> toggleDarkMode() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', state);
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final initialState = ref.watch(darkModeFutureProvider).maybeWhen(
        data: (value) => value,
        orElse: () => false,
      );
  return DarkModeNotifier(initialState);
});
