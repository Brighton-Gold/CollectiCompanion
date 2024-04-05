import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_item.dart';
import 'display_item.dart';
import 'edit_catalog.dart'; // Import the edit_catalog.dart file

class DisplayCatalogContents extends StatefulWidget {
  final String catalogId;
  final String userId;
  final String catalogName;
  final String description;

  const DisplayCatalogContents({
    Key? key,
    required this.catalogId,
    required this.userId,
    required this.catalogName,
    required this.description,
  }) : super(key: key);

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
      // Handle the error appropriately.
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
        title: Text(widget.catalogName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditCatalog(
                    catalogId: widget.catalogId,
                    userId: widget.userId,
                    catalogName: widget.catalogName,
                    description: widget.description,
                    
                  ),
                ),
              );
            },
            icon: Icon(Icons.edit),
          ),
        ],
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
                return _buildGridTile(context, _catalogItems[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItemPage(context),
        tooltip: 'Add New Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, DocumentSnapshot item) {
    Map<String, dynamic> data = item.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () => _navigateToDisplayItemPage(context, item.id),
      child: Card(
        child: ListTile(
          title: Text(data['itemName'] ?? 'Unnamed Item'),
          subtitle: Text(data['description'] ?? 'No description available'),
        ),
      ),
    );
  }

  void _navigateToDisplayItemPage(BuildContext context, String itemId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DisplayItem(itemId: itemId, userId: widget.userId),
      ),
    );
  }

  void _navigateToAddItemPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddItem(catalogId: widget.catalogId, userId: widget.userId),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
