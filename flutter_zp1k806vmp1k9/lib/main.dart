// Importing necessary Flutter and Dart packages
import 'package:flutter/material.dart';
import 'practice_screen.dart';
import 'new_flashcard_screen.dart';
import 'flashcard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  // Ensuring Flutter's framework is initialized before runApp is called
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieving flashcards data from local storage (shared preferences)
  final prefs = await SharedPreferences.getInstance();
  final String? flashcardsString = prefs.getString('flashcards');
  // Decoding the stored string into a list of Flashcard objects
  List<Flashcard> flashcards = flashcardsString != null ? 
    List<Flashcard>.from(json.decode(flashcardsString).map((e) => Flashcard.fromJson(e))) : [];

  // Starting the main application with the retrieved flashcards
  runApp(MyFlashcardApp(flashcards: flashcards));
}

class MyFlashcardApp extends StatelessWidget {
  final List<Flashcard> flashcards;

  // Constructor to initialize the app with a list of flashcards
  MyFlashcardApp({required this.flashcards});

  @override
  Widget build(BuildContext context) {
    // Setting up the Material App with its theme and initial route (home page)
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // The home page is set to FlashcardHomePage with the list of flashcards
      home: FlashcardHomePage(flashcards: flashcards),
    );
  }
}

class FlashcardHomePage extends StatefulWidget {
  final List<Flashcard> flashcards;

  // Constructor to initialize the page with a list of flashcards
  FlashcardHomePage({required this.flashcards});

  @override
  _FlashcardHomePageState createState() => _FlashcardHomePageState();
}

class _FlashcardHomePageState extends State<FlashcardHomePage> {
  int _selectedIndex = 0; // Keeps track of the currently selected tab in the navigation bar

  @override
  Widget build(BuildContext context) {
    // List of widgets (screens) that correspond to each tab
    final List<Widget> _screens = [
      PracticeScreen(flashcards: widget.flashcards),
      NewFlashcardScreen(flashcards: widget.flashcards),
    ];

    // Building the main scaffold of the app with an AppBar, Body and BottomNavigationBar
    return Scaffold(
      appBar: AppBar(title: Text('Coding Flashcards')),
      body: _screens[_selectedIndex], // Displaying the selected screen based on the current index
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'New'),
        ],
        currentIndex: _selectedIndex, // Tracking the current selected tab
        selectedItemColor: Colors.blue,
        onTap: (int index) {
          // Function to handle tab changes
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
