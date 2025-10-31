class Quest {
  int? id;
  int gameId;
  String objective;
  String codeChallenge;
  int points;
  String? hint; // Optional hint

  Quest({
    this.id,
    required this.gameId,
    required this.objective,
    required this.codeChallenge,
    required this.points,
    this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'objective': objective,
      'codeChallenge': codeChallenge,
      'points': points,
      'hint': hint,
    };
  }
}
