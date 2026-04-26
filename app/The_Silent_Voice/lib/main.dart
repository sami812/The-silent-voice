import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/pages/home_page.dart';
import 'package:the_silent_voice/pages/login_or_register.dart';
//import 'package:the_silent_voice/pages/home_page.dart';
//import 'package:the_silent_voice/pages/login_page.dart';
//import 'package:the_silent_voice/pages/sign_up_page.dart';
//import 'package:the_silent_voice/pages/sign_up_page.dart';
import 'themes/theme_data.dart';
import 'package:provider/provider.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
//firebase is not supported on linux (-__-)
import 'sign/firebase_options.dart';

/// # Main page
/// - contain all the main class `TheSilentVoice`
/// - contain the navigation bar class  'bottomNav'
/// - SharedPreferences : saves data on the device's internal storage, so the info stays put even if the user closes the app or restarts their phone. Its allows the application to remember the user's selected theme (Light or Dark mode) even after the app is closed and reopened.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // fire base only initilized if platform is Android or IOS
  if (Platform.isAndroid || Platform.isIOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //  WidgetsFlutterBinding.ensureInitialized();
  //  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAuth.instance.signOut();
  final prefs = await SharedPreferences.getInstance();
  final switched = prefs.getBool('isDarkMode') ?? false;
  runApp(TheSilentVoice(switched: switched));
}

class TheSilentVoice extends StatefulWidget {
  final bool switched;
  const TheSilentVoice({super.key, required this.switched});
  // ignore: library_private_types_in_public_api
  static _TheSilentVoiceState of(BuildContext context) =>
      context.findAncestorStateOfType<_TheSilentVoiceState>()!;
  @override
  State<TheSilentVoice> createState() => _TheSilentVoiceState();
}

/// ## theme switch
class _TheSilentVoiceState extends State<TheSilentVoice> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.switched ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SttService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        /// ## App Theme
        /// - by defualt the app should follow the phone theme
        /// - the value of all the theme is stored at the `themes/themedata.dart`
        /// - we should add a way to over ride this theme in the profile page => done
        theme: AppThemeData.light, // Light theme
        darkTheme: AppThemeData.dark, // Dark theme
        themeMode: _themeMode, // follow switch value in the  profile page
        home: (Platform.isAndroid || Platform.isIOS)
            ? StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const HomePage();
                  }
                  return const LoginOrRegister();
                },
              )
            : const HomePage(),
        //        home: StreamBuilder(
        //          stream: FirebaseAuth.instance.authStateChanges(),
        //          builder: (context, snapshot) {
        //            if (snapshot.hasData) {
        // final user = FirebaseAuth.instance.currentUser;
        // if (user != null && user.emailVerified) {
        //   return const HomePage();
        // }
        //              return const HomePage();
        //            }
        //            return const LoginOrRegister();
        //          },
        //        ),
      ),
    );
  }
}
