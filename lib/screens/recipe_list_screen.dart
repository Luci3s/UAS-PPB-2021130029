import 'package:flutter/material.dart';
import 'package:uas_ppb_2021130029/services/firebase_service.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';
import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  final String username;

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
  bool _isDarkMode = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  // Fungsi untuk memuat data resep
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
      // ignore: avoid_print
      print("Error: $e"); // Log error untuk debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengubah mode tema (light/dark)
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
          title: Text('Hello, ${widget.username}!'),
          backgroundColor: _isDarkMode ? Colors.black : const Color.fromARGB(255, 15, 223, 223),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: _currentIndex == 0
            ? _buildRecipeList()
            : AddRecipeScreen(username: widget.username), // Diberikan parameter username
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color.fromARGB(255, 14, 224, 196),
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

  // Widget untuk menampilkan daftar resep
  Widget _buildRecipeList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : RefreshIndicator(
                onRefresh: _loadRecipes,
                child: GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipe: _recipes[index]),
                          ),
                        ).then((_) => _loadRecipes()); // Memuat ulang resep setelah kembali
                      },
                      child: Card(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fastfood, color: Color.fromARGB(255, 8, 164, 211), size: 50),
                            const SizedBox(height: 10),
                            Text(
                              _recipes[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Difficulty: ${_recipes[index].difficulty}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
