import 'package:flutter/material.dart';
import 'package:dynamic_themes/dynamic_themes.dart';

ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    backgroundColor: Colors.grey[50],
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(secondary: Colors.blueAccent, brightness: Brightness.light),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    dialogBackgroundColor: Colors.grey[50],
    textSelectionTheme: const TextSelectionThemeData(
      selectionHandleColor: Colors.blue,
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(
            fontSize: 24,
            color: Colors.white
        )
    ),
);

Color getDarkBlueColor(double opacity) {
  int darkBlueRedComponent = 25;
  int darkBlueGreenComponent = 74;
  int darkBlueBlueComponent = 142;

  return Color.fromRGBO(darkBlueRedComponent, darkBlueGreenComponent, darkBlueBlueComponent, opacity);
}

Map<int, Color> darkBlueColor = {
  50: getDarkBlueColor(.1),
  100: getDarkBlueColor(.2),
  200: getDarkBlueColor(.3),
  300: getDarkBlueColor(.4),
  400: getDarkBlueColor(.5),
  500: getDarkBlueColor(.6),
  600: getDarkBlueColor(.7),
  700: getDarkBlueColor(.8),
  800: getDarkBlueColor(.9),
  900: getDarkBlueColor(1),
};

ThemeData darkTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF194A8E, darkBlueColor),
    backgroundColor: Colors.grey[900],
    primaryColor: darkBlueColor[900],
    colorScheme:ColorScheme.fromSwatch(primarySwatch: Colors.blue)
        .copyWith(secondary: darkBlueColor[500], brightness: Brightness.dark),
    scaffoldBackgroundColor: Colors.grey[900],
    dialogBackgroundColor: Colors.grey[900],
    textSelectionTheme: TextSelectionThemeData(
      selectionHandleColor: darkBlueColor[900],
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: MaterialColor(0xFF194A8E, darkBlueColor),
      titleTextStyle: const TextStyle(
        fontSize: 24,
        color: Colors.white
      )
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ));

class AppThemes {
  static const int light = 0;
  static const int dark = 1;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.light: lightTheme,
    AppThemes.dark: darkTheme,
  },
  fallbackTheme: ThemeData.light(),
);
