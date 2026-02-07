import 'package:flutter/material.dart';
import 'themes/themedata.dart';
import 'pages/startpage.dart';
import 'pages/profilepage.dart';
import 'pages/historypage.dart';

// note to other contributer
// the "///" well get add automaticly to the documentation
// while "//" is only ment for other developer
// note: feel free to change any doc
// note: the documentation use markdown (.md) syntax
// note: to change the name try this command
// '$ flutter pub rename'

/// # Main page
/// - contain all the main class `TheSilentVoice`
/// - contain the navigation bar class  'bottomNav'

void main() {
  runApp(const TheSilentVoice());
}

class TheSilentVoice extends StatefulWidget {
  const TheSilentVoice({super.key});
  static _TheSilentVoiceState of(BuildContext context) =>
      context.findAncestorStateOfType<_TheSilentVoiceState>()!;
  @override
  State<TheSilentVoice> createState() => _TheSilentVoiceState();
}

class _TheSilentVoiceState extends State<TheSilentVoice> {
  ThemeMode _themeMode = ThemeMode.light;
  toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /// ## App Theme
      /// - by defualt the app should follow the phone theme
      /// - the value of all the theme is stored at the `themes/themedata.dart`
      /// - we should add a way to over ride this theme in the profile page => done
      theme: AppThemeData.light, // Light theme
      darkTheme: AppThemeData.dark, // Dark theme
      themeMode: _themeMode, // follow switch value in the  profile page
      home: BottomNav(),
    );
  }
}

/// ## navigation bar class
///
/// - the implemntation for navigation bar
/// - provide us with a way to move between 3 diffrent pages
/// - `History Page`, `Start Page`, `Profile Page`

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

/// ### bottom navigation
///
/// - we use the variable `selectPage` to move between the page in the navigation bar
///
/// - `History Page` : set to `0`
/// - `Start Page`   : set to `1` (the defualt valus)
/// - `Profile Page` : set to '2'

class _BottomNavState extends State<BottomNav> {
  int selectPage = 1;
  List<Widget> pages = [Historypage(),StartPage(),Profilepage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectPage],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5)),
        ),
        child: BottomNavigationBar(
          onTap: (val) {
            setState(() {
              selectPage = val;
            });
          },
          currentIndex: selectPage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
          items: [
            BottomNavigationBarItem(
              icon:  Icon(Icons.history_rounded, size: 30),
              // icon: Image.asset(
              //   'assets/icons/history.png',
              //   width: 25,
              //   height: 25,
              //   color: Colors.grey,
              // ),
              // activeIcon: Image.asset(
              //   'assets/icons/history.png',
              //   width: 25,
              //   height: 25,
              //   color: Colors.blue,
              // ),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 30),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, size: 30),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
