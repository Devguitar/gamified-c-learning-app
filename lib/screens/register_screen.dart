import 'package:flutter/material.dart';
import 'package:gamified_cpla_v1/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:audioplayers/audioplayers.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final AudioPlayer _backgroundAudioPlayer = AudioPlayer();
  final AudioPlayer _buttonAudioPlayer = AudioPlayer(); // Only for sign up button sounds
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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
    // Background music setup
    await _backgroundAudioPlayer.play(AssetSource('audio/relaxing-guitar-loop-v5-245859.mp3'));
    await _backgroundAudioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio
    await _backgroundAudioPlayer.setVolume(0.5); // Set to 50% volume

    // Pre-load button sound effect for faster playback
    await _buttonAudioPlayer.setSource(AssetSource('audio/click.mp3'));
    await _buttonAudioPlayer.setVolume(0.8); // Set to 80% volume
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _backgroundAudioPlayer.dispose();
    _buttonAudioPlayer.dispose(); // Dispose the button audio player
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required IconData icon,
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
        obscureText: obscureText && _obscurePassword,
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

  // Play button tap sound and then perform registration
  Future<void> _playTapSoundAndRegister() async {
    // Reset audio to beginning and play
    await _buttonAudioPlayer.seek(Duration.zero);
    await _buttonAudioPlayer.resume();

    // Short delay to let the sound effect start before processing
    await Future.delayed(Duration(milliseconds: 100));

    // Handle registration logic
    _handleRegistration();
  }

  Future<void> _handleRegistration() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String role = 'user';

    if (username.isEmpty || password.isEmpty) {
      _showError('Please fill in all the fields');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      int result = await _dbHelper.insertUser(username, password, role);
      if (result != 0) {
        if (!mounted) return;

        // Stop audio when navigating away
        await _backgroundAudioPlayer.stop();
        await _buttonAudioPlayer.stop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        _showError('Registration failed. Please try again.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  // Navigate back without playing sound
  void _goBack() async {
    // Stop background audio when navigating away
    await _backgroundAudioPlayer.stop();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff153448),
      body: SafeArea(
        child: Container(
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
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sign up to start your journey',
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
                      obscureText: true,
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
                        onPressed: _isLoading ? null : _playTapSoundAndRegister,
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
                          'Sign Up',
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
                      onPressed: _goBack,  // Changed to _goBack that doesn't play sound
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
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
        ),
      ),
    );
  }
}