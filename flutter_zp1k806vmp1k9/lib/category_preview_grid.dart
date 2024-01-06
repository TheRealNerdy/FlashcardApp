import 'package:flutter/material.dart';

class CategoryPreviewGrid extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String> onCategoryTap;

  CategoryPreviewGrid({required this.categories, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(), // to work correctly inside a SingleChildScrollView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of items per row
        crossAxisSpacing: 10, // Spacing between items
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 1, // Aspect ratio for items
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => onCategoryTap(categories[index]),
          child: Card(
            color: Colors.blue.shade100,
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
