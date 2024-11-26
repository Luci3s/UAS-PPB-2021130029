// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/recipe.dart'; // Pastikan path ini sudah sesuai dengan lokasi model Recipe Anda

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Metode login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw 'Login failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred during login.';
    }
  }

  // Metode register
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw 'Registration failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred during registration.';
    }
  }

  // Menambahkan resep ke Firestore
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    try {
      await _firestore.collection('recipes').add(recipeData);
    } catch (e) {
      throw 'Failed to add recipe.';
    }
  }

  // Mengunggah gambar ke Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image.';
    }
  }

  // Mendapatkan daftar resep dari Firestore
  Future<List<Recipe>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('recipes').get();
      List<Recipe> recipes = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Recipe.fromMap(doc.id, data);
      }).toList();
      return recipes;
    } catch (e) {
      throw 'Failed to fetch recipes.';
    }
  }
}
