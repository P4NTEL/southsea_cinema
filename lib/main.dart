import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/screens/basket_screen.dart';
import 'package:southsea_cinema/screens/menu_screen.dart';
import 'package:southsea_cinema/screens/settings_screen.dart';
import 'package:southsea_cinema/constants.dart';

void main() {
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatefulWidget {
  const SouthseaCinemaApp({super.key});

  @override
  State<SouthseaCinemaApp> createState() {
    return _SouthseaCinemaAppState();
  }
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final bool? savedDarkMode = await prefs.getBool(prefDarkMode);

    if (savedDarkMode == null) {
      return;
    }
    if (savedDarkMode) {
      themeModeNotifier.value = ThemeMode.dark;
    } else {
      themeModeNotifier.value = ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (BuildContext context, ThemeMode mode, Widget? child) {
        return MaterialApp(
          title: appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: cinemaBackgroundLight,
            colorScheme: ColorScheme.fromSeed(
              seedColor: cinemaBrand,
              primary: cinemaBrand,
              surface: cinemaSurfaceLight,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: cinemaSurfaceLight,
              iconTheme: IconThemeData(color: cinemaBrand),
              titleTextStyle: TextStyle(
                color: cinemaBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0,
            ),
            cardTheme: const CardThemeData(color: cinemaSurfaceLight),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: cinemaBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: cinemaBrand,
              primary: cinemaBrand,
              surface: cinemaSurface,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: cinemaSurface,
              iconTheme: IconThemeData(color: cinemaBrand),
              titleTextStyle: cinemaHeaderStyle,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(color: cinemaSurface),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const MenuScreen(),
            '/basket': (context) => const BasketScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
