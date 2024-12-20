// ignore_for_file: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data'; // Menambahkan impor untuk Uint8List
import '../models/recipe.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// **Metode Login**
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw 'Login failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred during login.';
    }
  }

  /// **Metode Register**
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw 'Registration failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred during registration.';
    }
  }

  /// **Menyimpan Resep**
  Future<void> addRecipe(Recipe recipe) async {
    try {
      // Cek data yang akan disimpan
      final recipeData = recipe.toMap();

      if (kDebugMode) {
        print('Menyimpan resep dengan data: $recipeData');
      }

      // Simpan ke Firestore
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

  /// **Mengambil Daftar Resep**
  Future<List<Recipe>> getRecipes() async {
    try {
      final snapshot = await _firestore.collection('recipes').get();
      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('Tidak ada resep yang ditemukan.');
        }
        return [];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error mendapatkan resep: $e');
      }
      throw Exception('Gagal mengambil data resep');
    }
  }

  /// **Mengunggah Gambar**
  Future<String> uploadImage(dynamic image) async {
    try {
      // Pastikan nama file yang unik
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';
      TaskSnapshot snapshot;

      // Periksa platform
      if (kIsWeb && image is Uint8List) {
        // Untuk aplikasi web
        snapshot = await _storage.ref(fileName).putData(image);
      } else if (image is File) {
        // Untuk aplikasi mobile
        snapshot = await _storage.ref(fileName).putFile(image);
      } else {
        throw 'Unsupported image type.';
      }

      // Mendapatkan URL download
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload image: $e');
      }
      throw Exception('Gagal mengunggah gambar');
    }
  }
}
