import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';
import 'package:gamified_cpla_v1/database/database_helper.dart'; // Correct import

class StoryMode extends StatefulWidget {
  final int userId;
  final VoidCallback? onStoryCompleted;

  const StoryMode({Key? key, required this.userId, this.onStoryCompleted}) : super(key: key);

  @override
  _StoryModeState createState() => _StoryModeState();
}

class _StoryModeState extends State<StoryMode> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();


  bool _showText = false;
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AudioPlayer _audioPlayer;

  int _totalChallenges = 0;
  late List<bool> _challengeAnswered;
  double _progress = 0.0;

  // Story steps containing text, actions, and challenges
  final List<Map<String, dynamic>> _storySteps = [
    {"text": "Welcome to the World of C Programming!", "action": "Welcome!"},
    {
      "text": "In this journey, you'll learn the basics of C.",
      "action": "Introduction to C"
    },
    {
      "text": "Let's start with the famous main function!",
      "action": "Main Function"
    },
    {
      "text": "Are you ready to write your first program?",
      "action": "Prompt",
      "challenge": false,
    },
    {
      "text": "Great! Let's tackle your first challenge!",
      "action": "Challenge",
      "challenge": true,
      "question": "What is the correct syntax for the main function in C?",
      "options": [
        "int main()",
        "void main()",
        "main()",
        "main(int argc, char *argv[])"
      ],
      "correctAnswer": "int main()",
    },
    {
      "text": "Remember, every programmer started as a beginner!",
      "action": "Encouragement"
    },
    {
      "text": "Now, let's dive into variables and data types.",
      "action": "Variables and Types",
    },
    {
      "text": "You'll learn how to store data in your programs.",
      "action": "Data Storage",
      "challenge": true,
      "question": "What type would you use to store a decimal number?",
      "options": ["int", "float", "char", "double"],
      "correctAnswer": "float",
    },
    {
      "text": "Next up: control structures like loops and conditionals!",
      "action": "Control Structures",
    },
    {
      "text": "These will help you make decisions in your code.",
      "action": "Making Decisions",
      "challenge": true,
      "question": "Which statement is used for conditional execution?",
      "options": ["if", "for", "while", "switch"],
      "correctAnswer": "if",
    },
    {
      "text": "Now, let's talk about functions!",
      "action": "Functions",
    },
    {
      "text": "They allow you to organize and reuse your code.",
      "action": "Code Reusability",
    },
    {
      "text": "You're doing great! Let's finish this journey strong!",
      "action": "Final Challenge",
      "challenge": true,
      "question": "How do you declare a function in C?",
      "options": [
        "function name()",
        "void functionName()",
        "def functionName()",
        "declare functionName()"
      ],
      "correctAnswer": "void functionName()",
    },
    {
      "text": "You've unlocked the secrets of C programming!",
      "action": "Congratulations!",
      "final": true,
    },
  ];

  Future<void> _completeStory() async {
    await _dbHelper.updateUserStoryCompletion(widget.userId, true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('story_completed_${widget.userId}', true);

    if (widget.onStoryCompleted != null) {
      widget.onStoryCompleted!();
    }
  }

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('audio/background.mp3'));

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _totalChallenges = _storySteps.where((step) => step['challenge'] == true).length;
    _challengeAnswered = List<bool>.filled(_totalChallenges, false);

    _startStory();

    // Simulate story completion after some delay
    Future.delayed(Duration(seconds: 5), () async {
      await _completeStory();
    });
  }
  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startStory() async {
    for (int i = 0; i < _storySteps.length; i++) {
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _currentStep = i;
        _showText = true;
        _progress = (i + 1) / _storySteps.length;
      });
      _animationController.forward(from: 0.0);

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _showText = false;
      });
      await _animationController.reverse();

      if (_storySteps[i]['challenge'] == true &&
          !_challengeAnswered[_getChallengeIndex(i)]) {
        await Future.delayed(Duration(milliseconds: 500));
        _showChallengeDialog(i);
      } else if (_storySteps[i]['final'] == true) {
        setState(() {});
        await Future.delayed(Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
            fullscreenDialog: true,
          ),
        );
        _audioPlayer.dispose();
      }
    }
  }

  int _getChallengeIndex(int stepIndex) {
    int count = 0;
    for (int i = 0; i < stepIndex; i++) {
      if (_storySteps[i]['challenge'] == true) count++;
    }
    return count;
  }

  void _showSuccessAnimation(BuildContext ctx) {
    // Show the dialog
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 60),
                SizedBox(height: 16),
                Text(
                  "Excellent!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "You're making great progress!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Dismiss the dialog after a brief delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) { // Check if the widget is still mounted before popping the dialog
        Navigator.of(ctx).pop(); // Close the dialog
      }
    });
  }


  // Modify the _showChallengeDialog method to include a skip button
  void _showChallengeDialog(int index) {
    var challenge = _storySteps[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xff153448),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.code, color: Colors.white, size: 40),
                      SizedBox(height: 16),
                      Text(
                        "Challenge Time!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        challenge['question'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ...challenge['options'].map<Widget>((option) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();
                              bool isCorrect = option == challenge['correctAnswer'];

                              if (isCorrect) {
                                _challengeAnswered[_getChallengeIndex(index)] = true;
                                _showSuccessAnimation(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.white),
                                          SizedBox(width: 12),
                                          Text(
                                            "Not quite right. Try again!",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    backgroundColor: Colors.red[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );

                                // Delay for wrong answer before retrying challenge
                                await Future.delayed(const Duration(seconds: 1));
                                _showChallengeDialog(index);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: Color(0xff153448),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      // Skip button added here
                      SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _skipChallenge(index);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.skip_next, color: Colors.grey[700]),
                              SizedBox(width: 8),
                              Text(
                                "Skip Challenge",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Add a new method to handle skipping challenges
  void _skipChallenge(int index) {
    // Mark the challenge as answered
    _challengeAnswered[_getChallengeIndex(index)] = true;

    // Show a message that the challenge was skipped
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Challenge skipped",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep < 0 || _currentStep >= _storySteps.length) {
      _currentStep = 0;
      return Center(child: Text("Invalid story step. Resetting..."));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Learning Journey',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.insights, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff153448),
              Color(0xff1a4258),
              Color(0xff2c5d7c),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                    minHeight: 8,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background glow effect
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blue.withOpacity(0.2),
                              Colors.blue.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                      // Animated character with shadow
                      AnimatedOpacity(
                        opacity: _showText ? 0.3 : 1.0,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/robot.png',
                            height: 150,
                          ),
                        ),
                      ),
                      // Animated text with glass effect
                      AnimatedOpacity(
                        opacity: _showText ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            padding: EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getStepIcon(_storySteps[_currentStep]['action']),
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  _storySteps[_currentStep]['text'] ?? "Error: No text",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _storySteps[_currentStep]['action'] ?? "Error: No action",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                    height: 1.4,
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_storySteps[_currentStep]['challenge'] == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 24),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: Colors.yellow[400],
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Challenge Available',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
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
                    ],
                  ),
                ),
              ),
              // Bottom indicator dots
              // Bottom indicator dot
              Container(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _storySteps.length,
                        (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentStep
                            ? Colors.blue[400]
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStepIcon(String action) {
    switch (action.toLowerCase()) {
      case 'welcome!':
        return Icons.waving_hand;
      case 'introduction to c':
        return Icons.code;
      case 'main function':
        return Icons.functions;
      case 'prompt':
        return Icons.play_arrow;
      case 'challenge':
        return Icons.extension;
      case 'encouragement':
        return Icons.favorite;
      case 'variables and types':
        return Icons.data_array;
      case 'data storage':
        return Icons.storage;
      case 'control structures':
        return Icons.account_tree;
      case 'making decisions':
        return Icons.route;
      case 'functions':
        return Icons.functions;
      case 'code reusability':
        return Icons.recycling;
      case 'final challenge':
        return Icons.emoji_events;
      case 'congratulations!':
        return Icons.celebration;
      default:
        return Icons.code;
    }
  }
}
