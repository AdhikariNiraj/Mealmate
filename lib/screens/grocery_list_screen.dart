import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_list_model.dart';
import '../providers/grocery_provider.dart';
import '../widgets/grocery_item_tile.dart';
import '../widgets/custom_button.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  String? _editingListId;
  GroceryList? _groceryList;
  List<GroceryItem> _items = [];
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listId = ModalRoute.of(context)?.settings.arguments as String?;
      if (listId != null && listId != 'new') {
        _editingListId = listId;
        _loadGroceryList(listId);
      }
    });
  }

  Future<void> _loadGroceryList(String listId) async {
    setState(() => _isLoading = true);
    try {
      final groceryProvider = Provider.of<GroceryProvider>(context, listen: false);
      _groceryList = await groceryProvider.getGroceryList(listId);
      if (_groceryList != null) {
        _nameController.text = _groceryList!.name;
        _storeController.text = _groceryList!.store ?? '';
        _notesController.text = _groceryList!.notes ?? '';
        _items = _groceryList!.items;
        _calculateTotalCost();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading grocery list: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateTotalCost() {
    _totalCost = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> _saveGroceryList() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a list name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final groceryProvider = Provider.of<GroceryProvider>(context, listen: false);
      final listId = _editingListId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final groceryList = GroceryList(
        id: listId,
        name: _nameController.text,
        store: _storeController.text,
        notes: _notesController.text,
        items: _items,
        recipes: [],
        createdAt: _groceryList?.createdAt ?? DateTime.now(),
      );

      print('Saving Grocery List:');
      print('ID: ${groceryList.id}');
      print('Name: ${groceryList.name}');
      print('Store: ${groceryList.store}');
      print('Notes: ${groceryList.notes}');
      print('Items: ${_items.map((item) => "${item.name} (${item.quantity} ${item.unit}, Price: ${item.price})").toList()}');

      if (_editingListId != null) {
        print('Updating existing list...');
        await groceryProvider.updateGroceryList(groceryList);
        print('Update completed');
      } else {
        print('Adding new list...');
        await groceryProvider.addGroceryList(groceryList);
        print('Add completed');
      }

      if (mounted) {
        Navigator.pop(context, true); // Signal that a save occurred
      }
    } catch (e) {
      print('Error in _saveGroceryList: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving grocery list: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shareGroceryList() {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Grocery List: ${_nameController.text}');
    buffer.writeln('🏪 Store: ${_storeController.text}');
    buffer.writeln('💰 Estimated Total: ₹${_totalCost.toStringAsFixed(2)}');
    buffer.writeln('\n📌 Items:');
    for (final item in _items) {
      buffer.writeln('- ${item.name}: ${item.quantity} ${item.unit} @ ₹${item.price.toStringAsFixed(2)}');
    }
    buffer.writeln('\n📝 Notes: ${_notesController.text}');
    Share.share(buffer.toString(), subject: 'Grocery List');
  }

  Future<void> _addItem() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, lbs)'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category (e.g., Fruit)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                final quantity = double.tryParse(quantityController.text) ?? 0.0;
                final unit = unitController.text;
                final category = categoryController.text;

                if (name.isNotEmpty && price >= 0 && quantity > 0 && unit.isNotEmpty && category.isNotEmpty) {
                  setState(() {
                    _items.add(GroceryItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      price: price,
                      quantity: quantity,
                      unit: unit,
                      category: category,
                    ));
                    _calculateTotalCost();
                  });
                  print('Added item: $name, Total items: ${_items.length}');
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingListId == null ? 'Create Grocery List' : 'Edit Grocery List'),
        actions: [
          if (_editingListId != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareGroceryList,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              '🛍️ Items',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Center(child: Text('No items yet'))
            else
              ..._items.map((item) => GroceryItemTile(
                item: item,
                onPurchased: (bool purchased) {
                  setState(() {
                    int index = _items.indexWhere((i) => i.id == item.id);
                    if (index != -1) {
                      _items[index] = _items[index].copyWith(purchased: purchased);
                    }
                  });
                },
                onDelete: () {
                  setState(() {
                    _items.remove(item);
                  });
                },
              )),
            const SizedBox(height: 16),
            Text(
              '💰 Estimated Total: ₹${_totalCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Save List',
              isLoading: _isLoading,
              onPressed: _saveGroceryList,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Item',
              isLoading: false,
              onPressed: _addItem,
            ),
          ],
        ),
      ),
    );
  }
}