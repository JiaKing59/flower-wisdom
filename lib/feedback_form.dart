import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowerwisdom/feedbackInbox.dart';
import 'package:flutter/material.dart';

import 'firestore_service.dart';



class FeedbackForm extends StatefulWidget {
  final User user;
  final FirestoreService firestoreService;
  final Function(FeedbackMessage) onFeedbackSubmitted;

  FeedbackForm({Key? key, required this.user, required this.firestoreService, required this.onFeedbackSubmitted})
      : super(key: key);

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Enter your feedback'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                String feedbackMessage = _feedbackController.text.trim();
                if (feedbackMessage.isNotEmpty) {
                  FeedbackMessage feedback = FeedbackMessage(
                    userId: widget.user.uid,
                    userEmail: widget.user.email ?? 'N/A',
                    message: feedbackMessage,
                    timestamp: DateTime.now(), documentId: '',
                  );
                  await widget.firestoreService.addFeedback(feedback);
                  widget.onFeedbackSubmitted(feedback);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback submitted successfully'),
                    ),
                  );
                  // Clear the feedback text field after submission
                  _feedbackController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your feedback'),
                    ),
                  );
                }
              },
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
