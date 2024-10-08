import 'package:flutter_camera/globals.dart';
import 'package:flutter_camera/model/photo_item.dart';

class InventoryItem {
  final String itemId;
  final String aiDesc;
  final String humanDesc;
  final String date;
  final String location;
  late String image;
  final int quantity;

  InventoryItem({
    required this.itemId,
    required this.aiDesc,
    required this.humanDesc,
    required this.date,
    required this.location,
    required this.image,
    required this.quantity,
  }) {
    if (this.image.isEmpty) {
      this.image = getGcsImageUrl(inventoryItemId: itemId)!;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'ai_description': aiDesc,
      'human_description': humanDesc,
      'date': date,
      'location': location,
      'image': image,
      'quantity': quantity,
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemId: map['item_id'],
      aiDesc: map['ai_description'],
      humanDesc: map['human_description'],
      date: map['date'],
      location: map['location'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }

  static fromPhotoItem(PhotoItem pi) {
    print('convert photo item with url ${pi.gcsUrl}');
    return InventoryItem(
      itemId: pi.formattedTimestamp,
      aiDesc: pi.geminiDesc ?? "none",
      humanDesc: pi.humanDesc ?? "none",
      date: pi.formattedTimestamp,
      location: pi.location,
      image: '=Image("${pi.gcsUrl}")',
      quantity: 1,
    );
  }

  // Equality check based on itemId
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InventoryItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;
}
