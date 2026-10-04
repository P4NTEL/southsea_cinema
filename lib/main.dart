import 'package:flutter/material.dart';
import 'package:southsea_cinema/screens/menu_screen.dart';
import 'package:southsea_cinema/constants.dart';

void main() {
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatelessWidget {
  const SouthseaCinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: cinemaBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          primary: cinemaBrand,
          surface: cinemaSurface,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
      },
    );
  }
}
