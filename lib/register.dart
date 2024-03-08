import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flowerwisdom/home.dart';
import 'package:flowerwisdom/main.dart';
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
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Initialize Firebase APP
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Page'),
      ),
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const RegisterScreen();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Registration function
  static Future<User?> registerUsingEmailPassword({
    required String email,
    required String password,
    required String confirmationPassword,
    required BuildContext context,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      if (password != confirmationPassword) {
        throw FirebaseAuthException(
          code: 'passwords-do-not-match',
          message: 'Password and confirmation password do not match.',
        );
      }

      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error during registration: ${e.message}");

      // Handle specific errors if needed, e.g., show an error message to the user
      if (e.code == 'weak-password') {
        _showErrorDialog(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog(context, 'The account already exists for that email.');
      } else if (e.code == 'passwords-do-not-match') {
        _showErrorDialog(context, 'Password and confirmation password do not match.');
      }
    } catch (e) {
      print("Unexpected error during registration: $e");
      // Handle unexpected errors, e.g., show a generic error message
      _showErrorDialog(context, 'An unexpected error occurred during registration.');
    }

    return user;
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Error'),
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
    // Create text field controllers
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmationPasswordController =
        TextEditingController();

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
            height: 26.0,
          ),
          TextField(
            controller: confirmationPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Confirm Password",
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            child: const Text(
              "Already have an Existing Account?",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16.0,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(
            height: 88.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RawMaterialButton(
                  fillColor: const Color(0xFF0069FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onPressed: () async {
                    User? user = await registerUsingEmailPassword(
                      email: emailController.text,
                      password: passwordController.text,
                      confirmationPassword:
                          confirmationPasswordController.text,
                      context: context,
                    );

                    if (user != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>  HomePage(user: user),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
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
