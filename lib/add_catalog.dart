// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddCatalogScreen extends StatefulWidget {
  final String userId;
  final Function onCatalogAdded;

  const AddCatalogScreen(
      {Key? key, required this.userId, required this.onCatalogAdded})
      : super(key: key);

  @override
  _AddCatalogScreenState createState() => _AddCatalogScreenState();
}

class _AddCatalogScreenState extends State<AddCatalogScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _selectedColor = Colors.white;
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCatalog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Catalog Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Catalog Description'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectColor,
              child: const Text('Select Color'),
            ),
            const SizedBox(height: 10),
            _buildImagePicker(), // Use the _buildImagePicker function here
            imageUrl != null
                ? Image.network(imageUrl!)
                : Container(), // Displaying the uploaded image
          ],
        ),
      ),
    );
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveCatalog() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference catalogRef = firestore
        .collection('users')
        .doc(widget.userId)
        .collection('catalogList')
        .doc();

    String colorString =
        '#${_selectedColor.value.toRadixString(16).substring(2)}';

    await catalogRef.set({
      'catalogId': catalogRef.id,
      'catalogName': _nameController.text,
      'description': _descriptionController.text,
      'color': colorString,
      'imageUrl': imageUrl, // Save the URL of the uploaded image
    });

    widget.onCatalogAdded(); // Invoke the callback here
    Navigator.pop(context);
  }

  Widget _buildImagePicker() {
    if (kIsWeb) {
      // Web-specific UI
      return IconButton(
        onPressed: _pickAndUploadImage,
        icon: const Icon(Icons.camera_alt),
      );
    } else {
      // Mobile-specific or other platforms UI
      return Container(); // Return an empty container for non-web platforms
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child("images/$fileName");

      try {
        await storageRef.putFile(imageFile);
        String downloadedUrl = await storageRef.getDownloadURL();
        setState(() {
          imageUrl = downloadedUrl;
        });
      } catch (e) {
        // Handle errors in uploading
      }
    }
  }
}
