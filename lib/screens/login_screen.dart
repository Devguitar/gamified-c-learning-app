import 'package:flutter/material.dart';
import 'package:gamified_cpla_v1/screens/storymode_screen.dart';
import 'package:gamified_cpla_v1/screens/student_dashboard_screen.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart';
import 'package:gamified_cpla_v1/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:audioplayers/audioplayers.dart';

// Create a singleton AudioManager to handle audio across screens
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // New player for sound effects
  bool _isInitialized = false;
  bool _isPlaying = false;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  Future<void> initAudio() async {
    if (!_isInitialized) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio
      await _audioPlayer.setVolume(0.5); // Set to 50% volume
      await _sfxPlayer.setVolume(0.7); // Set SFX volume slightly higher
      _isInitialized = true;
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isPlaying) {
      await initAudio();
      await _audioPlayer.play(AssetSource('audio/relaxing-guitar-loop-v5-245859.mp3'));
      _isPlaying = true;
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  // New method to play button tap sound
  Future<void> playButtonTapSound() async {
    await initAudio();
    await _sfxPlayer.play(AssetSource('audio/click.mp3'));
  }

  void dispose() {
    _audioPlayer.dispose();
    _sfxPlayer.dispose(); // Dispose the SFX player too
    _isInitialized = false;
    _isPlaying = false;
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Use AudioManager singleton
  final AudioManager _audioManager = AudioManager();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _seedAdmin();
    _initAudio();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initAudio() async {
    await _audioManager.playBackgroundMusic();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    // We don't dispose the audio manager here, as it's a singleton
    super.dispose();
  }

  void _seedAdmin() async {
    await _dbHelper.seedAdminIfNeeded();
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _handleLogin() async {
    // Play the button tap sound first
    await _audioManager.playButtonTapSound();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter both username and password');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch user from the database
      Map<String, dynamic>? user = await _dbHelper.getUser(username, password);

      if (user != null) {
        String role = user['role'];
        int userId = user['id'];
        bool hasCompletedStory = (user['hasCompletedStory'] ?? 0) == 1;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_username', username);
        await prefs.setInt('current_user_id', userId);

        // Retrieve stored completion status or fallback to database value
        bool storedStoryStatus = prefs.getBool('story_completed_$userId') ?? hasCompletedStory;

        // Stop audio when navigating away
        await _audioManager.stopBackgroundMusic();

        if (!mounted) return;

        if (role == 'admin') {
          await prefs.setString('last_screen', 'AdminDashboard');
          _navigateToScreen(AdminDashboardScreen());
        } else {
          if (storedStoryStatus) {
            _navigateToScreen(DashboardScreen());
          } else {
            _navigateToScreen(StoryMode(
              userId: userId,
              onStoryCompleted: () async {
                await _dbHelper.updateUserStoryCompletion(userId, true);
                await prefs.setBool('story_completed_$userId', true);

                if (!mounted) return;
                _navigateToScreen(DashboardScreen());
              },
            ));
          }
        }
      } else {
        _showError('Invalid username or password');
      }
    } catch (e) {
      _showError('An error occurred during login');
      print("Login error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to navigate to a new screen
  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required IconData icon,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white24, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xffDFD0B8), width: 2),
          ),
          fillColor: Color(0xff2a4a60),
          filled: true,
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: label == 'Password'
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff153448),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff153448),
                    Color(0xff1f4c6a),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: MediaQuery.of(context).viewInsets.bottom > 0 ? 20.0 : 40.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _animation.value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/robot.png',
                              height: 150,
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sign in to continue learning',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 40),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          obscureText: false,
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          icon: Icons.lock_outline,
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffDFD0B8),
                                Color(0xffCFB691),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffDFD0B8).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff153448)),
                                strokeWidth: 3,
                              ),
                            )
                                : Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xff153448),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // Play tap sound for sign up button too
                            _audioManager.playButtonTapSound();
                            // Pause audio instead of stopping when going to sign up
                            _audioManager.pauseBackgroundMusic();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            ).then((_) {
                              // Resume audio when coming back from sign up
                              if (mounted) {
                                _audioManager.resumeBackgroundMusic();
                              }
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xffDFD0B8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
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
          },
        ),
      ),
    );
  }
}