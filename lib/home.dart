import 'package:flutter/material.dart';
import 'display_catalogs.dart'; // Ensure this file contains the CatalogList widget

class HomePage extends StatelessWidget {
  final String userId;
  
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: CatalogList(userId: userId), // Your custom widget for the catalog list
    );
  }
}
