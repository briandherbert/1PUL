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
      'ai_desc': aiDesc,
      'human_desc': humanDesc,
      'date': date,
      'location': location,
      'image': image,
      'quantity': quantity,
    };
  }

  static InventoryItem fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      itemId: map['item_id'],
      aiDesc: map['ai_desc'],
      humanDesc: map['human_desc'],
      date: map['date'],
      location: map['location'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }
}
