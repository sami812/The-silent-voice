import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/pages/email_verification_page.dart';
import 'package:the_silent_voice/pages/home_page.dart';
import 'package:the_silent_voice/pages/login_or_register.dart';
import 'package:the_silent_voice/services/history_service.dart';
// import 'package:the_silent_voice/pages/video_chat_page.dart';
import 'themes/theme_data.dart';
import 'package:provider/provider.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
//firebase is not supported on linux (-__-)
import 'sign/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// # Main page
/// - contain all the main class `TheSilentVoice`
/// - contain the navigation bar class  'bottomNav'
///
/// - SharedPreferences : saves data on the device's internal storage, so the info stays put even if the user closes the app or restarts their phone. Its allows the application to remember the user's selected theme (Light or Dark mode) even after the app is closed and reopened.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // fire base only initilized if platform is Android or IOS
  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //  WidgetsFlutterBinding.ensureInitialized();
  //  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final switched = prefs.getBool('isDarkMode') ?? true;
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
        ChangeNotifierProvider(create: (_) => TtsService()),
        ChangeNotifierProvider(create: (_) => ConversationHistoryService()),
        ChangeNotifierProxyProvider<ConversationHistoryService, SttService>(
          create: (_) => SttService(),
          update: (_, historyService, sttService) {
            sttService!.setHistoryService(historyService);
            return sttService;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        /// ## App Theme
        /// - by default the app should follow the phone theme
        /// - the value of all the theme is stored at the `themes/themedata.dart`
        /// - we should add a way to over ride this theme in the profile page => done
        theme: AppThemeData.light, // Light theme
        darkTheme: AppThemeData.dark, // Dark theme
        themeMode: _themeMode, // follow switch value in the  profile page
        home:
            // VideoChatPage(),
            (Platform.isAndroid || Platform.isIOS)
            ? StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    final isGoogleUser = user.providerData.any(
                      (info) => info.providerId == 'google.com',
                    );
                    if (!isGoogleUser && !user.emailVerified) {
                      return EmailVerificationPage();
                    }
                    return const HomePage();
                  }
                  return const LoginOrRegister();
                },
              )
            : const HomePage(),
      ),
    );
  }
}
