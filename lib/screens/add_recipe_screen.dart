import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/recipe.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'recipe_list_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  final String username;

  const AddRecipeScreen({super.key, required this.username});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  File? _thumbnailImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _dropdownItems = ['easy', 'medium', 'hard'];
  String _selectedDifficulty = 'easy';
  bool _isLoading = false;

  Future<void> _pickThumbnailImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _thumbnailImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada gambar yang dipilih.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _addRecipe() async {
    if (_nameController.text.trim().isEmpty ||
        _ingredientsController.text.trim().isEmpty ||
        _stepsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua bidang yang wajib!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Memisahkan bahan dan langkah
    List<String> ingredients = _ingredientsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> steps = _stepsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    String imageUrl = '';
    if (_thumbnailImage != null) {
      try {
        imageUrl = await _firebaseService.uploadImage(_thumbnailImage!);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
        return;
      }
    }

    Recipe newRecipe = Recipe(
      id: '',
      name: _nameController.text.trim(),
      difficulty: _selectedDifficulty,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl,
      videoUrl: _videoUrlController.text.trim(),
    );

    try {
      await _firebaseService.addRecipe(newRecipe);
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeListScreen(username: widget.username),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil ditambahkan!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan resep: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tambah Resep Baru'),
        backgroundColor: const Color.fromARGB(255, 0, 213, 255),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masukkan Detail Resep',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 34, 255, 200),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Nama Resep',
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _ingredientsController,
                        label: 'Bahan-bahan (pisahkan dengan koma)',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _stepsController,
                        label: 'Langkah-langkah (pisahkan dengan koma)',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _videoUrlController,
                        label: 'URL Video (opsional)',
                      ),
                      const SizedBox(height: 16),
                      _buildThumbnailPicker(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 183, 248),
                        ),
                        child: const Text('Tambahkan Resep'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      items: _dropdownItems.map((difficulty) {
        return DropdownMenuItem(
          value: difficulty,
          child: Text(difficulty.capitalize()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDifficulty = value!;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Tingkat Kesulitan',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildThumbnailPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thumbnail Gambar (opsional)'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickThumbnailImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: _thumbnailImage != null
                  ? DecorationImage(
                      image: FileImage(_thumbnailImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _thumbnailImage == null
                ? const Center(child: Text('Pilih Gambar'))
                : null,
          ),
        ),
      ],
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }
}
