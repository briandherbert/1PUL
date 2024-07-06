import 'dart:convert';
import 'package:flutter_camera/model/inventory_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsInventory {
  late GSheets _gsheets;
  Worksheet? _worksheet;

  GoogleSheetsInventory() {
    _gsheets = GSheets(_decodeCredentials(dotenv.env['SERVICE_ACCT_CREDS']!));
  }

  static Map<String, dynamic> _decodeCredentials(String base64Credentials) {
    final decoded = utf8.decode(base64.decode(base64Credentials));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<void> init() async {
    final ss = await _gsheets.spreadsheet(dotenv.env['GSHEET_ID']!);
    _worksheet = ss.worksheetByTitle('inventory');
  }

  Future<List<InventoryItem>> readItems() async {
    if (_worksheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final rows = await _worksheet!.values.map.allRows();
    if (rows == null) return [];

    return rows.map((row) {
      return InventoryItem(
        itemId: row['item_id'] ?? '',
        aiDesc: row['ai_desc'] ?? '',
        humanDesc: row['human_desc'] ?? '',
        date: row['date'] ?? '',
        location: row['location'] ?? '',
        image: row['image'] ?? '',
        quantity: int.tryParse(row['quantity'] ?? '0') ?? 0,
      );
    }).toList();
  }

  Future<void> addItem(InventoryItem item) async {
    if (_worksheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    await _worksheet!.values.appendRow(item.toMap().values.toList());
  }

  Future<void> updateItem(String itemId, InventoryItem newItem) async {
    if (_worksheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final rows = await _worksheet!.values.map.allRows();
    if (rows != null) {
      for (var i = 0; i < rows.length; i++) {
        if (rows[i]['item_id'] == itemId) {
          await _worksheet!.values
              .insertRow(i + 1, newItem.toMap().values.toList());
          return;
        }
      }
    }
    throw Exception("Item with id $itemId not found.");
  }
}
