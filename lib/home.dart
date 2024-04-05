import 'package:flutter/material.dart';
import 'display_catalogs.dart'; 
import 'search.dart'; // Ensure this import is present

class HomePage extends StatelessWidget {
  final String userId;
  
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // When this button is pressed, navigate to the SearchScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SearchScreen(userId: userId)),
              );
            },
          ),
        ],
      ),
      body: CatalogList(userId: userId), // Existing body
    );
  }
}
