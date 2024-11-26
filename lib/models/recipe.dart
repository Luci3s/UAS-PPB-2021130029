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

  // Convert Recipe object to a Map
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

  // Create Recipe object from a Map
  static Recipe fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      name: map['name'] ?? 'Unknown',
      difficulty: map['difficulty'] ?? 'Unknown',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
    );
  }
}
