import 'package:flutter/material.dart';
import 'flashcard_model.dart';
import 'flashcard_viewer.dart';

// Defines the PracticeScreen as a StatefulWidget. 
// This screen will display flashcards for practice.
class PracticeScreen extends StatefulWidget {
  final List<Flashcard> flashcards; // List of flashcards to be used in this screen.

  PracticeScreen({required this.flashcards}); // Constructor requiring a list of Flashcards.

  @override
  _PracticeScreenState createState() => _PracticeScreenState(); // Creates the mutable state for this widget.
}

class _PracticeScreenState extends State<PracticeScreen> {
  String? selectedCategory; // The currently selected category of flashcards.

  @override
  void initState() {
    super.initState();
    // Extracts unique categories from the list of flashcards and assigns the first category to selectedCategory.
    List<String> categories = widget.flashcards.map((e) => e.category).toSet().toList();
    selectedCategory = categories.isNotEmpty ? categories.first : null;
  }

  @override
  Widget build(BuildContext context) {
    // Again, extract unique categories from flashcards.
    List<String> categories = widget.flashcards.map((e) => e.category).toSet().toList();

    // Check and update the selectedCategory based on the current categories availability.
    if (categories.isEmpty) {
      // If there are no categories, set selectedCategory to null.
      selectedCategory = null;
    } else if (!categories.contains(selectedCategory)) {
      // If the currently selected category is not in the available categories, update it to the first category.
      selectedCategory = categories.first;
    }

    // Filter the flashcards based on the selectedCategory.
    List<Flashcard> filteredFlashcards = selectedCategory != null
        ? widget.flashcards.where((card) => card.category == selectedCategory).toList()
        : [];

    // Building the widget tree for PracticeScreen.
    return Column(
      children: [
        // Dropdown to select categories if available.
        if (categories.isNotEmpty) ...[
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue; // Update the selectedCategory and rebuild the widget.
              });
            },
            items: categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
        // Display the FlashcardViewer or a message if no cards are available.
        Expanded(
          child: filteredFlashcards.isNotEmpty
              ? FlashcardViewer(flashcards: filteredFlashcards)
              : Center(child: Text('There are no cards in this category.')), // Displayed when no flashcards are available in the selected category.
        ),
      ],
    );
  }
}
