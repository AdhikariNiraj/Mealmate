import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_list_model.dart';
import '../models/recipe_model.dart';

class GroceryProvider with ChangeNotifier {
  // Reference to Firestore collection
  final CollectionReference _groceryListsRef = FirebaseFirestore.instance.collection('groceryLists');
  final List<GroceryItem> _purchasedItems = [];
  final List<GroceryItem> _deletedItems = [];
  List<GroceryList> _groceryLists = [];
  final Map<String, List<GroceryItem>> _categorizedItems = {
    'Vegetables': [],
    'Proteins': [],
    'Grains': [],
  };

  // Getters
  List<GroceryList> get groceryLists => _groceryLists;
  Map<String, List<GroceryItem>> get categorizedItems => _categorizedItems;
  List<GroceryItem> get purchasedItems => _purchasedItems;
  List<GroceryItem> get deletedItems => _deletedItems;

  /// Fetches grocery lists from Firestore and sorts them by creation date in descending order.
  Future<void> fetchGroceryLists() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Fetch all documents from the user's subcollection
      final snapshot = await _groceryListsRef.doc(userId).collection('userLists').get();
      _groceryLists = snapshot.docs.map((doc) {
        final data = doc.data();
        return GroceryList(
          id: doc.id,
          name: data['name'] as String,
          items: (data['items'] as List<dynamic>? ?? []).map((item) {
            final itemData = item as Map<String, dynamic>;
            return GroceryItem(
              id: itemData['id'] as String,
              name: itemData['name'] as String,
              category: itemData['category'] as String,
              quantity: (itemData['quantity'] as num).toDouble(),
              unit: itemData['unit'] as String,
              purchased: itemData['purchased'] as bool? ?? false,
              purchasedAt: (itemData['purchasedAt'] as Timestamp?)?.toDate(),
              deletedAt: (itemData['deletedAt'] as Timestamp?)?.toDate(),
              price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList(),
          recipes: (data['recipes'] as List<dynamic>? ?? [])
              .map((recipe) => Recipe.fromMap(recipe as Map<String, dynamic>))
              .toList(),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          store: data['store'] as String?,
          notes: data['notes'] as String?,
        );
      }).toList();

      // Sort lists by createdAt in descending order (most recent first)
      _groceryLists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      print('Error fetching grocery lists: $e');
      throw Exception('Failed to fetch grocery lists: $e');
    }
  }

  /// Retrieves a specific grocery list by ID from Firestore.
  Future<GroceryList> getGroceryList(String id) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final docSnapshot = await _groceryListsRef.doc(userId).collection('userLists').doc(id).get();
      if (!docSnapshot.exists) throw Exception('Grocery list not found');
      final data = docSnapshot.data()!;
      return GroceryList(
        id: docSnapshot.id,
        name: data['name'] as String,
        items: (data['items'] as List<dynamic>? ?? []).map((item) {
          final itemData = item as Map<String, dynamic>;
          return GroceryItem(
            id: itemData['id'] as String,
            name: itemData['name'] as String,
            category: itemData['category'] as String,
            quantity: (itemData['quantity'] as num).toDouble(),
            unit: itemData['unit'] as String,
            purchased: itemData['purchased'] as bool? ?? false,
            purchasedAt: (itemData['purchasedAt'] as Timestamp?)?.toDate(),
            deletedAt: (itemData['deletedAt'] as Timestamp?)?.toDate(),
            price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList(),
        recipes: (data['recipes'] as List<dynamic>? ?? [])
            .map((recipe) => Recipe.fromMap(recipe as Map<String, dynamic>))
            .toList(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        store: data['store'] as String?,
        notes: data['notes'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to get grocery list: $e');
    }
  }

  /// Adds a new grocery list to Firestore and refreshes the local list.
  Future<void> addGroceryList(GroceryList list) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final userGroceryListRef = _groceryListsRef.doc(userId).collection('userLists').doc(list.id);
      await userGroceryListRef.set({
        'name': list.name,
        'items': list.items.map((item) => {
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
          'unit': item.unit,
          'purchased': item.purchased,
          'purchasedAt': item.purchasedAt != null ? Timestamp.fromDate(item.purchasedAt!) : null,
          'deletedAt': item.deletedAt != null ? Timestamp.fromDate(item.deletedAt!) : null,
          'price': item.price,
        }).toList(),
        'recipes': list.recipes.map((recipe) => recipe.toMap()).toList(),
        'createdAt': Timestamp.fromDate(list.createdAt),
        'store': list.store,
        'notes': list.notes,
      }).then((_) {
        print('Grocery list saved to Firestore: ${list.id}');
      });
      await fetchGroceryLists(); // Sync local list with Firestore
    } catch (e) {
      print('Error in addGroceryList: $e');
      throw Exception('Failed to add grocery list: $e');
    }
  }

  /// Updates an existing grocery list in Firestore and the local list.
  Future<void> updateGroceryList(GroceryList list) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final userGroceryListRef = _groceryListsRef.doc(userId).collection('userLists').doc(list.id);
      await userGroceryListRef.update({
        'name': list.name,
        'items': list.items.map((item) => {
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'quantity': item.quantity,
          'unit': item.unit,
          'purchased': item.purchased,
          'purchasedAt': item.purchasedAt != null ? Timestamp.fromDate(item.purchasedAt!) : null,
          'deletedAt': item.deletedAt != null ? Timestamp.fromDate(item.deletedAt!) : null,
          'price': item.price,
        }).toList(),
        'recipes': list.recipes.map((recipe) => recipe.toMap()).toList(),
        'createdAt': Timestamp.fromDate(list.createdAt),
        'store': list.store,
        'notes': list.notes,
      }).then((_) {
        print('Grocery list updated in Firestore: ${list.id}');
      });
      final index = _groceryLists.indexWhere((l) => l.id == list.id);
      if (index != -1) {
        _groceryLists[index] = list;
        notifyListeners();
      }
    } catch (e) {
      print('Error in updateGroceryList: $e');
      throw Exception('Failed to update grocery list: $e');
    }
  }

  /// Deletes a grocery list from Firestore and the local list.
  Future<void> deleteGroceryList(String id) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _groceryListsRef.doc(userId).collection('userLists').doc(id).delete();
      _groceryLists.removeWhere((list) => list.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete grocery list: $e');
    }
  }

  /// Compiles ingredients from recipes into categorized lists.
  void compileIngredientsFromRecipes(List<Recipe> recipes) {
    _categorizedItems.clear();
    _categorizedItems['Vegetables'] = [];
    _categorizedItems['Proteins'] = [];
    _categorizedItems['Grains'] = [];
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final groceryItem = GroceryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: ingredient.name,
          category: ingredient.category,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
        );
        if (ingredient.category.toLowerCase() == 'vegetables' ||
            ingredient.name.toLowerCase().contains('carrot') ||
            ingredient.name.toLowerCase().contains('broccoli')) {
          _categorizedItems['Vegetables']!.add(groceryItem);
        } else if (ingredient.category.toLowerCase() == 'proteins' ||
            ingredient.name.toLowerCase().contains('chicken') ||
            ingredient.name.toLowerCase().contains('beef')) {
          _categorizedItems['Proteins']!.add(groceryItem);
        } else if (ingredient.category.toLowerCase() == 'grains' ||
            ingredient.name.toLowerCase().contains('rice') ||
            ingredient.name.toLowerCase().contains('pasta')) {
          _categorizedItems['Grains']!.add(groceryItem);
        } else {
          _categorizedItems['Vegetables']!.add(groceryItem);
        }
      }
    }
    notifyListeners();
  }

  /// Clears purchased and deleted items.
  void clearPurchasedAndDeletedItems() {
    _purchasedItems.clear();
    _deletedItems.clear();
    notifyListeners();
  }

  /// Adds an item to the purchased list.
  void addPurchasedItem(GroceryItem item) {
    _purchasedItems.add(item.copyWith(
      purchasedAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Adds an item to the deleted list.
  void addDeletedItem(GroceryItem item) {
    _deletedItems.add(item.copyWith(
      deletedAt: DateTime.now(),
    ));
    notifyListeners();
  }
}