import 'package:flutter/material.dart';

class FlashcardView extends StatelessWidget {
  final String text;

  FlashcardView({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center( // Wrap with a Center widget to align it in the middle
      child: Card(
        child: Container(
          width: 300, // Set a fixed width
          height: 200, // Set a fixed height
          alignment: Alignment.center,
          padding: EdgeInsets.all(16.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        margin: EdgeInsets.all(16),
        elevation: 10,
      ),
    );
  }
}
