import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'add_item.dart';
import 'display_item.dart';
import 'edit_catalog.dart';

class DisplayCatalogContents extends StatefulWidget {
  final String catalogId;
  final String userId;
  final String catalogName;
  final String description;
  //function to display catalog contents
  final Function displayCatalogContents;

  const DisplayCatalogContents({
    Key? key,
    required this.catalogId,
    required this.userId,
    required this.catalogName,
    required this.description,
    required this.displayCatalogContents,
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
      // Handle errors appropriately
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                      onCatalogUpdated: widget.displayCatalogContents),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
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
          return _buildGridTile(context, _catalogItems[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItemPage(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, DocumentSnapshot item) {
    Map<String, dynamic> data = item.data() as Map<String, dynamic>;

    Widget imageWidget;
    if (data['imagebase64'] != null &&
        data['imagebase64'].toString().isNotEmpty) {
      String base64String = data['imagebase64'];
      if (base64String.startsWith('data:image')) {
        base64String = base64String.split(',')[1];
      }
      imageWidget = Image.memory(base64Decode(base64String), fit: BoxFit.cover);
    } else {
      imageWidget = Container(color: Colors.grey); // Default placeholder
    }

    return GestureDetector(
      onTap: () => _navigateToDisplayItemPage(context, item.id),
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
                data['itemName'] ?? 'Unnamed Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                data['description'] ?? 'No description available',
                style: const TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
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
        builder: (context) => AddItem(
          catalogId: widget.catalogId,
          userId: widget.userId,
          onItemAdded: refreshItemList,
        ),
      ),
    );
  }

  void refreshItemList() {
    setState(() {
      _catalogItems.clear();
      _lastDocument = null;
      _hasMoreItems = true;
      _loadItems();
    });
  }

  void refreshCatalog() {
    setState(() {
      _catalogItems.clear();
      _lastDocument = null;
      _hasMoreItems = true;
      _loadItems();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
