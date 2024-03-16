// Start by importing the necessary packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addCatalogScreen.dart'; // Make sure this is the correct import
import 'display_catalog_contents.dart'; // Import the DisplayCatalogContents screen

class CatalogList extends StatefulWidget {
  final String userId;

  const CatalogList({Key? key, required this.userId}) : super(key: key);

  @override
  _CatalogListState createState() => _CatalogListState();
}

class _CatalogListState extends State<CatalogList> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _catalogItems = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMoreItems = true;
  bool _isLoading = false;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    if (!_hasMoreItems) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cataloglist')
        .orderBy('catalogName') // Adjust the field name as needed
        .limit(_itemsPerPage);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    var snapshot = await query.get();
    if (snapshot.docs.length < _itemsPerPage) {
      _hasMoreItems = false;
    }

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    setState(() {
      _catalogItems.addAll(snapshot.docs);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600
        ? 2
        : screenWidth < 900
            ? 3
            : 4;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddCatalogScreen(userId: widget.userId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: _catalogItems.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data =
              _catalogItems[index].data()! as Map<String, dynamic>;
          return _buildGridTile(context, data);
        },
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, Map<String, dynamic> data) {
    Widget imageWidget;

    // Check for base64 image
    if (data['imgbase64'] != null && data['imgbase64'].toString().isNotEmpty) {
      String base64String = data['imgbase64'];
      if (base64String.startsWith('data:image')) {
        base64String = base64String.split(',')[1];
      }
      imageWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover);
    } else {
      // Use color from Firebase, default to purple if not available
      Color backgroundColor = Colors.purple;
      if (data['color'] != null && data['color'].toString().isNotEmpty) {
        try {
          String colorString = data['color'];
          backgroundColor = _colorFromHex(colorString);
        } catch (e) {
          // If parsing fails, default color is used
        }
      }
      imageWidget = Container(color: backgroundColor);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayCatalogContents(
                catalogId: data['catalogId'], userId: widget.userId),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageWidget,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                data['catalogName'] ?? 'Unnamed Catalog',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                data['description'] ?? 'No description available',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor; // Add alpha value if missing
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
