import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_silent_voice/pages/history_page.dart';
import 'package:the_silent_voice/pages/profile_page.dart';
import 'package:the_silent_voice/pages/start_page.dart';
import 'package:the_silent_voice/services/history_service.dart';
import 'package:the_silent_voice/sign/user_cache.dart';

/// ## navigation bar class
///
/// - the implementation for navigation bar
/// - provide us with a way to move between 3 different pages
/// - `History Page`, `Start Page`, `Profile Page`

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

/// ### bottom navigation
///
/// - we use the variable `selectPage` to move between the page in the navigation bar
///
/// - `History Page` : set to `0`
/// - `Start Page`   : set to `1` (the default values)
/// - `Profile Page` : set to '2'

class _HomePageState extends State<HomePage> {
  int selectPage = 1;

  Future<void> getData() async {
    if (userCache != null) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) {
      setState(() {
        userCache = doc.data();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    // Load the history when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationHistoryService>().loadSessions();
    });
  }

  // List<Widget> pages = [HistoryPage(), StartPage(), ProfilePage()];
  Widget pages() {
    switch (selectPage) {
      case 0:
        return HistoryPage();
      case 1:
        return StartPage();
      case 2:
        return ProfilePage();
      default:
        return StartPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // pages[selectPage],
          pages(),
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
          currentIndex: selectPage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded, size: 30),
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
