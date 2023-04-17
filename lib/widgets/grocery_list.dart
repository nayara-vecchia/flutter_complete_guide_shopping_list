import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_complete_guide_shopping_app/data/categories.dart';
import 'package:flutter_complete_guide_shopping_app/models/item.dart';
import 'package:flutter_complete_guide_shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final firebaseUri = dotenv.env['FIREBASE_URL'] as String;
    final firebaseJson = dotenv.env['FIREBASE_JSON'] as String;
    final url = Uri.https(firebaseUri, firebaseJson);
    final response = await http.get(url);


    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItemList = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;
      _loadedItemList.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category),
      );
    }
    setState(() {
      _groceryItems = _loadedItemList;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    _loadItems();
  }

  void _removeItem(item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  Widget itemList() {
    return ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) => Dismissible(
        onDismissed: (direction) {
          _removeItem(_groceryItems[index]);
        },
        key: ValueKey(_groceryItems[index].id),
        child: ListTile(
          title: Text(_groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: _groceryItems[index].category.color,
          ),
          trailing: Text(
            _groceryItems[index].quantity.toString(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
        ),
        body: _groceryItems.isEmpty
            ? const Center(
                child: Text('No item added yet, try to add some...'),
              )
            : itemList() //ListView.builder(
        );
  }
}
