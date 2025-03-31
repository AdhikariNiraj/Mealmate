import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class AnimatedIngredientTile extends StatelessWidget {
  final int index;
  final Ingredient ingredient;

  const AnimatedIngredientTile({
    Key? key,
    required this.index,
    required this.ingredient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${index + 1}'),
      ),
      title: Text(ingredient.name),
      subtitle: Text(
        '${ingredient.quantity} ${ingredient.unit} (${ingredient.category})',
      ),
    );
  }
}
