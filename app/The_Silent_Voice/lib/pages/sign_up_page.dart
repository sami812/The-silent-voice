// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_silent_voice/pages/home_page.dart';
import 'package:the_silent_voice/pages/login_page.dart';
import 'package:the_silent_voice/upload_to_cloudinary.dart';
import 'package:the_silent_voice/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool hidden = true;
  late final TextEditingController userPassword;
  late final TextEditingController userEmail;
  late final TextEditingController userName;

  String? message;
  Future<void> signUp() async {
    if (userPassword.text.length < 6) {
      setState(() {
        message = 'Password must be at least 6 characters';
      });
      return;
    }
    if (userEmail.text.isEmpty || userName.text.isEmpty) {
      setState(() {
        message = 'Please fill in all the fields';
      });
      return;
    }
    if (_image == null) {
      setState(() {
        message = 'Please select an image';
      });
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: userEmail.text,
            password: userPassword.text,
          );
      String uid = userCredential.user!.uid;
      String imageUrl = await uploadToCloudinary(_image!);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': userEmail.text,
        'name': userName.text,
        'photoUrl': imageUrl,
        'createdAt': DateTime.now(),
      });
      Navigator.pop(context);
      setState(() {
        message = null;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        if (e.code == 'email-already-in-use') {
          message = 'Email already exists';
        } else if (e.code == 'weak-password') {
          message = 'Weak password';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email';
        }
      });
    }
  }

  String? googleMessage;
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (!mounted) return;
      if (googleUser == null) {
        Navigator.pop(context);
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
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final user = userCredential.user;
      if (!mounted) return;
      Navigator.pop(context);
      if (user == null) {
        return;
      }
      if(!isNewUser) {
        await FirebaseAuth.instance.signOut();
        if(!context.mounted) return;
        setState(() {
          googleMessage = 'Account already exists, please log in';
        });
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'user',
        'photoUrl': user.photoURL,
        'createdAt': DateTime.now(),
      }, SetOptions(merge: true));
      if (!context.mounted) return;
      setState(() {
        googleMessage = null;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        if (e.code == 'account-exists-with-different-credential') {
          googleMessage = 'Account exists with different credential';
        } else if (e.code == 'invalid-credential') {
          googleMessage = 'Invalid credential';
        }
        else {
          message = 'Error signing in with Google';
        }
      });
    }
  }

  Uint8List? _image;

  void selectImage(ImageSource source) async {
    Uint8List? image = await pickImage(source);
    if (image == null) return;
    setState(() {
      _image = image;
    });
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    userPassword = TextEditingController();
    userEmail = TextEditingController();
    userName = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(color: Colors.white),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(color: Colors.blue, height: 300),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              'Create \nAccount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 160,
            top: 180,
            child: GestureDetector(
              onTap: () {
                showImageOptions();
              },
              child: _image != null
                  ? CircleAvatar(
                      radius: 65,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : CircleAvatar(
                      radius: 65,
                      backgroundImage:
                          AssetImage("assets/icons/profile.avif")
                              as ImageProvider,
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(left: 20, right: 20, top: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: userName,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    border: UnderlineInputBorder(),
                    labelText: 'Name',
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
                SizedBox(height: 30),
                if (message != null)
                  Text(message!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    fixedSize: Size(350, 50),
                  ),
                  child: Text(
                    'Sign Up',
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
                          ' Sign up with ',
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
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(50),
                      //   child: Image.asset(
                      //     'assets/icons/Facebook.png',
                      //     width: 50,
                      //     height: 50,
                      //   ),
                      // ),
                      // SizedBox(width: 20),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(50),
                      //   child: Image.asset(
                      //     'assets/icons/google.jpg',
                      //     width: 50,
                      //     height: 50,
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          signInWithGoogle();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/icons/google.jpg',
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (googleMessage != null)
                    Text(googleMessage!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
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
      size.width - 100,
      size.height,
      size.width,
      size.height - 150,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
