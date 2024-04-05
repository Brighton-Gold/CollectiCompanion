import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItem extends StatefulWidget {
  final String catalogId;
  final String userId;
  final Function onItemAdded;

  const AddItem(
      {Key? key,
      required this.catalogId,
      required this.userId,
      required this.onItemAdded})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          widget
              .onItemAdded(); // Invoke the callback when back button is pressed
          return true; // Allows the screen to be popped
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Item to Catalog'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveItem, // Connect the _saveItem method here
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ));
  }

  void _saveItem() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference itemListRef = firestore
          .collection('users')
          .doc(widget.userId)
          .collection('itemList')
          .doc();

      String itemId = itemListRef.id;

      // Use set to add a new document to itemList
      await itemListRef.set({
        'itemName': _nameController.text,
        'description': _descriptionController.text,
        'catalogId': widget.catalogId,
        'itemId': itemId,
      });

      // Clearing the text fields after successful upload
      _nameController.clear();
      _descriptionController.clear();

      // Show a success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item added successfully!")));
    } catch (e) {
      // Show an error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error adding item: $e")));
    }
  }
}
