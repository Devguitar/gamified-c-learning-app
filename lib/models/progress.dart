class Progress {
  int? id;
  int userId;
  int gameId;
  bool completed;
  int score;

  Progress({
    this.id,
    required this.userId,
    required this.gameId,
    required this.completed,
    required this.score,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'completed': completed ? 1 : 0,
      'score': score,
    };
  }
}
