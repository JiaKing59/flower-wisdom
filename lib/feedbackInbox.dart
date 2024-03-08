import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowerwisdom/firestore_service.dart';
import 'package:flowerwisdom/inbox.dart';
import 'package:flutter/material.dart';

class FeedbackMessage {
  final String userId;
  final String userEmail;
  final String message;
  final DateTime timestamp;
  bool isRead;
  String documentId;

  FeedbackMessage({
    required this.userId,
    required this.userEmail,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.documentId,
  });
}

class MessageInboxPage extends StatefulWidget {
  final User? user;
  final FirestoreService firestoreService;

  // Pass the feedbackStream as a parameter
  const MessageInboxPage({
    Key? key,
    required this.user,
    required this.firestoreService,
    required this.feedbackStream,
  }) : super(key: key);

  // Declare the feedbackStream variable
  final Stream<List<FeedbackMessage>> feedbackStream;

  @override
  _MessageInboxPageState createState() => _MessageInboxPageState();
}

class _MessageInboxPageState extends State<MessageInboxPage> {
  // Remove late from _feedbackStream declaration
  late Stream<List<FeedbackMessage>> _feedbackStream;

  @override
  void initState() {
    super.initState();
    // Assign widget.feedbackStream directly
    _feedbackStream = widget.feedbackStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF89DDA1),
        title: const Text(
          'Flower Wisdom - Inbox',
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
      body: StreamBuilder<List<FeedbackMessage>>(
        stream: _feedbackStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            List<FeedbackMessage> feedbackMessages = snapshot.data ?? [];
            return _buildFeedbackList(feedbackMessages);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildFeedbackList(List<FeedbackMessage> feedbackMessages) {
    return ListView.builder(
      itemCount: feedbackMessages.length,
      itemBuilder: (context, index) {
        final feedbackMessage = feedbackMessages[index];
        return _buildFeedbackCard(feedbackMessage);
      },
    );
  }

Widget _buildFeedbackCard(FeedbackMessage feedbackMessage) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.all(8),
    child: ListTile(
      title: Text(feedbackMessage.userEmail),
      subtitle: Text(feedbackMessage.message),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          // Call a function to delete the feedbackMessage
          _deleteFeedback(feedbackMessage);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InboxDetailsPage(
              feedbackMessage: feedbackMessage,
              firestoreService: widget.firestoreService,
            ),
          ),
        );
      },
    ),
  );
}

void _deleteFeedback(FeedbackMessage feedbackMessage) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete Feedback'),
        content: Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Call the delete function from FirestoreService
              await widget.firestoreService.deleteFeedback(feedbackMessage);

              // Close the dialog
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}
}
