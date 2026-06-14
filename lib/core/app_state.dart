import 'package:flutter/material.dart';

/// Global theme notifier — dark (true) or light (false)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

/// Global current user id notifier (account switcher)
final ValueNotifier<String> currentUserIdNotifier = ValueNotifier('u-shamim');

bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

void toggleTheme() {
  themeNotifier.value =
      themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

/// Global language notifier
final ValueNotifier<String> languageNotifier = ValueNotifier('en');

void setLanguage(String code) {
  languageNotifier.value = code;
}

const List<Map<String, String>> kLanguages = [
  {'code': 'en', 'label': 'English',  'native': 'English'},
  {'code': 'fr', 'label': 'French',   'native': 'Français'},
  {'code': 'bn', 'label': 'Bengali',  'native': 'বাংলা'},
  {'code': 'ar', 'label': 'Arabic',   'native': 'العربية'},
];
