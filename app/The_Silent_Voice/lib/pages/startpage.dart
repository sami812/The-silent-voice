import 'package:flutter/material.dart';
import 'conversationpage.dart';

/// # Start Page
/// `StartPage` is the main landing page of the app. It shows the app logo, title, description,
/// main features, and a button to start a conversation.
/// - Features include "Text", "Speech", and "Guided" communication methods.
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ### Body
      /// Main content of the Start Page
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// #### App Logo Container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/chat.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),
            /// #### App Title
            Text(
              'The silent voice',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            /// #### App Description
            Text(
              'Bridge communication gaps with text,\n'
              'speech, and guided conversations',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 80),
            /// #### Start Conversation Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(colors: [const Color.fromARGB(255, 16, 103, 252),const Color.fromARGB(255, 20, 173, 244)],begin: Alignment.topRight,end: Alignment.bottomLeft),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero,elevation: 0,backgroundColor: Colors.transparent,minimumSize: Size(300,70),),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Conversationpage(),),);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/chat.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                      
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Start Conversation',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                )
              ),
            ),

            const SizedBox(height: 40),
            /// #### Subtext
            Text('Begin a communication session',textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 80),
            /// #### Features Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// ##### Text Feature
                Column(
                  children: [

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/note.png',
                          width: 40,
                          height: 40,
                        ),
                      ),  
                    ),

                    Text('Text',style: Theme.of(context).textTheme.bodySmall,),

                  ],
                ),
                /// ##### Speech Feature
                Column(
                  children: [

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/microphone.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),

                    Text('Speech',style: Theme.of(context).textTheme.bodySmall,),
                  ],
                ),
                /// ##### Guided Feature
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/speech.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    
                    Text('Guided',style: Theme.of(context).textTheme.bodySmall,),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
