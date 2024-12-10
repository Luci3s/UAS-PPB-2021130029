import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipe.imageUrl.isNotEmpty
                ? Image.network(
                    recipe.imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 100, color: Colors.red);
                    },
                  )
                : Container(
                    height: 100,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
            const SizedBox(height: 10),
            Text(
              'Difficulty: ${recipe.difficulty}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text('Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...recipe.ingredients.map((ingredient) => Text('- $ingredient')),
                        const SizedBox(height: 10),
            const Text('Steps:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...recipe.steps.map((step) => Text('- $step')),
            const SizedBox(height: 10),
            if (recipe.videoUrl.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  // Navigate to the video page or play video logic here
                },
                child: const Text('Watch Video'),
              ),
          ],
        ),
      ),
    );
  }
}
