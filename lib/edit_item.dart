// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditItem extends StatefulWidget {
  final String itemId;
  final String userId;
  final String itemName;
  final String description;
  final Function onItemUpdated;

  const EditItem(
      {Key? key,
      required this.itemId,
      required this.userId,
      required this.itemName,
      required this.description,
      required this.onItemUpdated})
      : super(key: key);

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  final _formKey = GlobalKey<FormState>();
  late String _itemName;
  late String _description;

  @override
  void initState() {
    super.initState();
    // Initialize the fields with the current item data
    _itemName = widget.itemName;
    _description = widget.description;
  }

  void _updateItemData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('itemList')
          .doc(widget.itemId)
          .update({
        'itemName': _itemName,
        'description': _description,
      });
      widget.onItemUpdated();
      Navigator.pop(context);
    }
  }

  void _deleteItem() async {
    bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text(
                "Are you sure you want to delete this item? This action cannot be undone."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
            ],
          );
        });

    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('itemList')
          .doc(widget.itemId)
          .delete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _itemName,
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (value) => _itemName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => _description = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateItemData,
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteItem,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
