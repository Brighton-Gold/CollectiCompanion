// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCatalog extends StatefulWidget {
  final String catalogId;
  final String userId;
  final String catalogName;
  final String description;

  const EditCatalog({
    Key? key,
    required this.catalogId,
    required this.userId,
    required this.catalogName,
    required this.description,
  }) : super(key: key);

  @override
  _EditCatalogState createState() => _EditCatalogState();
}

class _EditCatalogState extends State<EditCatalog> {
  final _formKey = GlobalKey<FormState>();
  late String _catalogName;
  late String _description;

  @override
  void initState() {
    super.initState();
    _catalogName = widget.catalogName;
    _description = widget.description;
  }

  void _updateCatalogData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('catalogList')
            .doc(widget.catalogId)
            .update({
          'catalogName': _catalogName,
          'description': _description,
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Catalog updated successfully"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to update catalog: $e"),
        ));
      }
    }
  }

  void _deleteItem() async {
    bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text(
                "Are you sure you want to delete this catalog? This action cannot be undone."),
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
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('catalogList')
            .doc(widget.catalogId)
            .delete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Catalog deleted successfully"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to delete catalog: $e"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Catalog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _catalogName,
                decoration: const InputDecoration(labelText: 'Catalog Name'),
                onChanged: (value) => _catalogName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a catalog name';
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
                onPressed: _updateCatalogData,
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteItem,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
