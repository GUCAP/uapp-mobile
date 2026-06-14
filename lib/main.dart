import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/app_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));
  runApp(const UAppMobile());
}

class UAppMobile extends StatelessWidget {
  const UAppMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => ValueListenableBuilder<String>(
        valueListenable: languageNotifier,
        builder: (_, __, ___) => MaterialApp(
          title: 'UAPP',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildAppTheme(),
          themeMode: mode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
