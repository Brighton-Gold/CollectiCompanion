import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCatalogScreen extends StatefulWidget {
  final String userId;

  const AddCatalogScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddCatalogScreenState createState() => _AddCatalogScreenState();
}

class _AddCatalogScreenState extends State<AddCatalogScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Color _selectedColor = Colors.white;

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
              decoration: const InputDecoration(labelText: 'Catalog Description'),
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allows the input to expand to multiple lines
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectColor,
              child: const Text('Select Color'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadFile,
              child: const Text('Upload Image (Placeholder)'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCatalog() async {
    String catalogId = FirebaseFirestore.instance.collection('users').doc().id;

    // Convert color to HEX string (excluding alpha)
    String colorString = '#${_selectedColor.value.toRadixString(16).substring(2)}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('cataloglist')
        .doc(catalogId)
        .set({
      'catalogName': _nameController.text,
      'color': colorString,
      'discription': _descriptionController.text,
      // 'imgbase64': // Implement photo functionality here if needed
    });
    Navigator.pop(context);
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

  void _uploadFile() {
    // Placeholder for file upload logic
    // Implement file upload functionality here
  }
}
