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

  String _selectedDifficulty = 'unknown'; // Default difficulty

  Future<void> _pickThumbnailImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addRecipe() async {
    if (_nameController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _stepsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua bidang!')));
      return;
    }

    List<String> ingredients = _ingredientsController.text.split(',');
    List<String> steps = _stepsController.text.split(',');

    String imageUrl = '';
    if (_thumbnailImage != null) {
      imageUrl = await _firebaseService.uploadImage(_thumbnailImage!);
    }

    Recipe newRecipe = Recipe(
      id: '',
      name: _nameController.text,
      difficulty: _selectedDifficulty,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl,
      videoUrl: _videoUrlController.text,
    );

    try {
      await _firebaseService.addRecipe(newRecipe.toMap());
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Detail Resep',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Resep',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Tingkat Kesulitan',
                border: OutlineInputBorder(),
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Bahan-Bahan (pisahkan dengan koma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stepsController,
              decoration: const InputDecoration(
                labelText: 'Langkah-Langkah (pisahkan dengan koma)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_thumbnailImage != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Image.file(
                      _thumbnailImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _pickThumbnailImage,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.image),
                      SizedBox(width: 8),
                      Text('Pilih Gambar'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Video Tutorial (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRecipe,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Simpan Resep'),
            ),
          ],
        ),
      ),
    );
  }
}
