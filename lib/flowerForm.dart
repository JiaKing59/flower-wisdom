import 'package:flutter/material.dart';
import 'package:flowerwisdom/firestore_service.dart';

class FlowerForm extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? documentId;

  const FlowerForm({Key? key, required this.firestoreService, this.documentId}) : super(key: key);


  @override
  _FlowerFormState createState() => _FlowerFormState();
}

class _FlowerFormState extends State<FlowerForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _careGuidelinesController = TextEditingController();

  late FocusNode _descriptionFocusNode;
  late FocusNode _languageFocusNode;

  @override
  void initState() {
    super.initState();

    // If documentId is provided, load existing flower data
    if (widget.documentId != null) {
      _loadExistingFlowerData();
    }

    // Initialize focus nodes
    _descriptionFocusNode = FocusNode();
    _languageFocusNode = FocusNode();
  }

  void _loadExistingFlowerData() async {
    final flower = await widget.firestoreService.getFlower(widget.documentId!);
    if (flower != null) {
      _nameController.text = flower.name;
      _descriptionController.text = flower.description;
      _languageController.text = flower.language;
      _careGuidelinesController.text = flower.careGuidelines;
    }
  }

  @override
  void dispose() {
    // Dispose of the focus nodes
    _descriptionFocusNode.dispose();
    _languageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId != null ? 'Edit Flower' : 'Add Flower'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard('Name', _nameController, textInputAction: TextInputAction.next),
            _buildInfoCard('Description', _descriptionController, focusNode: _descriptionFocusNode, textInputAction: TextInputAction.next),
            _buildInfoCard('Flower Language', _languageController, focusNode: _languageFocusNode, textInputAction: TextInputAction.next),
            _buildInfoCard('Care Guidelines', _careGuidelinesController),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final flower = Flower(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  language: _languageController.text,
                  careGuidelines: _careGuidelinesController.text,
                );

                if (widget.documentId != null) {
                  await widget.firestoreService.updateFlower(widget.documentId!, flower);
                } else {
                  await widget.firestoreService.addFlower(flower);
                }

                Navigator.pop(context); // Close the form after saving
              },
              child: Text(widget.documentId != null ? 'Save Changes' : 'Add Flower'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, TextEditingController controller,
      {FocusNode? focusNode, TextInputAction? textInputAction}) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(border: InputBorder.none),
              maxLines: null, // Allow multiple lines
              textInputAction: textInputAction,
              onFieldSubmitted: (value) {
                if (focusNode != null) {
                  FocusScope.of(context).requestFocus(focusNode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
