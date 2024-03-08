import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowerwisdom/feedbackInbox.dart';
import 'package:flowerwisdom/feedback_form.dart';
import 'package:flowerwisdom/firestore_service.dart';
import 'package:flowerwisdom/history.dart';
import 'package:flowerwisdom/home.dart';
import 'package:flowerwisdom/main.dart';
import 'package:flutter/material.dart';

class Profile {
  final String displayName;
  final String email;

  Profile({required this.displayName, required this.email});
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data as User?;
            return MaterialApp(
              home: user != null ? ProfilePage(user: user) : LoginPage(),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({Key? key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2; // Initialize with the index of 'Profile'
  FirestoreService _firestoreService = FirestoreService();
  List<FeedbackMessage> _feedbackInbox = [];
  
  void _handleFeedbackSubmission(FeedbackMessage feedback) {
    setState(() {
      _feedbackInbox.add(feedback);
    });
  }
  // Function to show a double confirmation dialog for logout
  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Logout the user
                await FirebaseAuth.instance.signOut();

                // Navigate back to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Profile userProfile = Profile(
      displayName: widget.user?.displayName ?? 'User',
      email: widget.user?.email ?? 'user@example.com',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF89DDA1),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _showDetailsNavigationDrawer(context);
          },
        ),
        title: const Text(
          'Flower Wisdom',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Imprint MT Shadow',
            fontSize: 20.0,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 3.0,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFB0EDC1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Display Name: ${userProfile.displayName}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${userProfile.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
       ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackForm(
              user: widget.user!,
              firestoreService: _firestoreService,
              onFeedbackSubmitted: _handleFeedbackSubmission,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: const Color.fromARGB(255, 101, 230, 106),
      ),
      child: Text('Submit Feedback'),
    ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show double confirmation dialog for logout
                _showLogoutConfirmation();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Red background for Logout button
              ),
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: _currentIndex == 2 ? Colors.blue : null,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            debugPrint('Navigate to Home Page');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: widget.user!)),
            );
          } else if (index == 1) {
            debugPrint('Navigate to History Page');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoryPage(
                  user: widget.user!,
                  firestoreService: FirestoreService(),
                ),
              ),
            );
          } else if (index == 2) {
            debugPrint('You are already on the Profile Page');
          }
        },
      ),
    );
  }
  void _showDetailsNavigationDrawer(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Navigate to:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDetailsNavigationButton(context, 'Home', Icons.home, () {
              Navigator.pop(context); // Close the dialog
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: widget.user!,
                  ),
                ),
              );
            }),
            _buildDetailsNavigationButton(context, 'History', Icons.history, () {
              Navigator.pop(context); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(
                    user: widget.user!,
                    firestoreService: FirestoreService(),
                  ),
                ),
              );
            }),
            _buildDetailsNavigationButton(context, 'Profile', Icons.person, () {
              Navigator.pop(context); // Close the dialog
            }),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailsNavigationButton(
    BuildContext context, String label, IconData icon, VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
    ),
  );
}
}
