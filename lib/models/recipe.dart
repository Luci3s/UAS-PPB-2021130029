class Recipe {
  final String id;
  final String name;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String videoUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.videoUrl,
  });

  // fromMap yang benar
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      name: data['name'] ?? '',
      difficulty: data['difficulty'] ?? 'unknown',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }

  // Metode toMap untuk mengonversi Recipe ke Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}
