import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'history.dart';

class DetailsPage extends StatefulWidget {
  final HistoryRecord record;
  final FirestoreService firestoreService;

  const DetailsPage({
    required this.record,
    required this.firestoreService, required flower,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Flower? _flower;
  ScrollController _controller = ScrollController();
  bool isScrolling = false;

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
    _fetchFlowerData(); // Assuming you want to fetch data on initState
    super.initState();
  }

  Future<void> _fetchFlowerData() async {
    try {
      // Fetch the flower details based on the record name
      _flower = await widget.firestoreService.getFlowerByName(widget.record.name);
      setState(() {});
    } catch (e) {
      print('Error fetching flower data: $e');
    }
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
      SizedBox(height: 16), // Add some spacing between rows
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Flower Details',
                style: TextStyle(
                  color: Colors.white, // Set the text color to white
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.record.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Add a gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Customize the SliverAppBar styles as needed
            backgroundColor: Colors.blue, // Set the background color
          ),
SliverList(
  delegate: SliverChildListDelegate(
    [
      Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 165, 239, 186),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_flower == null)
                CircularProgressIndicator(),

              // Display Name
              buildInfoRow('Name', widget.record.name),

              // Display Description
              buildInfoRow('Description', _flower?.description ?? 'Loading...'),

              // Display Flower Language
              buildInfoRow('Flower Language', _flower?.language ?? 'Loading...'),

              // Display Care Guidelines
              buildInfoRow('Care Guidelines', _flower?.careGuidelines ?? 'Loading...'),
              
              // Continue with other fields as needed
            ],
          ),
        ),
      ),
    ],
  ),
),

        ],
        
      ),
    );
  }
}
