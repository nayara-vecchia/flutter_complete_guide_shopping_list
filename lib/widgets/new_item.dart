import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide_shopping_app/widgets/grocery_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_complete_guide_shopping_app/data/categories.dart';
import 'package:flutter_complete_guide_shopping_app/models/category.dart';
import 'package:flutter_complete_guide_shopping_app/models/item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  bool isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSending = true;
      });
      // final url = Uri.https('flutter-course-7c872-default-rtdb.firebaseio.com',
      //     'shopping-list.json');
      final firebaseUri = dotenv.env['FIREBASE_URL'] as String;
      final firebaseJson = dotenv.env['FIREBASE_JSON'] as String;
      final url = Uri.https(firebaseUri, "$firebaseJson.json");

      try {
        final response = await http.post(
          url,
          headers: {'Content-type': 'application/json'},
          body: json.encode(
            {
              "name": _enteredName,
              "quantity": _enteredQuantity,
              "category": _selectedCategory.title,
            },
          ),
        );

        // if (!widget.mounted) {
        //   return;
        // }

        final responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(
          GroceryItem(
              id: responseData['name'],
              name: _enteredName,
              quantity: _enteredQuantity,
              category: _selectedCategory),
        );
      } catch (e) {
        print('erro');
        print(e.runtimeType);
        setState(() {
          isSending = false;
        });
        throw e.toString();
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length == 1 ||
                      value.trim().length > 50) {
                    return 'Insert a valid item name';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
              ), //no lugar do textField()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Insert a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(category.value.title),
                            ]),
                          )
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSending ? null : _resetForm,
                    child: Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : _saveItem,
                    child: isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text('Add item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
