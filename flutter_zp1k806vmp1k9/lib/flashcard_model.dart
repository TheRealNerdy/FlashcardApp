class Flashcard {
  String question;
  String answer;
  String category;

  Flashcard({required this.question, required this.answer, this.category = 'General'});

  factory Flashcard.fromJson(Map<String, dynamic> jsonData) {
    return Flashcard(
      question: jsonData['question'],
      answer: jsonData['answer'],
      category: jsonData['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
    };
  }
}
