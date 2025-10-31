import 'dart:convert';

class Game {
  final int? id;
  final String title;
  final String description;
  final String difficultyLevel;
  final String adventureStage;
  final int pointsReward;
  final String concept;
  final String storyText;
  final List<String> storySegments;
  final List<List<String>> choicesByStep;
  final List<List<int>> pointsForChoices;
  final List<int> correctAnswers;
  final List<String> consequences;
  final bool isPlayed;

  Game({
    this.id,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    required this.adventureStage,
    required this.pointsReward,
    required this.concept,
    required this.storyText,
    required this.storySegments,
    required this.choicesByStep,
    required this.pointsForChoices,
    required this.correctAnswers,
    required this.consequences,
    this.isPlayed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficultyLevel': difficultyLevel,
      'adventureStage': adventureStage,
      'pointsReward': pointsReward,
      'concept': concept,
      'storyText': storyText,
      'storySegments': jsonEncode(storySegments),
      'choicesByStep': jsonEncode(choicesByStep),
      'pointsForChoices': jsonEncode(pointsForChoices),
      'correctAnswers': jsonEncode(correctAnswers),
      'consequences': jsonEncode(consequences),
      'isPlayed': isPlayed ? 1 : 0,
    };
  }
}