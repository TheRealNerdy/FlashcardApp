import 'package:flutter/material.dart';
import 'flashcard_model.dart'; // Importing the model for Flashcard
import 'flashcard_view.dart'; // Importing the view for Flashcard
import 'dart:math' as math; // Importing Dart's math library for mathematical calculations

class FlashcardViewer extends StatefulWidget {
  final List<Flashcard> flashcards; // Declaring a list of Flashcards

  FlashcardViewer({required this.flashcards}); // Constructor for FlashcardViewer

  @override
  _FlashcardViewerState createState() => _FlashcardViewerState(); // Creating state for the widget
}

class _FlashcardViewerState extends State<FlashcardViewer> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Animation controller for the flip animation
  late Animation<double> _flipAnimation; // The animation for flipping the card
  int _currentIndex = 0; // Current index of the displayed flashcard

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Setting duration for the flip animation
      vsync: this, // Ticker provider for the animation
    );
    _flipAnimation = Tween<double>(begin: 0, end: math.pi).animate(_controller); // Defining the flip animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Disposing the controller when the widget is removed
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isCompleted || _controller.velocity > 0)
      _controller.reverse(); // Reversing the animation if it's completed or in motion
    else
      _controller.forward(); // Otherwise, starting the animation
  }

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      _currentIndex++; // Increment current index if not at the end of the list
    } else {
      _currentIndex = 0; // Loop back to the first card
    }
    _controller.reset(); // Resetting the controller
    setState(() {}); // Triggering a rebuild to update the view
  }

  @override
  Widget build(BuildContext context) {
    Flashcard currentFlashcard = widget.flashcards[_currentIndex]; // Getting the current flashcard

    return GestureDetector(
      onTap: _nextCard, // Handling tap to move to the next card
      onHorizontalDragEnd: (details) => _flipCard(), // Handling horizontal drag to flip the card
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isFront = _controller.value < 0.5; // Determining if the front of the card is showing
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Setting 3D effect for the flip
              ..rotateY(_flipAnimation.value), // Applying rotation for the flip
            alignment: Alignment.center,
            child: isFront
                ? FlashcardView(text: currentFlashcard.question) // Displaying the front of the card
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi), // Rotating for the back of the card
                    child: FlashcardView(text: currentFlashcard.answer), // Displaying the back of the card
                  ),
          );
        },
      ),
    );
  }
}
