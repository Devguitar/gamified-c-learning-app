class Quiz {
  int? id;
  int tutorialId;
  String question;
  String option1;
  String option2;
  String option3;
  String option4;
  String correctOption;

  Quiz({
    this.id,
    required this.tutorialId,
    required this.question,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
  });

  // Convert a Quiz object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorial_id': tutorialId,
      'question': question,
      'option1': option1,
      'option2': option2,
      'option3': option3,
      'option4': option4,
      'correct_option': correctOption,
    };
  }

  // Create a Quiz object from a map
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      tutorialId: map['tutorial_id'],
      question: map['question'],
      option1: map['option1'],
      option2: map['option2'],
      option3: map['option3'],
      option4: map['option4'],
      correctOption: map['correct_option'],
    );
  }
}
