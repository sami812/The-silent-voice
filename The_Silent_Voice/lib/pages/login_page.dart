import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_silent_voice/sign/user_cache.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidden = true;
  late final TextEditingController userPassword;
  late final TextEditingController userEmail;

  String? message;

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data();
  }

  Future<void> login() async {
    if (userPassword.text.length < 6) {
      if(!mounted) return;
      setState(() {
        message = 'Password must be at least 6 characters';
      });
      return;
    }
    if (userEmail.text.isEmpty || userPassword.text.isEmpty) {
      if(!mounted) return;
      setState(() {
        message = 'Please fill in all the fields';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail.text.trim(),
        password: userPassword.text.trim(),
      );
      userCache = await getUserData();
      if(!mounted) return;
      setState(() {
        message = null;
      });
    } on FirebaseAuthException catch (e) {
      if(!mounted) return;
      setState(() {
        if (e.code == 'user-not-found') {
          message = 'User not found';
        } else if (e.code == 'wrong-password') {
          message = 'Wrong password';
        } else if (e.code == 'invalid-credential') {
          message = 'Email or password is incorrect';
        }
      });
    }
  }

  Future<void> logInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (user == null) return;
      if (isNewUser) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'user',
          'photoUrl': user.photoURL,
          'createdAt': DateTime.now(),
        });
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Center(
                child: Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              content: Text(
                'Welcome to The silent voice, we create a new account for you.',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Ok',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
      userCache = await getUserData();
      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Account exists with different credential';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credential';
      }
    }
  }

  Future<void> forgotPassword() async {
    if (userEmail.text.trim().isEmpty) {
      if(!mounted) return;
      setState(() {
        message = 'Please enter your email first';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: userEmail.text.trim(),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Password reset link sent',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Ok',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.lightBlueAccent),
              ),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if(!mounted) return;
      setState(() {
        if (e.code == 'user-not-found') {
          message = 'User not found for that email';
        }else{
          message = 'Something went wrong, try again';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userPassword = TextEditingController();
    userEmail = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(color: Colors.blue, height: 300),
          ),
          Positioned(
            top: 100,
            left: 40,
            child: Text(
              'Welcome',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: userEmail,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onChanged: (_) {
                    setState(() {
                      message = null;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: userPassword,
                  obscureText: hidden,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidden ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => hidden = !hidden),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      message = null;
                    });
                  },
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (message != null)
                  Text(message!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    fixedSize: Size(350, 50),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(bottom: 50),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 40, right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Divider()),
                        Text(
                          ' Sign in with ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          logInWithGoogle();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/icons/google.png',
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    // mid , bottom , right , up
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 250,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
