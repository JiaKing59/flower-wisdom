
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowerwisdom/feedbackInbox.dart';
import 'package:flowerwisdom/history.dart';


class Flower {
  final String name;
  final String description;
  final String language;
  final String careGuidelines;
  final String? documentId;

  Flower({
    required this.name,
    required this.description,
    required this.language,
    required this.careGuidelines,
    this.documentId,
  });


    // Add this factory constructor
  factory Flower.fromMap(Map<String, dynamic> map) {
    return Flower(
      name: map['name'],
      description: map['description'],
      language: map['language'],
      careGuidelines: map['careGuidelines'],
      documentId: map['documentId'],
    );
  }

  factory Flower.fromSnapshot(DocumentSnapshot<Object?> snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return Flower(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      language: data['language'] ?? '',
      careGuidelines: data['careGuidelines'] ?? '',
      documentId: snapshot.id,
    );
  }
}
class FeedbackDeleteException implements Exception {
  final String message;

  FeedbackDeleteException(this.message);

  @override
  String toString() => 'FeedbackDeleteException: $message';
}
class FirestoreService {
  final CollectionReference _flowersCollection =
      FirebaseFirestore.instance.collection('flowers');
  final CollectionReference historyCollection = 
      FirebaseFirestore.instance.collection('history');
  late Stream<List<FeedbackMessage>> feedbackStream;

  Stream<List<Flower>> getFlowers() {
    return _flowersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Flower.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>)).toList();
    });
  }
    Future<void> saveHistoryRecord(String? userId, HistoryRecord record) async {
    try {
      // Ensure userId is not null before saving
      if (userId != null) {
        await historyCollection.doc(userId).collection('records').add({
          'imageUrl': record.imageUrl,
          'name': record.name,
          'description': record.description,
          'time': record.time,
          'prediction': record.prediction,
        });
      }
    } catch (e) {
      print('Error saving history record: $e');
      // Handle error, log, or throw an exception as needed
    }
  }
  
Stream<List<HistoryRecord>> getHistoryRecords(String? userId) {
  try {
    if (userId != null) {
      return historyCollection
          .doc(userId)  // Assuming userId is the ID of a user document
          .collection('records')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return HistoryRecord(
                imageUrl: doc['imageUrl'] ?? '',
                name: doc['name'] ?? '',
                description: doc['description'] ?? '',
                time: doc['time']?.toDate() ?? DateTime.now(),
                prediction: doc['prediction'] ?? '', 
                userId: userId,
                recordId: doc.id,
              );
            }).toList();
          });
    } else {
      print('Error: userId is null.');
      return Stream.value([]); // Return an empty stream if userId is null
    }
  } catch (e) {
    print('Error fetching history records: $e');
    throw e; // You can handle the error in an appropriate way
  }
}


Future<void> deleteRecord(String? userId, String? recordId) async {
  try {
    // Ensure userId and recordId are not null before deleting
    if (userId != null && recordId != null) {
      await FirebaseFirestore.instance
          .collection('history')
          .doc(userId)
          .collection('records')
          .doc(recordId)
          .delete();
    }
  } catch (e) {
    print('Error deleting record: $e');
    // Handle error, log, or throw an exception as needed
  }
}


  
  Future<void> addFlower(Flower flower) {
    return _flowersCollection.add({
      'name': flower.name,
      'description': flower.description,
      'language': flower.language,
      'careGuidelines': flower.careGuidelines,
    });
  }

  Future<void> updateFlower(String documentId, Flower flower) {
    return _flowersCollection.doc(documentId).update({
      'name': flower.name,
      'description': flower.description,
      'language': flower.language,
      'careGuidelines': flower.careGuidelines,
    });
  }

  Future<Flower?> getFlower(String documentId) async {
    final snapshot = await _flowersCollection.doc(documentId).get();
    if (snapshot.exists) {
      return Flower.fromSnapshot(snapshot);
    }
    return null;
  }

 Future<void> deleteFlower(String? documentId) {
  if (documentId == null) {
    throw ArgumentError('documentId must not be null for deleteFlower');
  }

  return _flowersCollection.doc(documentId).delete();
}


  Future<Flower?> getFlowerByName(String name) async {
    try {
      final querySnapshot = await _flowersCollection.where('name', isEqualTo: name).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you only expect one document with the given name
        final flowerData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        return Flower(
          name: flowerData['name'] ?? '',
          description: flowerData['description'] ?? '',
          language: flowerData['language'] ?? '',
          careGuidelines: flowerData['careGuidelines'] ?? '',
          documentId: querySnapshot.docs.first.id,
        );
      }
    } catch (e) {
      print('Error fetching flower data by name: $e');
    }

    return null;
  }
Future<void> addFeedback(FeedbackMessage feedback) async {
  try {
    var docRef = await FirebaseFirestore.instance.collection('feedback').add({
      'userId': feedback.userId,
      'userEmail': feedback.userEmail,
      'message': feedback.message,
      'timestamp': feedback.timestamp,
      'isRead': feedback.isRead,
    });

    // Update the feedback with the assigned document ID
    feedback.documentId = docRef.id;
  } catch (e) {
    print('Error adding feedback: $e');
  }
}

Stream<List<FeedbackMessage>> getFeedback() {
    return FirebaseFirestore.instance.collection('feedback').snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return FeedbackMessage(
          userId: doc['userId'],
          userEmail: doc['userEmail'],
          message: doc['message'],
          timestamp: doc['timestamp'].toDate(),
          isRead: doc['isRead'], 
          documentId: doc.id,
        );
      }).toList();
    });
  }

  FirestoreService() {
    // Initialize feedbackStream in the constructor
    feedbackStream = getFeedback();
  }
  
Future<void> deleteFeedback(FeedbackMessage feedbackMessage) async {
  try {
    String documentId = feedbackMessage.documentId;

    if (documentId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(documentId)
          .delete();
      print('Feedback deleted successfully');
    } else {
      throw FeedbackDeleteException('Invalid document ID');
    }
  } catch (e) {
    print('Error deleting feedback: $e');
  }
}




}

