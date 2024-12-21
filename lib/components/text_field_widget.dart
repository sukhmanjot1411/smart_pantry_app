import 'package:flutter/material.dart';
import '../models/recipe.dart';

class TextFieldWidget extends StatefulWidget {
  final Function(List<Recipe>) onSearchResults;

  const TextFieldWidget({
    Key? key,
    required this.onSearchResults,
  }) : super(key: key);

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  final TextEditingController _searchController = TextEditingController();

  void _handleSearch(String query) {
    if (query.isEmpty) {
      widget.onSearchResults([]);
      return;
    }

    final results = recipes.where((recipe) {
      final nameLower = recipe.name.toLowerCase();
      final descriptionLower = recipe.description.toLowerCase();
      final ingredientsLower = recipe.ingredients.map((e) => e.toLowerCase()).join(' ');
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          descriptionLower.contains(searchLower) ||
          ingredientsLower.contains(searchLower);
    }).toList();

    widget.onSearchResults(results);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    
    return Container(
      height: h * .06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 2
          )
        ],
        color: Colors.orange, // added color: orange
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearch,
        style: TextStyle(
          fontSize: w * .04,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Search for recipes...",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: w * .03
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          suffixIcon: Icon(
            Icons.search,
            color: Colors.deepOrangeAccent,
            size: w * .07,
          )
        ),
      ),
    );
  }
}
