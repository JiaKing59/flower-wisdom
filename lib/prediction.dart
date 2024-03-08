import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flowerwisdom/history.dart';
import 'package:flowerwisdom/home.dart';
import 'package:flowerwisdom/profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'firestore_service.dart';

class PredictionPage extends StatefulWidget {
  final User? user;
  final String flaskServerUrl;
  final FirestoreService firestoreService;
  final List<HistoryRecord> historyRecords;

  const PredictionPage({
    Key? key,
    required this.user,
    required this.flaskServerUrl,
    required this.firestoreService,
    required this.historyRecords,
  }) : super(key: key);

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  late final ScrollController _controller;
  bool isScrolling = false;
  String imageUrl = "";
  Uint8List? imageBytes;

  List<List<String>> tableData = [
    ['Name:', ''],
    ['Description:', ''],
    ['Flower Language:', ''],
    ['Care Guidelines:', ''],
  ];

  void _handleScrollChange() {
    if (isScrolling != _controller.position.isScrollingNotifier.value) {
      setState(() {
        isScrolling = _controller.position.isScrollingNotifier.value;
      });
    }
  }

  void _handlePositionAttach(ScrollPosition position) {
    position.isScrollingNotifier.addListener(_handleScrollChange);
  }

  void _handlePositionDetach(ScrollPosition position) {
    position.isScrollingNotifier.removeListener(_handleScrollChange);
  }

  @override
  void initState() {
    _controller = ScrollController(
      onAttach: _handlePositionAttach,
      onDetach: _handlePositionDetach,
    );
    super.initState();
  }

  void _updatePredictionInTable(String prediction) {
    setState(() {
      tableData[0][1] = prediction; // Corrected index for prediction
    });
  }

  Future<void> _fetchFlowerData(String prediction) async {
    try {
      Flower? flowerData = await widget.firestoreService.getFlowerByName(prediction);

      setState(() {
        tableData[1][1] = flowerData!.description;
        tableData[2][1] = flowerData.language;
        tableData[3][1] = flowerData.careGuidelines;
      });
    } catch (e) {
      print('Error fetching flower data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
  controller: _controller,
  child: Padding(
    padding: const EdgeInsets.all(20.0), // Add your desired padding
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImagePicker(context),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_selectedImage != null) {
              _classifyImage(_selectedImage!);
            } else {
              print('Please select an image first.');
            }
          },
          child: const Text('Classify Image'),
        ),
        const SizedBox(height: 50),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _buildExcelLikeTable(),
        ),
      ],
    ),
  ),
),



    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.white,
      ),
      child: _selectedImage == null
          ? IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                _showImageSourceDialog(context);
              },
            )
          : Stack(
              children: [
                Image.memory(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: 300,
                  height: 300,
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _removeImage();
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Widget _buildExcelLikeTable() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Table(
            columnWidths: const {
              0: FractionColumnWidth(0.35),
              1: FractionColumnWidth(0.65),
            },
            children: tableData.map((rowData) {
              return _buildExcelLikeTableRow(rowData, Colors.white);
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _saveResult();
              },
              child: const Text('Save Result'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _clearInformation();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  TableRow _buildExcelLikeTableRow(List<String> values, Color backgroundColor) {
    return TableRow(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 30,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: backgroundColor,
                  ),
                  child: Text(
                    values[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 70,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: backgroundColor,
                  ),
                  child: Text(
                    values[1],
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Future<void> _showImageSourceDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select source'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Ensure the column takes the minimum space
          children: <Widget>[
            GestureDetector(
              child: const Text(
                'Take a picture',
                style: TextStyle(fontSize: 20), // Adjust font size
              ),
              onTap: () {
                _openCamera(context);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 20.0), // Adjust spacing
            GestureDetector(
              child: const Text(
                'Choose from gallery',
                style: TextStyle(fontSize: 20), // Adjust font size
              ),
              onTap: () {
                _openGallery(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}


  void _openCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      _handleImage(context, pickedFile.path);
    }
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _handleImage(context, pickedFile.path);
    }
  }

Future<void> _handleImage(BuildContext context, String imagePath) async {
  try {
    final imageBytes = await File(imagePath).readAsBytes();

    // Assuming you have a function to upload the image to the server
    String imageUrl = await uploadImageToServer(imageBytes);

    if (imageUrl.isNotEmpty) {
      setState(() {
        _selectedImage = Uint8List.fromList(imageBytes);
      });

      print('UI updated with selected image.');
      print('Image URL: $imageUrl');
    } else {
      _showErrorMessage('Error: Image upload failed.');
    }
  } catch (e) {
    _showErrorMessage('Error in handling image: $e');
  }
}





Future<String> uploadImageToServer(Uint8List? imageBytes) async {
  try {
    if (imageBytes == null) {
      print('Error: Image bytes are null');
      return ''; // Handle the error case
    }

    var uri = Uri.parse('${widget.flaskServerUrl}/predict'); 

    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);
      String imageUrl = result['image_url'];
      print('Image upload successful. Image URL: $imageUrl');
      return imageUrl;
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
      return ''; // Handle the error case
    }
  } catch (e) {
    print('Error uploading image: $e');
    return ''; // Handle the error case
  }
}




Future<void> _classifyImage(Uint8List imageBytes) async {
  try {
    print('Flask Server URL: ${widget.flaskServerUrl}');
    print('Sending image to server...');

    if (widget.flaskServerUrl.isNotEmpty) {
      var request =
          http.MultipartRequest('POST', Uri.parse('${widget.flaskServerUrl}/predict'));

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var result = jsonDecode(responseBody);
        String prediction = result['prediction'];

        if (prediction != 'Cannot detect flower') {
          _updatePredictionInTable(prediction);
          await _fetchFlowerData(prediction); // Fetch additional flower data
        }

        _showPredictionDialog(prediction);
      } else {
        _showErrorMessage('Failed to make a request. Status code: ${response.statusCode}');
      }
    } else {
      _showErrorMessage('Error: flaskServerUrl is null');
    }
  } catch (e) {
    _showErrorMessage('Error in classifying image: $e');
  }
}



Future<void> _saveResult() async {
  try {
    String name = tableData[0][1];
    String description = tableData[1][1];
    String prediction = tableData[2][1];

    // Ensure that name, description, and prediction are not empty
    if (name.isNotEmpty && description.isNotEmpty && prediction.isNotEmpty) {
      // Ensure that imageBytes is not null
      if (_selectedImage != null) {
        // Assuming you have a function to upload the image to the server
        String imageUrl = await uploadImageToServer(_selectedImage!);

        HistoryRecord newRecord = HistoryRecord(
          imageUrl: imageUrl, // If imageUrl is null, use an empty string
          name: name,
          description: description,
          time: DateTime.now(),
          prediction: prediction, userId: '', recordId: '',
        );

        widget.historyRecords.add(newRecord);

        setState(() {
          _selectedImage = null;
          tableData = [
            ['Name:', ''],
            ['Description:', ''],
            ['Flower Language:', ''],
            ['Care Guidelines:', ''],
          ];
        });

        await widget.firestoreService.saveHistoryRecord(widget.user?.uid, newRecord);

        print('Record saved successfully with image URL: $imageUrl');
      } else {
        _showErrorMessage('Error: Image bytes are null');
      }
    } else {
      _showErrorMessage('Error: Some fields are empty');
    }
  } catch (e) {
    _showErrorMessage('Error in saving record: $e');
  }
}

void _showErrorMessage(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
  void _clearInformation() {
    setState(() {
      _selectedImage = null;
      tableData = [
        ['Name:', ''],
        ['Description:', ''],
        ['Flower Language:', ''],
        ['Care Guidelines:', ''],
      ];
    });
  }

void _showPredictionDialog(String prediction) {
  String dialogTitle = 'Prediction Result';
  String dialogContent;

  if (prediction == 'Cannot detect flower') {
    dialogContent = 'Cannot detect any flower. Please select another image.';
  } else {
    dialogContent = 'The predicted flower is: $prediction';
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogContent),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
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
              Navigator.pop(context); 
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: widget.user),
                  ),
                );// Close the dialog
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
