// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_item.dart'; // Make sure this is the correct import

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
  final List<DocumentSnapshot> _catalogItems = [];
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
      // print('Error fetching data: $e');
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
        title: const Text('Catalog Contents'),
      ),
      body: _catalogItems.isEmpty && !_isLoading
          ? const Center(
              child: Text(
                  'No items in the catalog. Add new items using the button below.'),
            )
          : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItemPage(context),
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        title: Text(data['itemName'] ?? 'Unnamed Item'),
        subtitle: Text(data['description'] ?? 'No description available'),
      ),
    );
  }

  void _navigateToAddItemPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              AddItem(catalogId: widget.catalogId, userId: widget.userId)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
