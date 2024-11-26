import 'package:uas_ppb_2021130029/models/recipe.dart';

List<Recipe> sampleRecipes = [
  Recipe(
    id: 'recipe1',
    name: 'Pasta Carbonara',
    difficulty: 'Medium',
    ingredients: ['Pasta', 'Eggs', 'Cheese', 'Pancetta', 'Black Pepper'],
    steps: [
      'Boil pasta',
      'Cook pancetta',
      'Mix eggs and cheese',
      'Combine and serve'
    ],
    imageUrl: 'https://placehold.co/600x400',
    videoUrl: 'https://placehold.co/600x400',
  ),
  Recipe(
    id: 'recipe2',
    name: 'Chocolate Cake',
    difficulty: 'Hard',
    ingredients: [
      'Flour',
      'Cocoa powder',
      'Eggs',
      'Sugar',
      'Butter',
      'Baking powder'
    ],
    steps: [
      'Mix dry ingredients',
      'Add wet ingredients',
      'Bake in oven',
      'Let cool and serve'
    ],
    imageUrl: 'https://placehold.co/600x400',
    videoUrl: 'https://placehold.co/600x400',
  ),
  // Add more sample recipes as needed
];
