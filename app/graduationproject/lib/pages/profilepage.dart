import 'package:flutter/material.dart';
import 'package:graduationproject/main.dart';
class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  @override
  Widget build(BuildContext context) {
    final switched = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text('Profile'),
      //   backgroundColor: Colors.white,
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(2),
      //     child: Container(color: Colors.grey.shade400, height: 1),
      //   ),
      // ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Scrolling AppBar 
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
            ),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Profile",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 15,)
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
            ),
            child: 
            Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue[800],
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                // profile data
                Text('data'),
                const SizedBox(height: 10,),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          // Appearance card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: Row(
                    children: [
                      Icon(switched? Icons.dark_mode_outlined : Icons.light_mode_outlined,color: Colors.blue,),
                      const SizedBox(width: 8),       
                      Expanded(
                        child: Text(
                          switched?'Dark Mode':'Light Mode',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      Switch(
                        value: switched,
                        onChanged: (value) {
                          TheSilentVoice.of(context).toggleTheme(value);
                        },
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[400],
                        activeTrackColor: Colors.blue,
                        activeThumbColor:  Colors.white,
                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Preferences card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_none),
                      const SizedBox(width: 8),       
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.grey[400],),),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                  child: Row(
                    children: [
                      Icon(Icons.language_outlined),
                      const SizedBox(width: 8),       
                      Expanded(
                        child: Text(
                          'Language',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.grey[400],),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Privacy & Security card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'Privacy & Security',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined),
                      const SizedBox(width: 8),       
                      Expanded(
                        child: Text(
                          'Privacy Security',
                          style:  Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.grey[400],),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // About card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 0, 4),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 15),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded),
                      const SizedBox(width: 8),       
                      Expanded(
                        child: Text(
                          'App Information',
                          style:  Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios,color: Colors.grey[400],),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
