class MenuItem {
  final int? id;
  final String itemCode;
  final String itemName;
  final int price;
  final bool isActive;

  const MenuItem({
    this.id,
    required this.itemCode,
    required this.itemName,
    required this.price,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_code': itemCode,
      'item_name': itemName,
      'price': price,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as int?,
      itemCode: map['item_code'] as String,
      itemName: map['item_name'] as String,
      price: map['price'] as int,
      isActive: (map['is_active'] as int) == 1,
    );
  }
}
