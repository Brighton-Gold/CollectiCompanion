import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/edit_item.dart';

class DisplayItem extends StatefulWidget {
  final String itemId;
  final String userId;

  const DisplayItem({Key? key, required this.itemId, required this.userId})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DisplayItemState createState() => _DisplayItemState();
}

class _DisplayItemState extends State<DisplayItem> {
  late Future<DocumentSnapshot> _itemData;

  @override
  void initState() {
    super.initState();
    _itemData = _fetchItemData();
  }

  Future<DocumentSnapshot> _fetchItemData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('itemList')
        .doc(widget.itemId)
        .get();
  }

  void refreshItemData() {
    setState(() {
      _itemData = _fetchItemData(); // Re-fetch the item data
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _itemData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error fetching data"));
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return const Center(child: Text("Item not found"));
        } else {
          Map<String, dynamic> itemData =
              snapshot.data!.data()! as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              title: Text(itemData['itemName'] ?? 'Unnamed Item'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Item Name: ${itemData['itemName']}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Description: ${itemData['description']}',
                      style: const TextStyle(fontSize: 18)),
                  // Add more fields as necessary
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditItem(
                    itemId: widget.itemId,
                    userId: widget.userId,
                    itemName: itemData['itemName'],
                    description: itemData['description'],
                    onItemUpdated: refreshItemData,
                  ),
                  //builder: (context) => EditItem(itemId: widget.itemId),
                ));
              },
              child: const Icon(Icons.edit),
            ),
          );
        }
      },
    );
  }
}
