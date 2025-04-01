// lib/models/grocery_list_model.dart
import 'package:mealmateapp/models/recipe_model.dart'; // Import Recipe model

// GroceryList model with recipe support
class GroceryList {
  final String id;
  final String name;
  final List<GroceryItem> items;
  final List<Recipe> recipes; // Added recipes field
  final DateTime createdAt;
  final String? store;  // Added store property
  final String? notes;  // Added notes property

  GroceryList({
    required this.id,
    required this.name,
    required this.items,
    required this.recipes, // Ensure recipes are passed in constructor
    required this.createdAt,
    this.store,  // Optional store
    this.notes,  // Optional notes
  });

  // Method to copy an existing grocery list with changes
  GroceryList copyWith({
    String? id,
    String? name,
    List<GroceryItem>? items,
    List<Recipe>? recipes, // Optional parameter for recipes
    DateTime? createdAt,
    String? store,  // Optional store
    String? notes,  // Optional notes
  }) {
    return GroceryList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      recipes: recipes ?? this.recipes,
      createdAt: createdAt ?? this.createdAt,
      store: store ?? this.store,  // Copy store if provided
      notes: notes ?? this.notes,  // Copy notes if provided
    );
  }
}

// GroceryItem model with additional fields like purchased and deletedAt
class GroceryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool purchased;
  final DateTime? purchasedAt;
  final DateTime? deletedAt;
  final double price; // Added price field

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

  // Method to create a copy of the grocery item with changes
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

  // Method to delete an item (set deletedAt to current date)
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