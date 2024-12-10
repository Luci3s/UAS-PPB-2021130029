// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/recipe.dart';

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

  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    try {
      // Cek apakah data yang diterima valid
      if (kDebugMode) {
        print('Menyimpan resep dengan data: $recipeData');
      }
      
      // Menyimpan resep ke Firestore
      await _firestore.collection('recipes').add(recipeData);
      if (kDebugMode) {
        print('Resep berhasil disimpan!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error menyimpan resep: $e');
      }
      throw Exception('Gagal menambahkan resep');
    }
  }

  // Mengunggah gambar ke Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    if (!imageFile.existsSync()) {
      throw 'Image file does not exist.';
    }
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  Future<List<Recipe>> getRecipes() async {
  final snapshot = await _firestore.collection('recipes').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Recipe.fromMap(doc.id, data); // Perbaiki argumen
  }).toList();
}

}