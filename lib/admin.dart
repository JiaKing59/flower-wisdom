import 'package:flowerwisdom/appConfig.dart';
import 'package:flowerwisdom/feedbackInbox.dart';
import 'package:flowerwisdom/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'flowerForm.dart';

void _signOut(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Sign Out Confirmation'),
        content: Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();

              // Sign out the user
              await FirebaseAuth.instance.signOut();

              // Navigate back to the login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Sign Out'),
          ),
        ],
      );
    },
  );
}

Future<void> _changeFlaskServerUrl(BuildContext context, String currentUrl) async {
  TextEditingController urlController = TextEditingController();
  String currentUrl = await AppConfig().getFlaskServerUrl();
  urlController.text = currentUrl;

  String? newUrl = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Change Flask Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Reduce vertical space
          children: [
            Text('Current URL: $currentUrl'),
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: 'New URL'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(urlController.text); // Pass the entered URL
            },
            child: Text('Change URL'),
          ),
        ],
      );
    },
  );

  if (newUrl != null && newUrl.isNotEmpty) {
    // Update the Flask server URL
    await AppConfig().setFlaskServerUrl(newUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flask Server URL changed successfully'),
      ),
    );
  }
}



// ignore: must_be_immutable
class AdminOptions extends StatelessWidget {
  final User? user;
  final FirestoreService _firestoreService = FirestoreService();
  int unreadMessagesCount = 0;
  
  AdminOptions({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF89DDA1),
        actions: [
          // See Mail Method
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.mail),
                if (unreadMessagesCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        unreadMessagesCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _navigateToFeedbackInbox(context);
            },
          ),
          IconButton(
  icon: Icon(Icons.settings),
onPressed: () async {
  String currentUrl = await AppConfig().getFlaskServerUrl();
  _changeFlaskServerUrl(context, currentUrl);
},
),

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
          ),
        ],
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
body: StreamBuilder<List<Flower>>(
  stream: _firestoreService.getFlowers(),
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data == null) {
      return const CircularProgressIndicator();
    }

    List<Flower> flowers = snapshot.data!;
    flowers.sort((a, b) => a.name.compareTo(b.name)); // Sort by flower names

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
          ),
        ),
        child: PaginatedDataTable(
          header: const Text('Flower Data'),
          rowsPerPage: 10,
          columns: [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Flower Language',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Care Guidelines',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Operation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          source: _FlowerDataSource(flowers, context, _firestoreService),
        ),
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final addedFlower = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FlowerForm(firestoreService: _firestoreService),
            ),
          );

          if (addedFlower != null && addedFlower is Flower) {
            await _firestoreService.addFlower(addedFlower);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Flower added successfully'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToFeedbackInbox(BuildContext context) {
    Stream<List<FeedbackMessage>> feedbackStream = _firestoreService.feedbackStream;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageInboxPage(
          feedbackStream: feedbackStream,
          firestoreService: _firestoreService,
          user: user,
        ),
      ),
    );
  }
}

class _FlowerDataSource extends DataTableSource {
  final List<Flower> _flowers;
  final BuildContext _context;
  final FirestoreService _firestoreService;

  _FlowerDataSource(this._flowers, this._context, this._firestoreService);

  @override
  DataRow getRow(int index) {
    final flower = _flowers[index];
    final isOddRow = index.isOdd;
    const cellTextStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
    );

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return isOddRow ? const Color.fromARGB(255, 169, 227, 254) : Colors.white;
        },
      ),
      cells: [
        DataCell(
          Container(
            width: _calculateColumnWidth(0),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              flower.name,
              style: cellTextStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: _calculateColumnWidth(1),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              flower.description,
              style: cellTextStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: _calculateColumnWidth(2),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              flower.language,
              style: cellTextStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: _calculateColumnWidth(3),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              flower.careGuidelines,
              style: cellTextStyle,
            ),
          ),
        ),
        DataCell(
          Container(
            width: _calculateColumnWidth(4),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        _context,
                        MaterialPageRoute(
                          builder: (_context) => FlowerForm(
                            firestoreService: _firestoreService,
                            documentId: flower.documentId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      bool confirmDelete = await showDialog(
                        context: _context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete this flower?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await _firestoreService.deleteFlower(flower.documentId);
                        ScaffoldMessenger.of(_context).showSnackBar(
                          const SnackBar(
                            content: Text('Flower deleted successfully'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    
  }


  double _calculateColumnWidth(int columnIndex) {
    double screenWidth = MediaQuery.of(_context).size.width;
    switch (columnIndex) {
      case 0:
        return screenWidth * 0.2;
      case 1:
        return screenWidth * 0.2;
      case 2:
        return screenWidth * 0.2;
      case 3:
        return screenWidth * 0.2;
      case 4:
        return screenWidth * 0.2;
      default:
        return screenWidth * 0.2;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _flowers.length;

  @override
  int get selectedRowCount => 0;

}
