import 'package:flutter/material.dart';
import 'package:uas_ppb_2021130029/services/firebase_service.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';
import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  final String username; // Tambahkan username sebagai parameter

  const RecipeListScreen({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDarkMode = false; // Default light mode
  int _currentIndex = 0; // Default tab index for BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _showWelcomeNotification(); // Tampilkan notifikasi "Selamat Datang"
    _loadRecipes();
  }

  // Notifikasi "Selamat Datang"
  void _showWelcomeNotification() {
    Future.delayed(
      Duration.zero,
      // ignore: use_build_context_synchronously
      () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat Datang, ${widget.username}!'),
          duration: const Duration(seconds: 3),
        ),
      ),
    );
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      _recipes = await _firebaseService.getRecipes();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recipes. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Recipe App - Hello, ${widget.username}!'), // Sapaan di AppBar
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme, // Toggle dark mode
            ),
          ],
        ),
        body: _currentIndex == 0
            ? _buildRecipeList() // Recipe list view
            : const AddRecipeScreen(), // Add recipe view
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Daftar Resep',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Tambah Resep',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : RefreshIndicator(
                onRefresh: _loadRecipes,
                child: ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(_recipes[index].name),
                        subtitle:
                            Text('Difficulty: ${_recipes[index].difficulty}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: _recipes[index]),
                            ),
                          ).then((_) => _loadRecipes());
                        },
                      ),
                    );
                  },
                ),
              );
  }
}
