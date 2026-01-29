import 'package:flutter/material.dart';
import 'startpage.dart';
import 'profilepage.dart';
import 'historypage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'OpenSans'),
      home: BottomNav(),
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectPage = 0;
  List<Widget> pages = [StartPage(),Historypage(),Profilepage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectPage],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade200, 
            width: 1.5, 
          ),
        ),
        child: BottomNavigationBar(
          onTap: (val) {
            setState(() {
              selectPage = val;
            });
          },
          backgroundColor: Colors.white,
          currentIndex: selectPage,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w300,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 30),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon:Image.asset('icons/history.png',width: 25,height: 25,color: Colors.grey,),
              activeIcon:Image.asset('icons/history.png',width: 25,height: 25,color: Colors.blue,),
              label: "History",
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
