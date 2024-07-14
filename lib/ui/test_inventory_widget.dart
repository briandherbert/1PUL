import 'package:flutter/material.dart';
import 'package:flutter_camera/api/google_auth.dart';
import 'package:flutter_camera/api/gsheets_inventory.dart';
import 'package:flutter_camera/model/inventory_item.dart';

import 'package:googleapis/drive/v3.dart' as drive;

class TestInventoryWidget extends StatefulWidget {
  const TestInventoryWidget({
    super.key,
  });

  @override
  _TestInventoryWidgetState createState() => _TestInventoryWidgetState();
}

class _TestInventoryWidgetState extends State<TestInventoryWidget> {
  late GoogleSheetsInventory _inventory;
  List<InventoryItem> _items = [];
  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _aiDescController = TextEditingController();
  final _humanDescController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inventory = GoogleSheetsInventory();
    _initializeSheet();
  }

  Future<void> _initializeSheet() async {
    await _inventory.init();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final items = await _inventory.readItems();
    setState(() {
      _items = items;
    });
  }

  Future<drive.File?> createSpreadsheet() async {
    final client = await getAuthenticatedHttpClient();
    if (client == null) {
      print("Failed to get authenticated client.");
      return null;
    }

    final driveApi = drive.DriveApi(client);
    final newFile = drive.File();
    newFile.name = "Test Organizer App";
    newFile.mimeType = "application/vnd.google-apps.spreadsheet";

    try {
      final createdFile = await driveApi.files.create(newFile);
      print('made file ${createdFile} with id ${createdFile.driveId}');
      return createdFile;
    } catch (e) {
      print("Error creating spreadsheet: $e");
      return null;
    }
  }

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryItem(
        itemId: _itemIdController.text,
        aiDesc: _aiDescController.text,
        humanDesc: _humanDescController.text,
        date: _dateController.text,
        location: _locationController.text,
        image: _imageController.text,
        quantity: int.parse(_quantityController.text),
      );
      await _inventory.addItem(newItem);
      _fetchItems();
      _clearForm();
    }
  }

  void _clearForm() {
    _itemIdController.clear();
    _aiDescController.clear();
    _humanDescController.clear();
    _dateController.clear();
    _locationController.clear();
    _imageController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory System'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _itemIdController,
                    decoration: InputDecoration(labelText: 'Item ID'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item ID';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _aiDescController,
                    decoration: InputDecoration(labelText: 'AI Description'),
                  ),
                  TextFormField(
                    controller: _humanDescController,
                    decoration: InputDecoration(labelText: 'Human Description'),
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'Image URL'),
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _addItem,
                    child: Text('Add Item'),
                  ),
                  ElevatedButton(
                    onPressed: createSpreadsheet,
                    child: Text('Auth w Google'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _items.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text(item.humanDesc),
                          subtitle: Text(
                              'ID: ${item.itemId}, Quantity: ${item.quantity}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _aiDescController.dispose();
    _humanDescController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
