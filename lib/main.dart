import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowerwisdom/admin.dart';
import 'package:flowerwisdom/home.dart';
import 'package:flowerwisdom/register.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, User? user});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Initialize Firebase APP
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const LoginScreen();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Login function
  static Future<User?> loginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        _showErrorDialog(context, "No user found for the given email");
      } else if (e.code == "wrong-password") {
        _showErrorDialog(context, "Wrong password provided");
      } else if (e.code == "invalid-email") {
        _showErrorDialog(context, "Invalid email address");
      } else {
        _showErrorDialog(context, "Login failed. Please try again later");
      }
    } catch (e) {
      _showErrorDialog(context, "An unexpected error occurred");
    }

    return user;
  }
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    const String adminEmail = 'adfw@gmail.com';
    const String adminPassword = 'adfw123456';
    // create textfiled controller
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Container(
      color: const Color(0xFF89DDA1),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/logo.png',
              height: 200,
            ),
          ),
          const SizedBox(
            height: 44.0,
          ),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "User Email",
              prefixIcon: Icon(Icons.mail),
            ),
          ),
          const SizedBox(
            height: 26.0,
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "User Password",
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(
            height: 88.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2 - 20,
                child: RawMaterialButton(
                  fillColor: const Color(0xFF0069FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onPressed: () async {
                    User? user = await loginUsingEmailPassword(
                      email: emailController.text,
                      password: passwordController.text,
                      context: context,
                    );
                    if (user != null) {
                      if (emailController.text == adminEmail && passwordController.text == adminPassword) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>  AdminOptions(user: user),
                        ),
                      );
                      } else{
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>  HomePage(user: user),
                      
                        ),
                      );
                      }
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2 - 20,
                child: RawMaterialButton(
                  fillColor: const Color(0xFF0069FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onPressed: () {
                    // Navigate to the register page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Register',
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      )
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
}
}