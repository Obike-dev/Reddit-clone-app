import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class Pallete {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: drawerColor),
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          surface: drawerColor,
          primary: redColor,
        ), // will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(color: blackColor),
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: whiteColor),
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          surface: whiteColor,
          primary: redColor,
        ),
  );
}

class ThemeState {
  final ThemeData themeData;
  final ThemeMode mode;

  ThemeState({
    required this.themeData,
    required this.mode,
  });
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(
          ThemeState(
            themeData: Pallete.darkModeAppTheme,
            mode: ThemeMode.dark,
          ),
        ) {
    getTheme();
  }

  void getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      state = ThemeState(
        themeData: Pallete.lightModeAppTheme,
        mode: ThemeMode.light,
      );
    } else {
      state = ThemeState(
        themeData: Pallete.darkModeAppTheme,
        mode: ThemeMode.dark,
      );
    }
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (state.mode == ThemeMode.dark) {
      state = ThemeState(
        themeData: Pallete.lightModeAppTheme,
        mode: ThemeMode.light,
      );
      prefs.setString('theme', 'light');
    } else {
      state = ThemeState(
        themeData: Pallete.darkModeAppTheme,
        mode: ThemeMode.dark,
      );
      prefs.setString('theme', 'dark');
    }
  }
}
