import 'package:flowerwisdom/appConfig.dart';
import 'package:flowerwisdom/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flowerwisdom/prediction.dart';
import 'history.dart';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    User? user; // Nullable User type
    return MaterialApp(
      home: HomePage(user: user),
    );
  }
}

class HomePage extends StatelessWidget {
  final User? user;

  HomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF89DDA1),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _showNavigationDrawer(context);
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
      body: Column(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Select Image Of Flower To Understand More',
                style: TextStyle(fontSize: 30.0, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/flower.jpg',
                    fit: BoxFit.cover,
                    width: 500,
                    height: 500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _showImageSourceDialog(context);
                },
                child: const Text('Start Prediction'),
              ),
            ),
          ),
        ],
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
          )
        ],
        onTap: (int index) {
          if (index == 0) {
            debugPrint('You are already on the Home Page');
          } else if (index == 1) {
            debugPrint('Navigate to History Page');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage(user: user, firestoreService: FirestoreService()),
              ),
            );
          } else if (index == 2) {
            debugPrint('Navigate to Profile Page');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
            );
          }
        },
      ),
    );
  }

Future<void> _showImageSourceDialog(BuildContext context) async {
  // Create an instance of AppConfig
  AppConfig appConfig = AppConfig();

  // Use 'await' to get the actual value from the Future
  String flaskServerUrl = await appConfig.getFlaskServerUrl();

  // No need to show the dialog, directly navigate to PredictionPage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => PredictionPage(
        user: user,
        flaskServerUrl: flaskServerUrl,  // Use the awaited value
        firestoreService: FirestoreService(),
        historyRecords: [],
      ),
    ),
  );
}



 Future<void> _showNavigationDrawer(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Navigate to:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildNavigationButton(context, 'Home', Icons.home, () {
                Navigator.pop(context); // Close the dialog
              }),
              _buildNavigationButton(context, 'History', Icons.history, () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      user: user,
                      firestoreService: FirestoreService(),
                    ),
                  ),
                );
              }),
              _buildNavigationButton(context, 'Profile', Icons.person, () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  Widget _buildNavigationButton(
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


