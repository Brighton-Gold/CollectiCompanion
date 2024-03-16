import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayCatalogContents extends StatefulWidget {
  final String catalogId;
  final String userId;

  const DisplayCatalogContents(
      {Key? key, required this.catalogId, required this.userId})
      : super(key: key);

  @override
  _DisplayCatalogContentsState createState() => _DisplayCatalogContentsState();
}

class _DisplayCatalogContentsState extends State<DisplayCatalogContents> {
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
        .collection('itemList')
        .where('catalogId', isEqualTo: widget.catalogId)
        .limit(_itemsPerPage);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      var snapshot = await query.get();
      print('Documents fetched: ${snapshot.docs.length}'); // Debug print

      if (snapshot.docs.length < _itemsPerPage) {
        _hasMoreItems = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      setState(() {
        _catalogItems.addAll(snapshot.docs);
      });
    } catch (e) {
      print('Error fetching data: $e'); // Error handling
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalog Contents'),
      ),
      body: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust as needed
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
    // Here, you would construct the grid tile.
    // This is a basic placeholder, adjust it as per your item's data structure.
    return Card(
      child: ListTile(
        title: Text(data['name'] ?? 'Unnamed Item'),
        subtitle: Text(data['description'] ?? 'No description available'),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
