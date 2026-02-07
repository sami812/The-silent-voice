import 'package:flutter/material.dart';
import 'page/startpage.dart';
import 'page/profilepage.dart';
import 'page/historypage.dart';
import 'themes/theme.dart';

// note to other contributer
// the "///" well get add automaticly to the documentation
// while "//" is only ment for other developer
// note: feel free to change any doc
// note: the documentation use markdown (.md) syntax
// note: to change the name try this command
// '$ flutter pub rename'

/// # Main page
/// - contain all the main class `MyAPP`
/// - contain the navigation bar class  'bottomNav'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// ## App Theme
      /// - by defualt the app should follow the phone theme
      /// - the value of all the theme is stored at the `themes/theme.dart`
      /// - we should add a way to over ride this theme in the profile page
      theme: lightMode,
      darkTheme: darkMode,
      // uncommet one of them at a time
      //themeMode: ThemeMode.system, // follow system theme
      //themeMode: ThemeMode.light, // just for testing for now
      themeMode: ThemeMode.dark, // just for testing for now
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
  List<Widget> pages = [Historypage(), StartPage(), Profilepage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectPage],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (val) {
            setState(() {
              selectPage = val;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: selectPage,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w300,
            fontFamily: 'OpenSans',
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded, size: 30),
              label: "History",
              // while the other icon is closer to the prototype
              // i think that it's not worth cluttering the code base
              // i don't have strong opinion about it so feel free to change it back
              //              icon: Image.asset(
              //                'icons/history.png',
              //                width: 25,
              //                height: 25,
              //                color: Theme.of(context).colorScheme.onSurfaceVariant,
              //              ),
              //              activeIcon: Image.asset(
              //                'icons/history.png',
              //                width: 25,
              //                height: 25,
              //                color: Theme.of(context).colorScheme.primary,
              //              ),
              //              label: "History",
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
