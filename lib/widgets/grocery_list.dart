import 'package:flutter/material.dart';

import 'package:flutter_complete_guide_shopping_app/models/item.dart';
import 'package:flutter_complete_guide_shopping_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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
