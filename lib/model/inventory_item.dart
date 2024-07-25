class InventoryItem {
  final String itemId;
  final String aiDesc;
  final String humanDesc;
  final String date;
  final String location;
  final String image;
  final int quantity;

  InventoryItem({
    required this.itemId,
    required this.aiDesc,
    required this.humanDesc,
    required this.date,
    required this.location,
    required this.image,
    required this.quantity,
  });

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
}
