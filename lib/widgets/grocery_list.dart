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
  bool _isLoading = true;
  String? _error;

  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final firebaseUri = dotenv.env['FIREBASE_URL'] as String;
    final firebaseJson = dotenv.env['FIREBASE_JSON'] as String;
    final url = Uri.https(firebaseUri, "$firebaseJson.json");

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data';
        });
      }
      if (response.body == 'null') {
        //depende da resposta do backend para um body sem dados, firebase retorna uma string com o texto null
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItemList = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        loadedItemList.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category),
        );
      }
      setState(() {
        _groceryItems = loadedItemList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
          _error = 'Something went wrong';
        });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
    // _loadItems();
  }

  void _removeItem(item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final firebaseUri = dotenv.env['FIREBASE_URL'] as String;
    final firebaseJson = dotenv.env['FIREBASE_JSON'] as String;
    final url = Uri.https(firebaseUri, "$firebaseJson/${item.id}.json");
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  Widget itemList() {
    if (_error != null) {
      return Center(
        child: Text(_error!),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
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
    return const Center(
      child: Text('No item added yet, try to add some...'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = Text('No item added yet, try to add some...');

    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    // if (_groceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //     itemCount: _groceryItems.length,
    //     itemBuilder: (ctx, index) => Dismissible(
    //       onDismissed: (direction) {
    //         _removeItem(_groceryItems[index]);
    //       },
    //       key: ValueKey(_groceryItems[index].id),
    //       child: ListTile(
    //         title: Text(_groceryItems[index].name),
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //           color: _groceryItems[index].category.color,
    //         ),
    //         trailing: Text(
    //           _groceryItems[index].quantity.toString(),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // if (_error != null) {
    //   content = Center(
    //     child: Text(_error!),
    //   );
    // }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
        ),
        body: itemList() //ListView.builder(
        );
  }
}
