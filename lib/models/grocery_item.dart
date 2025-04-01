class GroceryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool purchased;
  final DateTime? purchasedAt;
  final DateTime? deletedAt;
  final double price;

  // Constructor
  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.purchased = false,
    this.purchasedAt,
    this.deletedAt,
    this.price = 0.0, // Default price value
  });

  // copyWith method to create a copy of the GroceryItem with optional changes
  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    bool? purchased,
    DateTime? purchasedAt,
    DateTime? deletedAt,
    double? price,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchased: purchased ?? this.purchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      price: price ?? this.price,
    );
  }

  // Method to mark the item as purchased
  GroceryItem markAsPurchased() {
    return GroceryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      purchased: true,
      purchasedAt: DateTime.now(),
      deletedAt: deletedAt,
      price: price,
    );
  }

  // Method to delete the item by marking the deletedAt timestamp
  GroceryItem deleteItem() {
    return GroceryItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      purchased: purchased,
      purchasedAt: purchasedAt,
      deletedAt: DateTime.now(),
      price: price,
    );
  }
}