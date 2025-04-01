import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/grocery_provider.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  _ManageItemsScreenState createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Items'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recipes'),
            Tab(text: 'Grocery Lists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipeList(),
          _buildGroceryList(),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.recipes;

    if (recipes.isEmpty) {
      return const Center(child: Text('No recipes found'));
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return ListTile(
          title: Text(recipe.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, '/recipe_edit',
                      arguments: recipe.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context, 'recipe', recipe.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroceryList() {
    final groceryProvider = Provider.of<GroceryProvider>(context);
    final groceryLists = groceryProvider.groceryLists;

    if (groceryLists.isEmpty) {
      return const Center(child: Text('No grocery lists found'));
    }

    return ListView.builder(
      itemCount: groceryLists.length,
      itemBuilder: (context, index) {
        final list = groceryLists[index];
        return ListTile(
          title: Text(list.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, '/grocery',
                      arguments: list.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(
                      context, 'grocery list', list.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String type, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $type'),
          content: Text('Are you sure you want to delete this $type?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  if (type == 'recipe') {
                    await Provider.of<RecipeProvider>(context, listen: false)
                        .deleteRecipe(id);
                  } else if (type == 'grocery list') {
                    await Provider.of<GroceryProvider>(context, listen: false)
                        .deleteGroceryList(id);
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$type deleted successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete $type: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}