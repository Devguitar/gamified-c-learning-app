class GameInfo {
  final int id; // Add this line
  final String title;
  final int requiredPoints;
  bool isUnlocked;
  final bool secretNavigation;

  GameInfo({
    required this.id, // Add this line
    required this.title,
    required this.requiredPoints,
    this.isUnlocked = false,
    this.secretNavigation = false,
  });
}
