import 'package:flowerwisdom/feedbackInbox.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class InboxDetailsPage extends StatefulWidget {
  final FeedbackMessage feedbackMessage;
  final FirestoreService firestoreService;

  const InboxDetailsPage({
    required this.feedbackMessage,
    required this.firestoreService,
  });

  @override
  _InboxDetailsPageState createState() => _InboxDetailsPageState();
}

class _InboxDetailsPageState extends State<InboxDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow('User ID', widget.feedbackMessage.userId),
            buildInfoRow('User Email', widget.feedbackMessage.userEmail),
            buildInfoRow('Message', widget.feedbackMessage.message),
            buildInfoRow('Timestamp', widget.feedbackMessage.timestamp.toString()),
            // Add more information as needed
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
