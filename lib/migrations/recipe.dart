// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uas_ppb_2021130029/models/recipe.dart';

// Future<void> seedRecipesToFirestore(List<Recipe> recipes) async {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   for (Recipe recipe in recipes) {
//     try {
//       await firestore.collection('recipes').add(recipe.toMap());
//       // ignore: avoid_print
//       print('Recipe ${recipe.name} added successfully.');
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error adding recipe ${recipe.name}: $e');
//     }
//   }
// }
