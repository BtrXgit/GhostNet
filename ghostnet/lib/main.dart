import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ciphercloak/screens/homescreen.dart';

import 'helpers/prefs.dart';

late Size mediaQuery;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Pref.initializeHive();
  mediaQuery = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CipherCloak',
      home: GhostHome(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(centerTitle: true, elevation: 3),
      ),
      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(centerTitle: true, elevation: 3),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get backgroundColour => Pref.isDarkMode
      ? Color.fromARGB(255, 28, 28, 48)
      : Color.fromARGB(255, 194, 200, 222);
  Color get primaryColour =>
      Pref.isDarkMode ? Color(0xFFDCE2FA) : Color(0xff131321);
  Color get lightText =>
      Pref.isDarkMode ? Color(0xFFDCE2FA) : Color(0xff131321);
  Color get bottomNav =>
      Pref.isDarkMode ? Color(0xff23203f) : Color(0xff23203f);
}
