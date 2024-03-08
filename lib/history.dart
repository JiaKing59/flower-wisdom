import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowerwisdom/detail.dart';
import 'package:flowerwisdom/firestore_service.dart';
import 'package:flowerwisdom/home.dart';
import 'package:flowerwisdom/profile.dart';
import 'package:flutter/material.dart';

enum SortOption { byName, byDate }

class HistoryRecord {
  final String imageUrl;
  final String name;
  final String description;
  final DateTime time;
  final String userId;
  final String recordId;
  String prediction;

  HistoryRecord({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.time,
    required this.userId,
    required this.prediction,
    required this.recordId,
  });
}

class HistoryPage extends StatefulWidget {
  final User? user;
  final FirestoreService firestoreService;

  const HistoryPage({Key? key, required this.user, required this.firestoreService})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _currentIndex = 1;
  late Stream<List<HistoryRecord>> _historyRecordsStream;
  SortOption _currentSortOption = SortOption.byName;

  @override
  void initState() {
    super.initState();
    _historyRecordsStream =
        widget.firestoreService.getHistoryRecords(widget.user?.uid);
  }

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
      body: StreamBuilder<List<HistoryRecord>>(
        stream: _historyRecordsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            List<HistoryRecord> historyRecords = snapshot.data ?? [];
            return _buildHistoryList(historyRecords);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
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
        selectedItemColor: _currentIndex == 1 ? Colors.blue : null,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            debugPrint('Navigate to Home Page');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: widget.user)),
            );
          } else if (index == 1) {
            debugPrint('You are already on the History Page');
          } else if (index == 2) {
            debugPrint('Navigate to Profile Page');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
            );
          }
        },
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryRecord> historyRecords) {
    // Sort the records based on the current sorting option
    historyRecords.sort((a, b) {
      if (_currentSortOption == SortOption.byName) {
        return a.name.compareTo(b.name);
      } else {
        return a.time.compareTo(b.time);
      }
    });

    return Column(
      children: [
        // Dropdown for sorting option
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<SortOption>(
            value: _currentSortOption,
            onChanged: (SortOption? option) {
              if (option != null) {
                setState(() {
                  _currentSortOption = option;
                });
              }
            },
            items: SortOption.values.map<DropdownMenuItem<SortOption>>((SortOption option) {
              return DropdownMenuItem<SortOption>(
                value: option,
                child: Text(option == SortOption.byName ? 'Sort by Name' : 'Sort by Date'),
              );
            }).toList(),
          ),
        ),
        // List of sorted history records
        Expanded(
          child: ListView.builder(
            itemCount: historyRecords.length,
            itemBuilder: (context, index) {
              final record = historyRecords[index];
              return record.prediction.isNotEmpty ? _buildHistoryCard(record, index + 1) : Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(HistoryRecord record, int cardNumber) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          _navigateToDetailsPage(record);
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.network(
                    record.imageUrl,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(record.description),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${record.time.toString()}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 60.0, 8.0, 16.0),
                child: ElevatedButton(
                  onPressed: () => _showDeleteConfirmation(context, record),
                  child: Text('Delete'),
                ),
              ),
            ),
            Positioned(
              left: 10.0,
              top: 20.0,
              child: Text(
                '$cardNumber',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, HistoryRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // ignore: unnecessary_null_comparison
                if (record.userId != null && record.recordId != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('history')
                        .doc(record.userId)
                        .collection('records')
                        .doc(record.recordId)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Record deleted successfully')),
                    );
                  } catch (e) {
                    print('Error deleting record: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting record')),
                    );
                  }
                } else {
                  print('Invalid userId or recordId');
                }

                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

void _navigateToDetailsPage(HistoryRecord record) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsPage(
        record: record,
        flower: null, // You may need to replace this with the appropriate Flower object
        firestoreService: widget.firestoreService,
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
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    user: widget.user!,
                  ),
                ),
              );
              }),
              _buildNavigationButton(context, 'History', Icons.history, () {
                Navigator.pop(context); // Close the dialog
                // Do nothing as you are already on the History Page
              }),
              _buildNavigationButton(context, 'Profile', Icons.person, () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user),
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

