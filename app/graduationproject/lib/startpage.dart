import 'package:flutter/material.dart';
import 'conversationpage.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    offset: Offset(5,5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.blue.shade200,
                    offset: Offset(-5,-5),
                    blurRadius: 20,
                  )
                ]
              ),
              child: Center(
                child: Image.asset(
                  'icons/chat.png',
                  width: 40,
                  height: 40,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 30),

            Text(
              'The silent voice',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            Text(
              'Bridge communication gaps with text,\n'
              'speech, and guided conversations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 79, 75, 75),
              ),
            ),

            SizedBox(height: 80),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(colors: [const Color.fromARGB(255, 16, 103, 252),const Color.fromARGB(255, 20, 173, 244)],begin: Alignment.topRight,end: Alignment.bottomLeft),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    offset: Offset(2,2),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.blue.shade200,
                    offset: Offset(-2,-2),
                    blurRadius: 20,
                  )
                ],
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
                      'icons/chat.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                      
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Start Conversation',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                )
              ),
            ),

            // SizedBox(height: 10),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.white,minimumSize: Size(250,40),),
            //   onPressed: () {},
            //   child: Text(
            //     'Sign Up',
            //     style: TextStyle(fontSize: 18, color: Colors.blue),
            //   ),
            // ),

            SizedBox(height: 40),

            Text('Begin a communication session',textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 79, 75, 75),
              ),
            ),

            SizedBox(height: 80),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'icons/note.png',
                          width: 40,
                          height: 40,
                        ),
                      ),  
                    ),

                    Text('Text',style: TextStyle(fontSize: 15,)),

                  ],
                ),

                Column(
                  children: [

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'icons/microphone.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),

                    Text('Speech',style: TextStyle(fontSize: 15,)),
                  ],
                ),

                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          'icons/speech.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    
                    Text('Guided',style: TextStyle(fontSize: 15,)),
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
