class StockItem {
  String? id;
  String name;
  int quantity;
  String? description;

  StockItem({
    this.id,
    required this.name,
    required this.quantity,
    this.description,
  });

  factory StockItem.fromMap(String id, Map<String, dynamic> map) {
    return StockItem(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'description': description,
    };
  }
}
