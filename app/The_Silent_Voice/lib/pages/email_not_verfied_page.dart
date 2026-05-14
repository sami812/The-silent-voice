import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/pages/home_page.dart';

class EmailNotVerfiedPage extends StatefulWidget {
  const EmailNotVerfiedPage({super.key});

  @override
  State<EmailNotVerfiedPage> createState() => _EmailNotVerfiedPageState();
}

class _EmailNotVerfiedPageState extends State<EmailNotVerfiedPage> {
  bool sent = false;
  Future<void> resentEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.sendEmailVerification();
    setState(() {
      sent = true;
    });
  }

  Future<void> checkVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    if (user?.emailVerified == true) {
      if(!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not verified yet, please check your email'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              const Text(
                'Please verify your email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              const Text(
                'Check your inbox and click the link to verify your email',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: checkVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(250, 50),
                ),
                child: const Text('I’ve checked', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if(sent)
                    Text('Email sent!',style: TextStyle(color: Colors.green),)
        
                  else 
                    TextButton(onPressed: resentEmail, child: Text('Resend Email',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17,),)),

                  TextButton(onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  }, child: Text('Sign out',style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18,),)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
