// Importing necessary Flutter and external libraries
import 'package:flutter/material.dart'; // Core Flutter framework for building UI.
import 'package:auto_size_text/auto_size_text.dart'; // Library for text that automatically resizes to fit the container.
import 'package:shared_preferences/shared_preferences.dart'; // Library for local data storage, useful for saving settings or preferences.
import 'dart:convert'; // Dart library for encoding and decoding JSON.

// The main function is the entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that the Flutter engine is initialized for the app.
  await LocalStorage.init(); // Initializes the local storage, setting up SharedPreferences.
  runApp(MyApp()); // Runs the MyApp class, which is the root of the application.
}

// MyApp is a stateless widget, which forms the root of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a convenience widget that wraps several widgets commonly required for material design applications.
    return MaterialApp(
      title: 'Flash', // Title of the app, usually shown in the task switcher.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Defines the primary color of the app theme.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts the visual density to the platform (e.g., Android, iOS).
      ),
      home: FlashcardPage(), // Specifies the home page of the app.
    );
  }
}

// Flashcard is a model class representing a flashcard with a question and answer.
class Flashcard {
  String question; // String variable for the question.
  String answer; // String variable for the answer.

  Flashcard({required this.question, required this.answer}); // Constructor that requires a question and an answer.

  // Method to convert a Flashcard object into a JSON map.
  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};

  // Factory method to create a Flashcard from a JSON map.
  static Flashcard fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'], 
      answer: json['answer']
    );
  }
}

// FlashcardView is a stateless widget for displaying a flashcard's content.
class FlashcardView extends StatelessWidget {
  final String text; // Variable to hold the text to be displayed.

  FlashcardView({required this.text}); // Constructor requiring the text.

  @override
  Widget build(BuildContext context) {
    // Card widget provides a material design card.
    return Card(
      elevation: 4.0, // Shadow depth for the card.
      child: SizedBox(
        width: 800, // Fixed width of the card.
        height: 250, // Fixed height of the card.
        child: Container(
          padding: EdgeInsets.all(20), // Padding inside the card.
          child: Center(
            // AutoSizeText automatically resizes the text to fit within its bounds.
            child: AutoSizeText(
              text,
              textAlign: TextAlign.center, // Align text to the center.
              style: TextStyle(fontSize: 50), // Base font size.
              minFontSize: 10, // Minimum font size to downscale if needed.
              maxLines: 10, // Maximum number of lines.
              overflow: TextOverflow.ellipsis, // Ellipsis used to indicate text overflow.
            ),
          ),
        ),
      ),
    );
  }
}



// FlashcardPage is a StatefulWidget that creates an instance of _FlashcardPageState.
class FlashcardPage extends StatefulWidget {
  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

// _FlashcardPageState maintains the state for the FlashcardPage widget.
class _FlashcardPageState extends State<FlashcardPage> {
  List<Flashcard> _flashcards = []; // List to hold the flashcards.
  int _currentIndex = 0; // Tracks the current index of the displayed flashcard.
  bool _showAnswer = false; // Boolean to toggle between question and answer view.

  // initState is called when this object is inserted into the tree.
  @override
  void initState() {
    super.initState();
    _loadData(); // Load existing flashcards and index from local storage.
  }

  // Loads flashcards and current index from local storage.
  Future<void> _loadData() async {
    _flashcards = await LocalStorage.loadFlashcards();
    _currentIndex = await LocalStorage.loadCurrentIndex();
    if (_flashcards.isEmpty) {
      _flashcards.add(Flashcard(question: "Tap to see the answer", answer: "Swipe to see the next card")); // Adds default flashcard if list is empty.
    }
    setState(() {}); // Triggers a rebuild of the widget.
  }

  // Saves flashcards and current index to local storage.
  Future<void> _saveData() async {
    await LocalStorage.saveFlashcards(_flashcards);
    await LocalStorage.saveCurrentIndex(_currentIndex);
  }

  // Handles the creation and addition of a new flashcard.
  Future<void> _createAndAddFlashcard(BuildContext context) async {
    final result = await _createNewFlashcard(context);
    if (result != null) {
      _flashcards.add(result);
      await _saveData();
      setState(() {});
    }
  }

  // Deletes the current flashcard.
  void _deleteFlashcard() {
    if (_flashcards.length > 1) {
      _flashcards.removeAt(_currentIndex);
      _currentIndex = _currentIndex % _flashcards.length;
      _saveData();
      setState(() {});
    }
  }

  // Advances to the next flashcard.
  void _nextFlashcard() {
    if (_flashcards.length > 1) {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
      _showAnswer = false;
      _saveData();
      setState(() {});
    }
  }

  // Opens a dialog to create a new flashcard.
  Future<Flashcard?> _createNewFlashcard(BuildContext context) async {
    String question = '';
    String answer = '';
    return showDialog<Flashcard>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Flashcard'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(onChanged: (value) => question = value, decoration: InputDecoration(hintText: "Enter question")),
                TextField(onChanged: (value) => answer = value, decoration: InputDecoration(hintText: "Enter answer")),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (question.isNotEmpty && answer.isNotEmpty) {
                  Navigator.of(context).pop(Flashcard(question: question, answer: answer));
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Builds the UI of the flashcard page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Flashcards')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) => _handleSwipe(details),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displays the current card number and total number of cards.
            if (_flashcards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Card ${_currentIndex + 1} of ${_flashcards.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            // Displays the current flashcard.
            GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: FlashcardView(text: _showAnswer ? _flashcards[_currentIndex].answer : _flashcards[_currentIndex].question),
            ),
            // Row of buttons for flashcard actions.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  onPressed: _deleteFlashcard,
                  tooltip: 'Delete Flashcard',
                  child: Icon(Icons.delete),
                  backgroundColor: Colors.red,
                ),
                FloatingActionButton(
                  onPressed: () => _createAndAddFlashcard(context),
                  tooltip: 'Add Flashcard',
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Handles swipe gestures to navigate between flashcards.
void _handleSwipe(DragEndDetails details) {
  // Set a threshold for swipe velocity to determine a swipe gesture.
  const velocityThreshold = 250.0;
    // Check if there are more than one flashcard in the list.
  if (_flashcards.length > 1) {
    // If swipe velocity is high enough and swipe direction is left (next card).
    if (details.primaryVelocity! < -velocityThreshold && _currentIndex < _flashcards.length - 1) {
      // Call the method to advance to the next flashcard.
      _nextFlashcard();
    }
    // If swipe velocity is high enough and swipe direction is right (previous card).
    else if (details.primaryVelocity! > velocityThreshold && _currentIndex > 0) {
      // Update the state to move to the previous flashcard.
      setState(() {
        _currentIndex--; // Decrease the current index by one.
        _showAnswer = false; // Set the flag to show the question side of the flashcard.
        _saveData(); // Save the current state (which flashcard we're on) to local storage.
      });
    }
  }
}
}

// LocalStorage class manages saving and loading data from the device's local storage.
class LocalStorage {
  static SharedPreferences? _preferences;

  static const _FlashcardsKey = 'flashcards'; // Key used for storing flashcards.
  static const _CurrentIndexKey = 'currentIndex'; // Key used for storing the current index.

  // Initializes the SharedPreferences instance.
  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Saves the list of flashcards to local storage.
  static Future saveFlashcards(List<Flashcard> flashcards) async {
    final flashcardsJson = jsonEncode(flashcards.map((f) => f.toJson()).toList());
    await _preferences?.setString(_FlashcardsKey, flashcardsJson);
  }

  // Loads the list of flashcards from local storage.
  static Future<List<Flashcard>> loadFlashcards() async {
    final flashcardsJson = _preferences?.getString(_FlashcardsKey);
    if (flashcardsJson == null) return [];
    Iterable decoded = jsonDecode(flashcardsJson);
    return decoded.map<Flashcard>((json) => Flashcard.fromJson(json)).toList();
  }

  // Saves the current index to local storage.
  static Future saveCurrentIndex(int index) async {
    await _preferences?.setInt(_CurrentIndexKey, index);
  }

  // Loads the current index from local storage.
  static Future<int> loadCurrentIndex() async {
    return _preferences?.getInt(_CurrentIndexKey) ?? 0;
  }
}
