import 'package:flutter/material.dart';
import 'flashcard_model.dart';
import 'flashcard_preview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewFlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  NewFlashcardScreen({required this.flashcards});

  @override
  _NewFlashcardScreenState createState() => _NewFlashcardScreenState();
}

class _NewFlashcardScreenState extends State<NewFlashcardScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  String _selectedCategory = 'General';
  List<String> _categories = ['General'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      setState(() {
        _categories = List<String>.from(json.decode(categoriesString));
      });
    }
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_categories);
    await prefs.setString('categories', encodedData);
  }

  void _addFlashcard() async {
    final String question = _questionController.text;
    final String answer = _answerController.text;
    final String category = _selectedCategory;

   bool isQuestionValid = question.isNotEmpty && question[0] == question[0].toUpperCase();
  bool isAnswerValid = answer.isNotEmpty && answer[0] == answer[0].toUpperCase();


  if (!isQuestionValid || !isAnswerValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Both question and answer fields must be filled out, and each must start with a capital letter')),
    );
    return;
  }

    Flashcard newFlashcard = Flashcard(question: question, answer: answer, category: category);
    setState(() {
      widget.flashcards.add(newFlashcard);
      _saveFlashcards();
      _questionController.clear();
      _answerController.clear();
    });
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(widget.flashcards.map((e) => e.toJson()).toList());
    await prefs.setString('flashcards', encodedData);
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: _newCategoryController,
            decoration: InputDecoration(hintText: "Category Name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addCategory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addCategory() {
    String newCategory = _newCategoryController.text.trim();
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      setState(() {
        _categories.add(newCategory);
        _selectedCategory = newCategory;
        _newCategoryController.clear();
      });
      _saveCategories();
    }
  }

void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardPreviewScreen(
          flashcards: widget.flashcards.where((card) => card.category == category).toList(),
          category: category,
          onFlashcardChanged: () {
            setState(() {});
          },
        ),
      ),
    );
  }
  

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('New Flashcard')),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Question',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              labelText: 'Answer',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                onChanged: (String? newValue) {
                  if (newValue == "Add New Category") {
                    _showAddCategoryDialog();
                  } else {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  }
                },
                items: _categories
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList()
                  ..add(DropdownMenuItem(
                      value: "Add New Category",
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.blue),
                          Text(" Add New Category"),
                        ],
                      ))),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle: TextStyle(fontSize: 18),
            ),
            onPressed: _addFlashcard,
            child: Text('Add Flashcard'),
          ),
          SizedBox(height: 20), // Space between button and grid
          GridView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 1,
            ),
            itemCount: _categories.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => _navigateToCategory(_categories[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20), // Additional space at the bottom if needed
        ],
      ),
    ),
  );
}
}
