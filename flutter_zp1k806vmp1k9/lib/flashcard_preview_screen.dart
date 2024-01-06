import 'package:flutter/material.dart';
import 'flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FlashcardPreviewScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final String category;
  final VoidCallback onFlashcardChanged;

  FlashcardPreviewScreen({
    required this.flashcards,
    required this.category,
    required this.onFlashcardChanged,
  });

  @override
  _FlashcardPreviewScreenState createState() => _FlashcardPreviewScreenState();
}

class _FlashcardPreviewScreenState extends State<FlashcardPreviewScreen> {
  late List<Flashcard> localFlashcards;

  @override
  void initState() {
    super.initState();
    localFlashcards = List.from(widget.flashcards); // Create a local copy of flashcards
    print("FlashcardPreviewScreen initState: Local flashcards initialized.");
  }

  Future<void> _deleteFlashcard(Flashcard flashcard) async {
    print("Deleting flashcard: ${flashcard.question}");

    setState(() {
      localFlashcards.remove(flashcard); // Update the local copy
      print("Flashcard deleted from localFlashcards.");
    });

    await _saveFlashcards();
    print("Flashcards saved to SharedPreferences.");

    widget.onFlashcardChanged();
    print("onFlashcardChanged callback called.");
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(localFlashcards.map((e) => e.toJson()).toList());
    await prefs.setString('flashcards', encodedData);
    print("Flashcards saved to SharedPreferences.");
  }

  @override
  Widget build(BuildContext context) {
    List<Flashcard> categoryFlashcards = localFlashcards
        .where((flashcard) => flashcard.category == widget.category)
        .toList();

    print("Building FlashcardPreviewScreen with ${categoryFlashcards.length} flashcards.");

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards in ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: categoryFlashcards.length,
        itemBuilder: (context, index) {
          Flashcard flashcard = categoryFlashcards[index];
          return ListTile(
            title: Text(flashcard.question),
            subtitle: Text(flashcard.answer),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteFlashcard(flashcard),
            ),
          );
        },
      ),
    );
  }
}
