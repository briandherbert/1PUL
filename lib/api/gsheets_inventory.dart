import 'dart:convert';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsInventory {
  late GSheets _gsheets;
  Worksheet? _inventorySheet;
  Worksheet? _locationsSheet;

  GoogleSheetsInventory() {
    _gsheets = GSheets(_decodeCredentials(dotenv.env['SERVICE_ACCT_CREDS']!));
  }

  static Map<String, dynamic> _decodeCredentials(String base64Credentials) {
    final decoded = utf8.decode(base64.decode(base64Credentials));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<void> init() async {
    final ss = await _gsheets.spreadsheet(dotenv.env['GSHEET_ID']!);
    _inventorySheet = ss.worksheetByTitle('inventory');
    _locationsSheet = ss.worksheetByTitle('locations');
  }

  Future<List<String>> getLocations() async {
    if (_inventorySheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final locations = await _locationsSheet!.values.column(1, fromRow: 2);
    print('got location rows ${locations}');
    return locations;
  }  

  Future<List<InventoryItem>> readItems() async {
    if (_inventorySheet == null) {
      throw Exception("Worksheet is not initialized.");
    }

    //await getLocations();
    final rows = await _inventorySheet!.values.map.allRows();
    if (rows == null) return [];

    //print('got sheets rows ${rows}');

    return rows.map((row) {
      return InventoryItem(
        itemId: row['item_id'] ?? '',
        aiDesc: row['ai_description'] ?? '',
        humanDesc: row['human_description'] ?? '',
        date: row['date'] ?? '',
        location: row['location'] ?? '',
        image: row['image'] ?? '',
        quantity: int.tryParse(row['quantity'] ?? '0') ?? 0,
      );
    }).toList();
  }

  Future<void> addItem(InventoryItem item) async {
    if (_inventorySheet == null) {
      throw Exception("Worksheet is not initialized.");
    }

    print('Adding inventory item with ai desc ${item.aiDesc}');
    await _inventorySheet!.values.appendRow(item.toMap().values.toList());
  }

  Future<void> updateItem(String itemId, InventoryItem newItem) async {
    if (_inventorySheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final rows = await _inventorySheet!.values.map.allRows();
    if (rows != null) {
      for (var i = 0; i < rows.length; i++) {
        if (rows[i]['item_id'] == itemId) {
          await _inventorySheet!.values
              .insertRow(i + 1, newItem.toMap().values.toList());
          return;
        }
      }
    }
    throw Exception("Item with id $itemId not found.");
  }
}
