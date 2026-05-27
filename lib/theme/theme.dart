import 'package:flutter/material.dart';

const primaryColor = Color(0xFFFFA18C);

final lightTheme = ThemeData(
  colorScheme: .fromSeed(seedColor: primaryColor, brightness: Brightness.light),
  useMaterial3: true,
);

final darkTheme = ThemeData(
  colorScheme: .fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
  useMaterial3: true,
);
