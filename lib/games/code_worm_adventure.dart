import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import'package:gamified_cpla_v1/database/database_helper.dart';


// Modern color scheme
const Color primaryColor = Color(0xFF2D3250); // Deep blue-grey
const Color secondaryColor = Color(0xFF424769); // Lighter blue-grey
const Color accentColor = Color(0xFFF4EEE0); // Cream white
const Color backgroundColor = Color(0xFF153448); // Dark teal
const Color cardHoverColor = Color(0xFF676F9D); // Muted purple



class CodeWormGame extends StatefulWidget {
  const CodeWormGame({Key? key}) : super(key: key);
  @override
  _CodeWormGameState createState() => _CodeWormGameState();
}

class _CodeWormGameState extends State<CodeWormGame> {
  int _score = 0;
  int _timeLeft = 60;
  bool _isPlaying = false;
  late Timer _timer;
  List<String> _currentCodeChallenge = [];
  List<String> _selectedCode = [];
  List<String> _codeOptions = [];
  int _level = 1;
  int _lives = 3;
  int _challengesCompleted = 0;
  final Random _random = Random();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _highScore = 0;

  // List of code snippets for different levels
  final List<List<String>> _codeSnippets = [
    // Level 1 - Basic print
    ["printf", "(", '"Hello, World!"', ")", ";"],
    // Level 2 - Variable declaration
    ["int", "count", "=", "0", ";"],
    // Level 3 - Conditional
    ["if", "(", "x", ">", "10", ")", "{", "}"],
    // Level 4 - Loop
    ["for", "(", "int", "i", "=", "0", ";", "i", "<", "10", ";", "i++", ")", "{", "}"],
    // Level 5 - Function
    ["void", "main", "(", ")", "{", "return", "0", ";", "}"],
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    int highScore = await _dbHelper.getHighScore();
    setState(() {
      _highScore = highScore;
    });
  }

  @override
  void dispose() {
    if (_isPlaying) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 60;
      _isPlaying = true;
      _level = 1;
      _lives = 3;
      _selectedCode = [];
      _challengesCompleted = 0;
      _loadNewChallenge();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _loadNewChallenge() {
    // Select a random code snippet based on current level
    int index = _random.nextInt(min(_level, _codeSnippets.length));
    _currentCodeChallenge = List.from(_codeSnippets[index]);
    // Shuffle the challenge for display
    List<String> shuffled = List.from(_currentCodeChallenge);
    shuffled.shuffle(_random);
    setState(() {
      _currentCodeChallenge = List.from(_codeSnippets[index]);
      _codeOptions = shuffled;
      _selectedCode = [];
    });
  }

  void _endGame() {
    _timer.cancel();
    setState(() {
      _isPlaying = false;
    });
    _saveGameStats();
    _showGameOverDialog(context as BuildContext);
  }

  Future<void> _saveGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('current_user_id');

    if (userId == null) {
      print("Error: No user ID found. Game stats not saved.");
      return; // Exit if no user is logged in
    }

    Map<String, dynamic> gameStats = {
      DatabaseHelper.columnUserId: userId,  // Ensure user_id is included
      DatabaseHelper.columnScore: _score,
      DatabaseHelper.columnLevel: _level,
      DatabaseHelper.columnTimeLeft: _timeLeft,
      DatabaseHelper.columnLives: _lives,
      DatabaseHelper.columnChallengesCompleted: _challengesCompleted,
    };

    await _dbHelper.insertGameStats(gameStats);

    // Update high score if needed
    if (_score > _highScore) {
      setState(() {
        _highScore = _score;
      });
    }
  }


  void _selectCode(String code) {
    if (_isPlaying) {
      setState(() {
        _selectedCode.add(code);
        _codeOptions.remove(code); // Remove selected option
      });
      _checkCode();
    }
  }

  void _removeSelection(int index) {
    if (_isPlaying) {
      setState(() {
        String code = _selectedCode.removeAt(index);
        _codeOptions.add(code); // Add back to options
      });
    }
  }

  void _checkCode() {
    if (_selectedCode.length == _currentCodeChallenge.length) {
      bool isCorrect = true;
      for (int i = 0; i < _selectedCode.length; i++) {
        if (_selectedCode[i] != _currentCodeChallenge[i]) {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect) {
        setState(() {
          _score += 10 * _level;
          _challengesCompleted++;
          if (_score > 0 && _score % 30 == 0) {
            _level = min(_level + 1, 5);
            _timeLeft += 10; // Bonus time for leveling up
            _showLevelCompletionDialog(context as BuildContext);
          }
        });
        _showSuccessSnackbar();
        _loadNewChallenge();
      } else {
        setState(() {
          _lives--;
          if (_lives <= 0) {
            _endGame();
          } else {
            // Return the items back to options
            _codeOptions.addAll(_selectedCode);
            _selectedCode = [];
            _showErrorSnackbar();
          }
        });
      }
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text("Correct! +${10 * _level} points",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: const Text("Incorrect! Try again (-1 life)",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context, // Fixed: Changed to BuildContext
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog( // Fixed: Explicitly specified BuildContext
        backgroundColor: secondaryColor,
        title: const Text("Game Over", style: TextStyle(color: accentColor, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
            const SizedBox(height: 20),
            Text("Final Score: $_score",
                style: const TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("High Score: $_highScore",
                style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Level Reached: $_level",
                style: const TextStyle(color: accentColor, fontSize: 18)),
            const SizedBox(height: 5),
            Text("Challenges Completed: $_challengesCompleted",
                style: const TextStyle(color: accentColor, fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Great job! Can you beat your score?",
                style: TextStyle(color: accentColor, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Play Again"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameStatsScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("View Stats"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Exit"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  void _showLevelCompletionDialog(BuildContext context) {
    showDialog(
      context: context, // Fixed: Changed to BuildContext
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog( // Fixed: Explicitly specified BuildContext
        backgroundColor: secondaryColor,
        title: const Text("Level Complete!", style: TextStyle(color: accentColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You've reached level $_level!", style: const TextStyle(color: accentColor)),
            const SizedBox(height: 10),
            Text("Current Score: $_score", style: const TextStyle(color: accentColor)),
            const SizedBox(height: 5),
            Text("Bonus Time: +10 seconds", style: const TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: accentColor,
            ),
            child: const Text("Continue"),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Code Worm: The C Programming Quest", style: TextStyle(color: accentColor)),
        backgroundColor: primaryColor,

        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: accentColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameStatsScreen()),
              );
            },
            tooltip: "Game Stats",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, primaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Game stats bar
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("SCORE", style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                          Text("$_score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("LEVEL", style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                          Text("$_level", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("TIME", style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
                          Text("$_timeLeft", style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _timeLeft < 10 ? Colors.red : accentColor,
                          )),
                        ],
                      ),
                      Row(
                        children: List.generate(_lives, (index) =>
                        const Icon(Icons.favorite, color: Colors.red, size: 20)
                        ) + List.generate(3 - _lives, (index) =>
                        const Icon(Icons.favorite_border, color: Colors.red, size: 20)
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Game area
                Expanded(
                  child: _isPlaying
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Challenge description
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Arrange the code in the correct order:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentCodeChallenge.join(" "),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // User's arrangement area
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cardHoverColor, width: 2),
                        ),
                        child: _selectedCode.isEmpty
                            ? const Text("Select code blocks to build your solution", style: TextStyle(color: accentColor))
                            : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _selectedCode.length,
                                (index) => GestureDetector(
                              onTap: () => _removeSelection(index),
                              child: Chip(
                                label: Text(_selectedCode[index], style: const TextStyle(color: primaryColor)),
                                backgroundColor: accentColor,
                                deleteIcon: const Icon(Icons.close, size: 16, color: primaryColor),
                                onDeleted: () => _removeSelection(index),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Available code options
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _codeOptions.map((code) {
                              return ElevatedButton(
                                onPressed: () => _selectCode(code),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: accentColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8
                                  ),
                                ),
                                child: Text(code),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CODE WORM",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "The C Programming Quest",
                          style: TextStyle(fontSize: 18, color: accentColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "High Score: $_highScore",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: _startGame,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("START GAME"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Game Stats Screen Implementation
class GameStatsScreen extends StatefulWidget {
  @override
  _GameStatsScreenState createState() => _GameStatsScreenState();
}

class _GameStatsScreenState extends State<GameStatsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _gameStatsList = [];
  int _highScore = 0;
  bool _isGameUnlocked = false; //

  @override
  void initState() {
    super.initState();
    _loadGameStats();
  }

  // Load game stats from the database
  Future<void> _loadGameStats() async {
    try {
      List<Map<String, dynamic>> gameStatsList = await _dbHelper.getAllGameStats();
      Map<String, dynamic>? highScoreData = await _dbHelper.getGlobalHighScoreWithUser();

      int highScore = highScoreData?['score'] ?? 0;
      int highScoreUserId = highScoreData?['user_id'] ?? 0;

      // Get current user ID (Assuming it's stored in SharedPreferences)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0; // Replace with actual user ID logic
      int level = 1; // Adjust based on game level tracking

      // Check unlock status from SharedPreferences first
      bool isUnlocked = prefs.getBool('game_unlocked_${userId}_$level') ?? false;

      // If not found in SharedPreferences, check in the database
      if (!isUnlocked) {
        isUnlocked = await _dbHelper.isGameUnlockedForUser(userId, level);
        if (isUnlocked) {
          await prefs.setBool('game_unlocked_${userId}_$level', true); // Store unlock status
        }
      }

      print("Game Stats List: $gameStatsList");
      print("High Score: $highScore by User ID: $highScoreUserId");
      print("Game Level $level Unlock Status for User $userId: ${isUnlocked ? "Unlocked" : "Locked"}");

      if (mounted) {
        setState(() {
          _gameStatsList = gameStatsList;
          _highScore = highScore;
          _isGameUnlocked = isUnlocked;
        });
      }
    } catch (e) {
      print("Error loading game stats: $e");
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Game Stats", style: TextStyle(color: accentColor)),
          backgroundColor: primaryColor,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundColor, primaryColor],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // High score card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                      const SizedBox(height: 10),
                      const Text(
                        "HIGH SCORE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: accentColor,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$_highScore",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Game history title
                const Text(
                  "GAME HISTORY",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: accentColor,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Game history list
                Expanded(
                  child: _gameStatsList.isEmpty
                      ? const Center(
                    child: Text(
                      "No games played yet!",
                      style: TextStyle(color: accentColor, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _gameStatsList.length,
                    itemBuilder: (context, index) {
                      final stats = _gameStatsList[index];
                      final timestamp = DateTime.parse(stats[DatabaseHelper.columnTimestamp]);
                      final formattedDate = "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Game #${_gameStatsList.length - index}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: accentColor,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xBBF4EEE0),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0x55F4EEE0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _statColumn(
                                    "Score",
                                    stats[DatabaseHelper.columnScore]?.toString() ?? "0", // Null check added
                                    (stats[DatabaseHelper.columnScore] ?? 0) == _highScore ? Colors.amber : accentColor,
                                  ),
                                  _statColumn(
                                    "Level",
                                    stats[DatabaseHelper.columnLevel]?.toString() ?? "0", // Null check added
                                    accentColor,
                                  ),
                                  _statColumn(
                                    "Challenges",
                                    stats[DatabaseHelper.columnChallengesCompleted]?.toString() ?? "0", // Null check added
                                    accentColor,
                                  ),
                                  _statColumn(
                                    "Lives",
                                    "",
                                    accentColor,
                                    livesWidget: Row(
                                      children: List.generate(
                                        (stats[DatabaseHelper.columnLives] as int?) ?? 0, // Ensures null safety
                                            (i) => const Icon(Icons.favorite, color: Colors.red, size: 16),
                                      ) + List.generate(
                                        3 - ((stats[DatabaseHelper.columnLives] as int?) ?? 0), // Ensures null safety
                                            (i) => const Icon(Icons.favorite_border, color: Colors.red, size: 16),
                                      ),
                                    ),
                                  ),
                                ],

                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _statColumn(String label, String value, Color valueColor, {Widget? livesWidget}) {
      return Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 5),
          livesWidget ?? Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      );
    }
  }