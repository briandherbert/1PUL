import 'dart:convert';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  final GSheets _gsheets;
  Worksheet? _worksheet;

  GoogleSheetsApi(String base64Credentials)
      : _gsheets = GSheets(_decodeCredentials(base64Credentials));

  static Map<String, dynamic> _decodeCredentials(String base64Credentials) {
    final decoded = utf8.decode(base64.decode(base64Credentials));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<void> init(String spreadsheetId, String worksheetTitle) async {
    final ss = await _gsheets.spreadsheet(spreadsheetId);
    _worksheet = ss.worksheetByTitle(worksheetTitle);
  }

  Future<List<Map<String, dynamic>>> readData() async {
    if (_worksheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final rows = await _worksheet!.values.map.allRows();
    return rows ?? [];
  }

  Future<void> writeData(List<Map<String, dynamic>> data) async {
    if (_worksheet == null) {
      throw Exception("Worksheet is not initialized.");
    }
    final columns = data.first.keys.toList();
    final values = data.map((row) => row.values.toList()).toList();
    
    await _worksheet!.values.insertRow(1, columns);  // Insert headers
    for (var row in values) {
      await _worksheet!.values.appendRow(row);
    }
  }
}
