import 'package:flutter/material.dart';
import 'package:uas_ppb_2021130029/services/firebase_service.dart';
import '../models/recipe.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
  String _selectedDifficulty = 'unknown';

  Future<void> _pickThumbnailImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _thumbnailImage = File(pickedFile.path);
        });
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar tidak dipilih.')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
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
        const SnackBar(content: Text('Harap isi semua bidang!')),
      );
      return;
    }

    List<String> ingredients = _ingredientsController.text.split(',');
    List<String> steps = _stepsController.text.split(',');

    String imageUrl = '';
    if (_thumbnailImage != null) {
      try {
        imageUrl = await _firebaseService.uploadImage(_thumbnailImage!);
      } catch (e) {
        // ignore: use_build_context_synchronously
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
      await _firebaseService.addRecipe(newRecipe.toMap());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
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
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: Colors.deepOrange,
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
                  label: 'Bahan-Bahan (pisahkan dengan koma)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _stepsController,
                  label: 'Langkah-Langkah (pisahkan dengan koma)',
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _videoUrlController,
                  label: 'URL Video Tutorial (opsional)',
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addRecipe,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Resep'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: 'Masukkan $label',
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDifficulty,
      decoration: InputDecoration(
        labelText: 'Tingkat Kesulitan',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: ['unknown', 'easy', 'medium', 'hard']
          .map((difficulty) => DropdownMenuItem(
                value: difficulty,
                child: Text(difficulty),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedDifficulty = value!;
        });
      },
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thumbnail Resep:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickThumbnailImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _thumbnailImage != null
                ? Image.file(_thumbnailImage!, fit: BoxFit.cover)
                : const Center(
                    child: Text('Pilih Gambar'),
                  ),
          ),
        ),
      ],
    );
  }
}
