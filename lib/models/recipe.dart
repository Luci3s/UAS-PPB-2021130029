class Recipe {
  final String id; // ID unik (dari Firebase)
  final String name; // Nama resep
  final String difficulty; // Tingkat kesulitan
  final List<String> ingredients; // Daftar bahan
  final List<String> steps; // Langkah-langkah
  final String imageUrl; // URL gambar (jika ada)
  final String videoUrl; // URL video (jika ada)

  // Konstruktor
  Recipe({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.videoUrl,
  });

  // Factory method untuk membuat objek `Recipe` dari Map (data Firestore)
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    try {
      // Pastikan ingredients dan steps adalah List
      // ignore: prefer_is_not_operator
      if (data['ingredients'] != null && !(data['ingredients'] is List)) {
        throw const FormatException('Ingredients should be a List');
      }
      // ignore: prefer_is_not_operator
      if (data['steps'] != null && !(data['steps'] is List)) {
        throw const FormatException('Steps should be a List');
      }

      return Recipe(
        id: id,
        name: data['name'] ?? '', // Gunakan string kosong sebagai default
        difficulty: data['difficulty'] ?? 'unknown', // Default 'unknown' untuk kesulitan
        ingredients: data['ingredients'] != null
            ? List<String>.from(data['ingredients'] as List<dynamic>)
            : [], // Konversi aman dari List<dynamic> ke List<String>
        steps: data['steps'] != null
            ? List<String>.from(data['steps'] as List<dynamic>)
            : [], // Konversi aman dari List<dynamic> ke List<String>
        imageUrl: data['imageUrl'] ?? '', // Default string kosong
        videoUrl: data['videoUrl'] ?? '', // Default string kosong
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing recipe data: $e');
      rethrow; // Re-throw error agar bisa ditangani di tempat lain
    }
  }

  // Metode untuk mengonversi objek `Recipe` ke Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}
