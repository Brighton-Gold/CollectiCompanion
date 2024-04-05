import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'display_catalog_contents.dart';
import 'display_item.dart';

enum SearchFilter { items, catalogs, both }

class SearchScreen extends StatefulWidget {
  final String userId;

  const SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  SearchFilter _searchFilter = SearchFilter.both;

  void _searchCatalogsAndItems(String query) async {
    String lowerCaseQuery = query.toLowerCase();

    if (lowerCaseQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<DocumentSnapshot> catalogResults = [];
    List<DocumentSnapshot> itemResults = [];

    if (_searchFilter == SearchFilter.catalogs ||
        _searchFilter == SearchFilter.both) {
      // Search in catalogs
      var catalogSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('catalogList')
          .get();
      catalogResults = catalogSnapshot.docs.where((doc) {
        var catalogName = doc['catalogName'] as String;
        return catalogName.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    if (_searchFilter == SearchFilter.items ||
        _searchFilter == SearchFilter.both) {
      // Search in items
      var itemSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('itemList')
          .get();
      itemResults = itemSnapshot.docs.where((doc) {
        var itemName = doc['itemName'] as String;
        return itemName.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    setState(() {
      _searchResults = [...catalogResults, ...itemResults];
    });
  }

  void _handleSearchFilterChange(SearchFilter? newValue) {
    setState(() {
      _searchFilter = newValue!;
    });
    // Perform the search with the current input and new filter
    _searchCatalogsAndItems(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Catalogs and Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<SearchFilter>(
                  value: _searchFilter,
                  onChanged: _handleSearchFilterChange,
                  items: <SearchFilter>[
                    SearchFilter.items,
                    SearchFilter.catalogs,
                    SearchFilter.both
                  ].map<DropdownMenuItem<SearchFilter>>((SearchFilter value) {
                    return DropdownMenuItem<SearchFilter>(
                      value: value,
                      child: Text(value.toString().split('.').last),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (query) {
                    _searchCatalogsAndItems(query);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                var data = _searchResults[index].data() as Map<String, dynamic>;
                bool isCatalog = data.containsKey('catalogName');

                return ListTile(
                  title:
                      Text(isCatalog ? data['catalogName'] : data['itemName']),
                  subtitle:
                      Text(data['description'] ?? 'No description available'),
                  onTap: () {
                    // Handle tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
