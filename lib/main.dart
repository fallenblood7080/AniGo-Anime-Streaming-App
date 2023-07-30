import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'anime_home.dart';
import 'app_colors.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            primaryColor: color_1,
            brightness: Brightness.dark,
            fontFamily: GoogleFonts.raleway().fontFamily,
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(color: color_1),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                    minimumSize:
                        const MaterialStatePropertyAll<Size>(Size(75, 50)),
                    textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(
                        color: color_4,
                        fontFamily: GoogleFonts.raleway().fontFamily)),
                    backgroundColor:
                        const MaterialStatePropertyAll<Color>(color_1),
                    overlayColor: const MaterialStatePropertyAll<Color>(
                        Color.fromARGB(92, 237, 237, 237)),
                    foregroundColor:
                        const MaterialStatePropertyAll<Color>(color_4),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))))),
            filledButtonTheme: FilledButtonThemeData(
                style: ButtonStyle(minimumSize: const MaterialStatePropertyAll<Size>(Size(75, 50)), textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(color: color_4, fontFamily: GoogleFonts.raleway().fontFamily)), backgroundColor: const MaterialStatePropertyAll<Color>(color_1), overlayColor: const MaterialStatePropertyAll<Color>(Color.fromARGB(92, 237, 237, 237)), foregroundColor: const MaterialStatePropertyAll<Color>(color_4), shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))),
        home: const HomeScreen());
  }
}
