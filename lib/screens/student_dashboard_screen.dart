import 'package:flutter/material.dart';
import 'package:gamified_cpla_v1/screens/admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gamified_cpla_v1/database/database_helper.dart';
import 'package:gamified_cpla_v1/models/game.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/animation.dart'; // For animations
import 'package:highlight/languages/cpp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gamified_cpla_v1/games/code_worm_adventure.dart';
import 'package:http/http.dart' as http;// Import the game
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class DashboardScreen extends StatelessWidget {
  // Modern color scheme - matching admin dashboard
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color cardHoverColor = Color(0xFF676F9D);// Muted purple

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Tutorials',
      'icon': Icons.school,
      'screen': CProgrammingTutorials()
    },
    {
      'title': 'Interactive Games',
      'icon': Icons.games,
      'screen': CProgrammingInteractiveGames()
    },
    {
      'title': 'Locked Games',
      'icon': Icons.games,
      'screen': ManageLockedGamesScreen()
    },
    {
      'title': 'Coding Assessment',
      'icon': Icons.code,
      'screen': CProgrammingCodingAssessment()
    },
    {
      'title': 'Progress',
      'icon': Icons.analytics,
      'screen':ProgressTracker()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Student Dashboard'),
      drawer: _buildDrawer(context),
      body: _buildFeatureGrid(context),
      backgroundColor: backgroundColor,
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: accentColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: accentColor),
      actions: [],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _getUserDetails(), // Fetch user details asynchronously
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: secondaryColor,
                      child: Icon(Icons.person, color: accentColor, size: 35),
                    ),
                    SizedBox(height: 12),
                    Text(
                      user['username'], // Dynamic username
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user['email'], // Dynamic email
                      style: GoogleFonts.inter(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(context, 'Edit Profile', Icons.edit_outlined, EditProfileScreen()),
              _buildDrawerItem(context, 'Change Password', Icons.lock_outline, ChangePasswordScreen()),
              _buildDrawerItem(context, 'Notification Settings', Icons.notifications_outlined, NotificationSettingsScreen()),
              _buildDrawerItem(context, 'Privacy Settings', Icons.privacy_tip_outlined, PrivacySettingsScreen()),
              _buildDrawerItem(context, 'Help & Support', Icons.help_outline, HelpSupportScreen()),
              Divider(color: accentColor.withOpacity(0.2), thickness: 1),
              _buildDrawerItem(context, 'Logout', Icons.logout, LoginScreen(), isLogoutButton: true, userId: user['userId']),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('current_user_id') ?? 0;
    bool hasCompletedStory = prefs.getBool('story_completed_$userId') ?? false;

    return {
      'userId': userId,
      'username': prefs.getString('current_username') ?? 'Student User',
      'email': prefs.getString('current_user_email') ?? 'student@example.com',
      'hasCompletedStory': hasCompletedStory, // ✅ Include story mode status
    };
  }
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('current_user_id');
    bool hasCompletedStory = prefs.getBool('story_completed_$userId') ?? false;

    await prefs.clear();
    if (userId != null) {
      await prefs.setBool('story_completed_$userId', hasCompletedStory);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }


  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Widget screen,
      {bool isLogoutButton = false, int? userId}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isLogoutButton ? Colors.red.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogoutButton ? Colors.red : accentColor),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isLogoutButton ? Colors.red : accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () async {
            Navigator.pop(context); // Close drawer before navigating

            if (isLogoutButton) {
              await _handleLogout(context);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
            }
          }


      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevent scrolling conflicts
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(
              title: feature['title'],
              icon: feature['icon'],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => feature['screen']),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: secondaryColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: accentColor,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureScreen(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(color: accentColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.inter(
              color: accentColor,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
// Placeholder screens for various features
class CProgrammingTutorials extends StatefulWidget {
  @override
  _CProgrammingTutorialsState createState() => _CProgrammingTutorialsState();
}

class _CProgrammingTutorialsState extends State<CProgrammingTutorials> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  // Store tutorials data
  List<Map<String, dynamic>> _tutorials = [];

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _launchResource(BuildContext context, String? url, String? filePath) async {
    try {
      if (url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar(context, 'Could not launch URL', isError: true);
        }
      } else if (filePath != null && filePath.isNotEmpty) {
        if (await File(filePath).exists()) {
          final result = await OpenFilex.open(filePath);
          if (result.type != ResultType.done) {
            _showSnackBar(context, 'Could not open file', isError: true);
          }
        } else {
          _showSnackBar(context, 'File does not exist', isError: true);
        }
      } else {
        _showSnackBar(context, 'No resource available', isError: true);
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', isError: true);
    }
  }

  // Function to refresh tutorials by fetching them again
  Future<void> _refreshTutorials() async {
    try {
      final tutorials = await _dbHelper.getAllTutorials();
      setState(() {
        _tutorials = tutorials;
      });
    } catch (e) {
      _showSnackBar(context, 'Error refreshing tutorials: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: accentColor),
        centerTitle: true,
        title: Text(
          'Tutorials',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 20, // Adjusted from 24 to 20 for smaller text
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _refreshTutorials,
            tooltip: 'Refresh Tutorials',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _dbHelper.getAllTutorials(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: accentColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: errorColor,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.inter(
                        color: errorColor,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: accentColor.withOpacity(0.6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No tutorials available',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            Map<String, List<Map<String, dynamic>>> groupedTutorials = {
              'General': snapshot.data!
            };

            return ListView(
              padding: EdgeInsets.all(16),
              children: groupedTutorials.entries.map((entry) {
                String moduleTitle = entry.key;
                List<Map<String, dynamic>> tutorials = entry.value;

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.1)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      collapsedIconColor: accentColor,
                      iconColor: accentColor,
                      title: Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            color: accentColor,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            moduleTitle,
                            style: GoogleFonts.poppins(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      children: tutorials.map((tutorial) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              tutorial['title'],
                              style: GoogleFonts.inter(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  tutorial['description'],
                                  style: GoogleFonts.inter(
                                    color: accentColor.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tutorial['url'] != null &&
                                    tutorial['url'].isNotEmpty)
                                  _buildActionButton(
                                    icon: Icons.link,
                                    color: Colors.blue[400]!,
                                    tooltip: 'Open URL',
                                    onPressed: () => _launchResource(
                                      context,
                                      tutorial['url'],
                                      null,
                                    ),
                                  ),
                                if (tutorial['filePath'] != null &&
                                    tutorial['filePath'].isNotEmpty) ...[
                                  SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.attach_file,
                                    color: Colors.green[400]!,
                                    tooltip: 'Open File',
                                    onPressed: () => _launchResource(
                                      context,
                                      null,
                                      tutorial['filePath'],
                                    ),
                                  ),
                                ],
                                SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.quiz,
                                  color: Colors.amber[400]!,
                                  tooltip: 'Take Quiz',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizScreen(
                                          tutorialId: tutorial['id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }
}

class QuizScreen extends StatelessWidget {
  final int tutorialId;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  QuizScreen({required this.tutorialId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
        'Quiz',
        style: GoogleFonts.poppins(
        color: accentColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
    ),
    ),
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
    ),
    ),
    child: FutureBuilder<List<Map<String, dynamic>>>(
    future: _dbHelper.getQuizzesByTutorial(tutorialId),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
    child: CircularProgressIndicator(color: accentColor),
    );
    }

    if (snapshot.hasError) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.error_outline,
    color: errorColor,
    size: 64,
    ),
    SizedBox(height: 16),
    Text(
    'Error: ${snapshot.error}',
    style: GoogleFonts.inter(
    color: errorColor,
    fontSize: 18,
    ),
    textAlign: TextAlign.center,
    ),
    ],
    ),
    );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.quiz_outlined,
    size: 64,
    color: accentColor.withOpacity(0.6),
    ),
    SizedBox(height: 16),
    Text(
    'No quizzes available',
    style: GoogleFonts.inter(
    color: accentColor,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    ),
    ),
    ],
    ),
    );
    }

    List<Map<String, dynamic>> quizzes = snapshot.data!;

    return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: quizzes.length,
    itemBuilder: (context, index) {
    final quiz = quizzes[index];
    return Card(
    margin: EdgeInsets.only(bottom: 12),
    color: secondaryColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
    'Q${index + 1}',
    style: GoogleFonts.inter(
    color: accentColor,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    SizedBox(width: 12),
    Expanded(
    child: Text(
    quiz['question'],
    style: GoogleFonts.inter(
    color: accentColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 16),
    ...List.generate(4, (i) {
    final option = quiz['option${i + 1}'];
    return Container(
    margin: EdgeInsets.only(bottom: 8),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: primaryColor.withOpacity(0.3),
    borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: accentColor.withOpacity(0.1),
      ),
    ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + i),  // A, B, C, D
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: GoogleFonts.inter(
                color: accentColor.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
    }),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Implement answer submission
              _showAnswerDialog(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8),
                Text(
                  'Submit Answer',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
    ),
    ),
    );
    },
    );
    },
    ),
    ),
    );
  }

  void _showAnswerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[400],
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Correct Answer!',
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Keep up the good work!',
                  style: GoogleFonts.inter(
                    color: accentColor.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          color: accentColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to tutorials
                      },
                      child: Text(
                        'Finish Quiz',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
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
    );
  }
}
//INTERACTIVE GAMES
class CProgrammingInteractiveGames extends StatefulWidget {
  @override
  _CProgrammingInteractiveGamesState createState() => _CProgrammingInteractiveGamesState();
}

class _CProgrammingInteractiveGamesState extends State<CProgrammingInteractiveGames> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  List<Game> _games = [];
  Map<int, bool> _gamePlayedStatus = {};

  @override
  void initState() {
    super.initState();
    _fetchGameList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_username');
  }

  Future<void> _fetchGameList() async {
    try {
      List<Game> games = await _dbHelper.getAllGames();
      String? username = await getCurrentUsername();

      if (username == null) {
        _showSnackBar('User not logged in!', isError: true);
        return;
      }

      Map<int, bool> playedStatus = {};
      for (Game game in games) {
        if (game.id != null) {
          bool isPlayed = await _dbHelper.isGamePlayedForUser(game.id!, username);
          playedStatus[game.id!] = isPlayed;
        }
      }

      setState(() {
        _games = games;
        _gamePlayedStatus = playedStatus;
      });
    } catch (e) {
      print('Error fetching games: $e');
      _showSnackBar('Failed to fetch games: ${e.toString()}', isError: true);
    }
  }

  void _onPlayButtonPressed(Game game) async {
    String? username = await getCurrentUsername();

    if (username == null || username.isEmpty) {
      _showSnackBar('User not logged in!', isError: true);
      return;
    }

    try {
      if (_gamePlayedStatus[game.id] ?? false) {
        _showSnackBar('Game has already been completed!');
        return;
      }

      await _dbHelper.markGameAsLockedForUser(game.id!, username);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdventureGameScreen(game: game),
        ),
      ).then((_) async {
        await _dbHelper.markGameAsPlayedForUser(game.id!, username);
        await _dbHelper.unlockGameForUser(game.id!, username);
        _fetchGameList();
      });
    } catch (e) {
      print('Error playing game: $e');
      _showSnackBar('An error occurred: $e', isError: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: accentColor),
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(

          'Interactive Games',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _fetchGameList,
            tooltip: 'Refresh Games',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          ),
        ),
        child: _games.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.games_outlined,
                size: 64,
                color: accentColor.withOpacity(0.6),
              ),
              SizedBox(height: 16),
              Text(
                'No games available',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _games.length,
          itemBuilder: (context, index) {
            Game game = _games[index];
            bool isPlayed = _gamePlayedStatus[game.id] ?? false;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              color: secondaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(
                    Icons.gamepad,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  game.title,
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      game.description,
                      style: GoogleFonts.inter(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPlayed ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPlayed ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlayed ? Icons.check_circle : Icons.access_time,
                            color: isPlayed ? Colors.green[400] : Colors.orange[400],
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            isPlayed ? 'Completed' : 'Not played',
                            style: GoogleFonts.inter(
                              color: isPlayed ? Colors.green[400] : Colors.orange[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: (isPlayed ? Colors.red : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlayed ? Icons.lock : Icons.play_arrow,
                      color: isPlayed ? Colors.red[400] : Colors.green[400],
                    ),
                    tooltip: isPlayed ? 'Game Locked' : 'Play Game',
                    onPressed: () => _onPlayButtonPressed(game),
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

class AdventureGameScreen extends StatefulWidget {
  final Game game;

  AdventureGameScreen({required this.game});

  @override
  _AdventureGameScreenState createState() => _AdventureGameScreenState();
}

class _AdventureGameScreenState extends State<AdventureGameScreen> {
  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  int currentSegmentIndex = 0;
  int totalPoints = 0;
  bool gameEnded = false;
  int timeSpentOnSegment = 0;
  late Stopwatch stopwatch;

  List<String> userChoices = [];
  late List<String> storySegments;
  late List<List<String>> choicesByStep;
  late List<List<int>> pointsForChoices;
  late List<int> correctAnswers;
  late List<String> consequences;

  late AudioPlayer _audioPlayer;
  late ConfettiController _confettiController;

  String username = '';

  @override
  void initState() {
    super.initState();
    storySegments = widget.game.storySegments;
    choicesByStep = widget.game.choicesByStep;
    pointsForChoices = widget.game.pointsForChoices;
    correctAnswers = widget.game.correctAnswers;
    consequences = widget.game.consequences;

    _audioPlayer = AudioPlayer();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    stopwatch = Stopwatch();
    stopwatch.start();

    _playBackgroundMusic();
    _checkGameStatus();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String storedUsername = prefs.getString('current_username') ?? '';

    if (storedUsername.isNotEmpty) {
      setState(() {
        username = storedUsername;
      });
    } else {
      // Try the alternate key as fallback
      String fallbackUsername = prefs.getString('username') ?? '';
      setState(() {
        username = fallbackUsername;
      });
    }
  }
  void _playBackgroundMusic() {
    _audioPlayer.stop();
    _audioPlayer.play(
      AssetSource('audio/big-beat-new-67544.mp3'),
      volume: 0.5,
    );
  }

  void _nextSegment(int choiceIndex) {
    if (currentSegmentIndex < storySegments.length) {
      setState(() {
        if (choiceIndex == -1) {
          userChoices.add('Skipped');
          currentSegmentIndex++;
          return;
        }

        if (currentSegmentIndex >= 0 &&
            currentSegmentIndex < choicesByStep.length &&
            choiceIndex >= 0 &&
            choiceIndex < choicesByStep[currentSegmentIndex].length) {
          userChoices.add(choicesByStep[currentSegmentIndex][choiceIndex]);
          totalPoints += pointsForChoices[currentSegmentIndex][choiceIndex];
        }

        currentSegmentIndex++;
        stopwatch.stop();
        timeSpentOnSegment = (stopwatch.elapsedMilliseconds ~/ 1000).toInt();
        stopwatch.reset();
        stopwatch.start();
        _confettiController.play();

        if (currentSegmentIndex >= storySegments.length) {
          _audioPlayer.stop();
          gameEnded = true;
          _showGameSummary();
        }
      });
    }
  }

  // Fix similar issue in _showGameSummary method - update username reference
  Future<void> _showGameSummary() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Adventure Complete!',
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Points', totalPoints.toString()),
                      SizedBox(height: 8),
                      _buildSummaryRow('Time Spent', '$timeSpentOnSegment seconds'),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          int? userId = await getCurrentUserId();
                          if (userId != null) {
                            await DatabaseHelper().saveGameProgress(
                              userId,
                              widget.game.id!,
                              totalPoints,
                              totalPoints,
                              timeSpentOnSegment,
                            );

                            // Use retrieved username value instead of possibly null username
                            if (username.isNotEmpty) {
                              await DatabaseHelper().markGameAsPlayedForUser(
                                widget.game.id!,
                                username,
                              );
                            }

                            Navigator.of(context).pop();
                          } else {
                            _showSnackBar('Unable to identify user. Progress may not be saved.', isError: true);
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: secondaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text(
                                  'Error',
                                  style: GoogleFonts.poppins(
                                    color: accentColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Failed to save game progress. Please try again.',
                                  style: GoogleFonts.inter(color: accentColor),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'OK',
                                      style: GoogleFonts.inter(
                                        color: accentColor.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(
                          color: accentColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _checkGameStatus() async {
    try {
      await _getUsername();

      // Fix: Only show error if username is empty after both retrieval attempts
      if (username.isEmpty) {
        _showSnackBar('User not logged in!', isError: true);
        return;
      }

      bool isGamePlayed = await DatabaseHelper().isGamePlayedForUser(
        widget.game.id!,
        username,
      );

      if (isGamePlayed) {
        setState(() {
          gameEnded = true;
        });
      } else {
        bool isGameLocked = await DatabaseHelper().isGameLockedForUser(
          widget.game.id!,
          username,
        );

        if (isGameLocked) {
          setState(() {
            currentSegmentIndex = 0;
            totalPoints = 0;
            gameEnded = false;
            userChoices.clear();
            stopwatch.reset();
            stopwatch.start();
          });
        } else {
          setState(() {
            currentSegmentIndex = 0;
            totalPoints = 0;
            gameEnded = false;
            userChoices.clear();
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error checking game status: $e', isError: true);
    }
  }

// Also fix the getCurrentUserId method to be consistent with username retrieval
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('current_user_id');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          widget.game.title,
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: gameEnded ? _buildGameEndScreen() : _buildGamePlayScreen(),
      ),
      floatingActionButton: !gameEnded ? FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: () => _nextSegment(-1),
        icon: Icon(Icons.skip_next, color: primaryColor),
        label: Text(
          'Skip',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ) : null,
    );
  }

  Widget _buildGameEndScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            color: Colors.amber,
            size: 64,
          ),
          SizedBox(height: 24),
          Text(
            '🎉 Adventure Complete! 🎉',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _buildEndGameStat('Total Points Earned', totalPoints.toString()),
                SizedBox(height: 12),
                _buildEndGameStat('Time Spent', '$timeSpentOnSegment seconds'),
              ],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Return to Games',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndGameStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGamePlayScreen() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: secondaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LinearProgressIndicator(
            value: (currentSegmentIndex + 1) / storySegments.length,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 8,
          ),
        ),
        SizedBox(height: 24),

        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withOpacity(0.1)),
            ),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Center(
                key: ValueKey<int>(currentSegmentIndex),
                child: Text(
                  storySegments[currentSegmentIndex],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            colors: [accentColor, Colors.amber, Colors.blue],
            gravity: 0.3,
          ),
        ),

        SizedBox(height: 24),

        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: choicesByStep[currentSegmentIndex].length,
            itemBuilder: (context, index) {
              final choice = choicesByStep[currentSegmentIndex][index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: accentColor,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: gameEnded ? null : () => _nextSegment(index),
                  child: Text(
                    choice,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


//
class ManageLockedGamesScreen extends StatefulWidget {
  @override
  _ManageLockedGamesScreenState createState() => _ManageLockedGamesScreenState();
}

class _ManageLockedGamesScreenState extends State<ManageLockedGamesScreen> {
  static const Color primaryColor = Color(0xFF2D3250);
  static const Color accentColor = Color(0xFFF4EEE0);
  static const Color backgroundColor = Color(0xFF153448);
  static const Color cardColor = Color(0xFF1A4258);
  static const Color lockedColor = Color(0xFF424242);
  static const Color unlockedColor = Color(0xFF4CAF50);

  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<GameInfo> games = [
    GameInfo(
      title: 'Hello World',
      description: 'Learn the basics of C programming with a simple Hello World program',
      level: 'Basic',
      isUnlocked: false,
      requiredPoints: 250,
      icon: Icons.code,
      secretNavigation: true,
    ),
    GameInfo(
      title: 'Variable Explorer',
      description: 'Master variable declaration and usage in C',
      level: 'Basic',
      isUnlocked: false,
      requiredPoints: 500,
      icon: Icons.science,
      secretNavigation: false,
    ),
    GameInfo(
      title: 'Loop Adventure',
      description: 'Learn to use for, while, and do-while loops effectively',
      level: 'Intermediate',
      isUnlocked: false,
      requiredPoints:1000 ,
      icon: Icons.loop,
      secretNavigation: false,
    ),
    GameInfo(
      title: 'Array Challenge',
      description: 'Manipulate arrays and understand memory allocation',
      level: 'Intermediate',
      isUnlocked: false,
      requiredPoints: 1500,
      icon: Icons.grid_on,
      secretNavigation: false,
    ),
    GameInfo(
      title: 'Code Worm',
      description: 'Navigate through code segments to find bugs and fix them',
      level: 'Advanced',
      isUnlocked: false,
      requiredPoints: 2000,
      icon: Icons.bug_report,
      secretNavigation: false,
    ),
    GameInfo(
      title: 'Pointer Master',
      description: 'Understand and use pointers like a professional',
      level: 'Advanced',
      isUnlocked: false,
      requiredPoints: 2500,
      icon: Icons.alt_route,
      secretNavigation: false,
    ),
  ];


  int userPoints = 0; // Initialize user points

  @override
  void initState() {
    super.initState();
    _loadUserPoints(); // Load user points based on totalScore
  }

  Future<void> _loadUserPoints() async {
    final user = await _dbHelper.getCurrentUser();
    if (user == null) {
      debugPrint('No user is logged in.');
      return;
    }

    final userId = user['id'] as int;

    final gameScores = await _dbHelper.getGameScores(userId);
    int totalGameScore = gameScores.fold(0, (sum, game) => sum + (game['score'] ?? 0) as int);
    int totalPointsEarned = gameScores.fold(0, (sum, game) => sum + (game['total_points'] ?? 0) as int);
    final assessments = await _dbHelper.fetchSubmittedAnswers(userId);
    int totalAssessmentPoints = assessments.fold(0, (sum, assessment) => sum + (assessment['updated_points'] ?? 0) as int);
    final highScore = await _dbHelper.getHighScore();

    int totalScore = totalGameScore + totalAssessmentPoints + highScore + totalPointsEarned;

    setState(() {
      userPoints = totalScore;
    });

    _loadGameUnlockStatus(userId);
  }

  Future<void> _loadGameUnlockStatus(int userId) async {
    try {
      final unlockedGames = await _dbHelper.getUnlockedGames(userId);

      setState(() {
        for (var game in games) {
          game.isUnlocked = unlockedGames.contains(game.title);
        }
      });
    } catch (e) {
      debugPrint("Error loading game unlock status: $e");
    }
  }


  void _unlockGame(int index) async {
    debugPrint('Attempting to unlock game at index: $index');

    final user = await _dbHelper.getCurrentUser();
    if (user == null) {
      debugPrint('No user is logged in.');
      return;
    }

    final userId = user['id'] as int;
    final gameId = index + 1;
    final requiredPoints = games[index].requiredPoints;

    if (!games[index].isUnlocked && userPoints >= requiredPoints) {
      debugPrint('Unlocking game...');

      try {
        // Save the unlocked game status to the database
        await _dbHelper.unlockGame(userId, gameId);  // Assuming you have a method to update the unlocked game in the database

        setState(() {
          games[index].isUnlocked = true;
          userPoints -= requiredPoints;
        });

        debugPrint('Game state updated in UI.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${games[index].title} unlocked successfully!'),
            backgroundColor: unlockedColor,
          ),
        );
      } catch (e) {
        debugPrint('Error unlocking game: $e');
      }
    } else {
      debugPrint('Not enough points to unlock the game.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough points to unlock ${games[index].title}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _playGame(GameInfo game) {
    // If the game has secret navigation or is the Code Worm game itself, navigate to Code Worm Game
    if (game.secretNavigation || game.title == 'Code Worm') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CodeWormGame()),
      );
    } else if (game.isUnlocked) {
      // Navigate to other games based on title
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${game.title}...'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locked Games',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: accentColor),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensure row takes minimal space
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '$userPoints',
                      style: GoogleFonts.poppins(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learn C Programming Step by Step',
              style: GoogleFonts.poppins(
                color: accentColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Unlock games by earning points. Complete challenges to progress.',
              style: GoogleFonts.poppins(
                color: accentColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    color: game.isUnlocked ? cardColor : lockedColor.withOpacity(0.8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: game.isUnlocked ? unlockedColor.withOpacity(0.5) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => game.isUnlocked ? _playGame(game) : _unlockGame(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                game.icon,
                                color: accentColor,
                                size: 26,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and level in a row with flexible width
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          game.title,
                                          style: GoogleFonts.poppins(
                                            color: accentColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getLevelColor(game.level),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          game.level,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    game.description,
                                    style: GoogleFonts.poppins(
                                      color: accentColor.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!game.isUnlocked)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.star, color: Colors.amber, size: 14),
                                              SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  '${game.requiredPoints} pts needed',
                                                  style: GoogleFonts.poppins(
                                                    color: accentColor.withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Text(
                                          'Unlocked',
                                          style: GoogleFonts.poppins(
                                            color: unlockedColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      Icon(
                                        game.isUnlocked ? Icons.play_circle_filled : Icons.lock,
                                        color: game.isUnlocked ? unlockedColor : accentColor.withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Basic':
        return Colors.green;
      case 'Intermediate':
        return Colors.blue;
      case 'Advanced':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}



class GameInfo {
  final String title;
  final String description;
  final String level;
  bool isUnlocked;
  final int requiredPoints;
  final IconData icon;
  final bool secretNavigation;

  GameInfo({
    required this.title,
    required this.description,
    required this.level,
    required this.isUnlocked,
    required this.requiredPoints,
    required this.icon,
    this.secretNavigation = false,
  });
}


//CODING ASSESSMENT
class CProgrammingCodingAssessment extends StatefulWidget {
  @override
  _CProgrammingCodingAssessmentState createState() => _CProgrammingCodingAssessmentState();
}

class _CProgrammingCodingAssessmentState extends State<CProgrammingCodingAssessment> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  List<Map<String, dynamic>> _assessments = [];

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _loadAssessments() async {
    try {
      final assessments = await _databaseHelper.fetchAssessments();
      setState(() {
        _assessments = assessments;
      });
    } catch (e) {
      _showSnackBar('Failed to load assessments: $e', isError: true);
    }
  }

  void _showLoadingSpinner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CircularProgressIndicator(
              color: accentColor,
            ),
          ),
        );
      },
    );
  }

  void _navigateToAssessmentScreen(Map<String, dynamic> assessment) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentAnswerScreen(assessment: assessment),
      ),
    );
  }

  void _answerAssessment(Map<String, dynamic> assessment) {
    _showLoadingSpinner();
    Future.delayed(Duration(seconds: 1), () {
      _navigateToAssessmentScreen(assessment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: accentColor),
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Coding Assessment',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _loadAssessments,
            tooltip: 'Refresh Assessments',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          ),
        ),
        child: _assessments.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: accentColor.withOpacity(0.6),
              ),
              SizedBox(height: 16),
              Text(
                'No assessments available',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _assessments.length,
          itemBuilder: (context, index) {
            final assessment = _assessments[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              color: secondaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          child: Icon(Icons.code, color: accentColor),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assessment['title'],
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                assessment['description'],
                                style: GoogleFonts.inter(
                                  color: accentColor.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Points: ${assessment['points'] ?? 0}',
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () => _answerAssessment(assessment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Take Assessment',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}

class AssessmentAnswerScreen extends StatefulWidget {
  final Map<String, dynamic> assessment;

  AssessmentAnswerScreen({required this.assessment});

  @override
  _AssessmentAnswerScreenState createState() => _AssessmentAnswerScreenState();
}

class _AssessmentAnswerScreenState extends State<AssessmentAnswerScreen> {
  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  late CodeController _codeController;
  String feedback = "";
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '// Enter your C code here\n',
      language: cpp,
    );
    _codeController.addListener(_checkSyntax);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }
  String executionOutput = "";
  bool _hasUserTyped = false;
  bool isRunning = false;// Track if the user has started typing

  void _checkSyntax() {
    String code = _codeController.text.trim();

    // Mark that the user has started typing
    if (!_hasUserTyped && code.isNotEmpty) {
      _hasUserTyped = true;
    }

    // If the user hasn't typed anything, clear feedback
    if (!_hasUserTyped || code.isEmpty || _isCommentOnly(code)) {
      setState(() {
        feedback = "";
      });
      return;
    }

    // Validate syntax and provide feedback
    setState(() {
      feedback = _validateSyntax(code);
    });
  }

// Helper function to check if the code only contains comments
  bool _isCommentOnly(String code) {
    RegExp commentOnlyPattern = RegExp(r'^\s*(//.*|/\*[\s\S]*?\*/)\s*$');
    return commentOnlyPattern.hasMatch(code);
  }

// Function to validate syntax and return appropriate feedback
  String _validateSyntax(String code) {
    if (!code.contains("#include <stdio.h>")) {
      return "❌ Error: Missing #include <stdio.h> directive.";
    }
    if (code.contains("main") && !code.contains(";")) {
      return "❌ Error: Missing semicolon.";
    }
    if (code.contains("{") && !code.contains("}")) {
      return "❌ Error: Unmatched braces.";
    }
    if (code.contains("int") && !code.contains("return")) {
      return "❌ Error: Missing return statement in function.";
    }
    if (code.contains("x") && !code.contains("int x")) {
      return "❌ Error: Variable 'x' is undeclared.";
    }
    if (code.contains("if") && (!code.contains("(") || !code.contains(")"))) {
      return "❌ Error: Missing condition in 'if' statement.";
    }
    if (code.contains("printf") && !code.contains("(")) {
      return "❌ Error: Missing parentheses in function call.";
    }
    if (code.contains("=") && code.contains("==")) {
      return "❌ Error: Using '==' for assignment instead of '='.";
    }
    if (!code.contains("{") || !code.contains("}")) {
      return "❌ Error: No braces found.";
    }

    return "✅ Syntax looks good! You can submit when ready.";
  }

  void _executeCode() async {
    String userCode = _codeController.text.trim();

    if (userCode.isEmpty) {
      _showSnackBar("⚠️ Code cannot be empty!", isError: true);
      return;
    }

    setState(() {
      isRunning = true;
      executionOutput = "⏳ Running...";
    });

    try {
      // Check if we're in development mode or if the API is not reachable
      bool isApiAccessible = await _checkApiAccessibility();

      if (isApiAccessible) {
        // Try to send to API if it's accessible
        await _sendToApiForExecution(userCode);
      } else {
        // If API is not accessible, use the local fallback
        _localExecutionSimulation(userCode);
      }
    } catch (e) {
      setState(() {
        executionOutput = "❌ Error: ${e.toString()}";
        isRunning = false;
      });
    }
  }

// Check if the API is accessible
  Future<bool> _checkApiAccessibility() async {
    try {
      final Uri apiUrl = Uri.parse('http://localhost:5000/');
      final response = await http.get(apiUrl).timeout(
        Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('API connection timed out');
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// Send code to API for execution
  Future<void> _sendToApiForExecution(String userCode) async {
    try {
      final Uri apiUrl = Uri.parse('http://localhost:5000/');

      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      final response = await http.post(
        apiUrl,
        headers: headers,
        body: jsonEncode({
          "code": userCode,
          "language": "C",
          "input": ""
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        setState(() {
          executionOutput = "❌ Error: Failed to execute code! (${response.statusCode})\n${response.body}";
          isRunning = false;
        });
        return;
      }

      final jsonResponse = jsonDecode(response.body);
      String resultOutput = jsonResponse['output']?.toString().trim() ?? "⚠️ No Output";

      setState(() {
        executionOutput = resultOutput;
        isRunning = false;
      });
    } catch (e) {
      throw e; // Let the main function handle this
    }
  }

// Local execution simulation (fallback when API is not available)
  void _localExecutionSimulation(String userCode) {
    // Parse and validate basic C code structure
    bool hasMain = userCode.contains("main");
    bool hasInclude = userCode.contains("#include");
    bool hasSemicolons = userCode.contains(";");
    bool hasOpenBrace = userCode.contains("{");
    bool hasCloseBrace = userCode.contains("}");
    bool hasPrintf = userCode.contains("printf");

    // Extract output from printf statements (simple simulation)
    String output = "";

    // Simple validation
    if (!hasInclude) {
      output += "Warning: Missing #include directive\n";
    }

    if (!hasMain) {
      output += "Warning: No main function detected\n";
    }

    if (!hasSemicolons) {
      output += "Error: Missing semicolons\n";
      setState(() {
        executionOutput = output + "\nExecution failed due to syntax errors.";
        isRunning = false;
      });
      return;
    }

    if (!(hasOpenBrace && hasCloseBrace)) {
      output += "Error: Unbalanced braces\n";
      setState(() {
        executionOutput = output + "\nExecution failed due to syntax errors.";
        isRunning = false;
      });
      return;
    }

    // Extract printf content (simplified)
    if (hasPrintf) {
      RegExp printfRegex = RegExp(r'printf\s*\(\s*"(.*?)(?<!\\)"\s*(?:,.*?)?\s*\)\s*;');
      Iterable<RegExpMatch> matches = printfRegex.allMatches(userCode);

      for (var match in matches) {
        if (match.group(1) != null) {
          String printfContent = match.group(1)!;
          // Handle some common escape sequences
          printfContent = printfContent.replaceAll("\\n", "\n");
          printfContent = printfContent.replaceAll("\\t", "\t");
          output += printfContent;
        }
      }
    } else {
      output += "[Program executed with no visible output]";
    }

    // Add a success message if there were no warnings or errors
    if (output.isEmpty || (!output.contains("Warning") && !output.contains("Error"))) {
      output = "[Program executed successfully]\n" + output;
    }

    setState(() {
      executionOutput = output;
      isRunning = false;
    });
  }

  void _showLoadingSpinner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CircularProgressIndicator(
              color: accentColor,
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(color: accentColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitAnswer() async {
    if (_codeController.text.trim().isEmpty) {
      _showErrorDialog('Code cannot be empty!');
      return;
    }

    if (feedback.contains("Error")) {
      _showErrorDialog('Fix the syntax errors before submitting.');
      return;
    }

    _showLoadingSpinner();

    try {
      // Directly call insertSubmittedAnswer since it already fetches the user ID
      await _databaseHelper.insertSubmittedAnswer(
        widget.assessment['id'], // Assessment ID
        _codeController.text.trim(), // Submitted Code
      );

      _showSnackBar('Code submitted successfully!');

      Future.delayed(Duration(seconds: 2), () {
        _codeController.clear();
        Navigator.pop(context);
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the available screen size
    final Size screenSize = MediaQuery.of(context).size;
    // Get the keyboard visibility height
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Calculate if keyboard is visible
    final bool isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      // Use resizeToAvoidBottomInset to handle keyboard properly
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: Text(
            'Solve Assessment',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
              ),
            ),
            // Wrap the content in SafeArea to handle notches and system UI
            child: SafeArea(
              child: Column(
                  children: [
              Expanded(
              child: SingleChildScrollView(
              // Enable physics to make scrolling smoother
              physics: AlwaysScrollableScrollPhysics(),
              // Add padding to avoid edge of screen
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Assessment details card
              Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assessment['title'],
                    style: GoogleFonts.poppins(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.assessment['description'],
                    style: GoogleFonts.inter(
                      color: accentColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Code editor container
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code editor header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.code, color: accentColor, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Code Editor',
                              style: GoogleFonts.inter(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: isRunning ? null : _executeCode,
                          icon: Icon(Icons.play_arrow, color: primaryColor),
                          label: Text(
                            'Run',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Code editor field - use a flexible height for better keyboard handling
                  Container(
                    height: isKeyboardVisible
                        ? screenSize.height * 0.25 // Smaller height when keyboard is visible
                        : screenSize.height * 0.35, // Larger height when keyboard is hidden
                    padding: EdgeInsets.all(8),
                    child: CodeTheme(
                      data: CodeThemeData(
                        styles: monokaiSublimeTheme,
                      ),
                      child: CodeField(
                        controller: _codeController,
                        textStyle: GoogleFonts.firaCode(
                          fontSize: 14,
                          color: accentColor,
                        ),

                        // Use adaptive height for code editor
                        maxLines: null,
                        // Add padding to prevent text from being at the edge
                        expands: true,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Execution output
            if (executionOutput.isNotEmpty)
        Padding(
    padding: EdgeInsets.only(top: 16),
    child: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: executionOutput.contains("Error") ? errorColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
    color: executionOutput.contains("Error") ? errorColor.withOpacity(0.2) : Colors.green.withOpacity(0.2),
    ),
    ),
// Execution output container content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Execution Output:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            executionOutput,
            style: GoogleFonts.firaCode(
              fontSize: 14,
              color: executionOutput.contains("Error") ? errorColor : Colors.green,
            ),
          ),
        ],
      ),
    ),
        ),

                    // Feedback display
                    if (!_hasUserTyped || feedback.isEmpty)
                      SizedBox(height: 16)
                    else
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: feedback.contains("Error") ? errorColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: feedback.contains("Error") ? errorColor.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Syntax Feedback:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                feedback,
                                style: GoogleFonts.firaCode(
                                  fontSize: 14,
                                  color: feedback.contains("Error") ? errorColor : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Add extra space at the bottom when keyboard is visible
                    if (isKeyboardVisible)
                      SizedBox(height: 16),
                  ],
              ),
              ),
              ),

                    // Action buttons in a fixed position at the bottom
                    // Use AnimatedContainer to smoothly resize when keyboard appears
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: isKeyboardVisible ? 8 : 16,
                          top: 8
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: primaryColor,
                                  // Adjust padding based on keyboard visibility
                                  padding: EdgeInsets.symmetric(
                                    vertical: isKeyboardVisible ? 12 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: feedback.contains("Error") ? null : _submitAnswer,
                                icon: Icon(Icons.send),
                                label: Text(
                                  'Submit Answer',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    // Adjust font size based on keyboard visibility
                                    fontSize: isKeyboardVisible ? 13 : 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                foregroundColor: accentColor,
                                // Adjust padding based on keyboard visibility
                                padding: EdgeInsets.symmetric(
                                  vertical: isKeyboardVisible ? 12 : 16,
                                  horizontal: isKeyboardVisible ? 16 : 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                              label: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  // Adjust font size based on keyboard visibility
                                  fontSize: isKeyboardVisible ? 13 : 14,
                                ),
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
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}




//PROGRESS TRACKER
class ProgressTracker extends StatefulWidget {
  @override
  _ProgressTrackerState createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker> {
  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red
  static const Color successColor = Color(0xFF81C784);    // Soft green

  int totalQuestions = 0;
  int questionsAttempted = 0;
  int correctAnswers = 0;
  double averageResponseTime = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  late int currentUserId;
  double completionRate = 0.0;

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }

      final yesterday = now.subtract(Duration(days: 1));
      if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }

      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _fetchCurrentUserId() async {
    final userId = await getCurrentUserId();
    if (userId != null) {
      setState(() {
        currentUserId = userId;
        _isLoading = false;
      });
      _fetchGameProgress();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User ID not found';
      });
    }
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('current_user_id');
  }

  Future<void> _fetchGameProgress() async {
    try {
      final progressData = await DatabaseHelper().getGameProgress(currentUserId);
      if (progressData.isNotEmpty) {
        setState(() {
          totalQuestions = progressData.length;
          questionsAttempted = progressData.where((e) => e['score'] > 0).length;
          correctAnswers = progressData.fold(0, (sum, e) => sum + (e['score'] > 0 ? 1 : 0));
          completionRate = _calculateCompletionRate();
        });
      } else {
        setState(() {
          _errorMessage = 'No progress data found.';
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching progress: $e', isError: true);
    }
  }

  double _calculateCompletionRate() {
    return (totalQuestions > 0) ? (questionsAttempted / totalQuestions) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: accentColor),
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Progress Tracker',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_events, color: accentColor), // Leaderboard Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageAnalyticsScreen()),
              );
            },
            tooltip: 'View Leaderboards',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _fetchGameProgress,
            tooltip: 'Refresh Progress',
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          ),
        ),
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(color: accentColor),
        )
            : _errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: errorColor,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: GoogleFonts.inter(
                  color: errorColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchGameProgress,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        )
            : FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper().getGameProgress(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: accentColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.inter(
                    color: errorColor,
                    fontSize: 18,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 64,
                      color: accentColor.withOpacity(0.6),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No progress data available',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final progressData = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: progressData.length,
              itemBuilder: (context, index) {
                final progress = progressData[index];
                double gameCompletionRate = (progress['score'] / 100).clamp(0.0, 1.0);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: secondaryColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.videogame_asset,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'C Programming Game',
                                    style: GoogleFonts.inter(
                                      color: accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Score: ${progress['score']}',
                                        style: GoogleFonts.inter(
                                          color: accentColor.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accentColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              LinearPercentIndicator(
                                lineHeight: 8,
                                percent: gameCompletionRate,
                                progressColor: successColor,
                                backgroundColor: primaryColor.withOpacity(0.3),
                                barRadius: Radius.circular(4),
                                padding: EdgeInsets.zero,
                                animation: true,
                                animationDuration: 1000,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(gameCompletionRate * 100).toStringAsFixed(1)}% Complete',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.timer,
                          'Time Spent',
                          '${progress['time_spent']} seconds',
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Started',
                          _formatDateTime(progress['created_at']),
                        ),
                        if (progress['completed_at'] != null) ...[
                          SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.check_circle,
                            'Completed',
                            _formatDateTime(progress['completed_at']),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor.withOpacity(0.8), size: 16),
          SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.inter(
              color: accentColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// Common method to build placeholder screens

class ProfileSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen()._buildFeatureScreen(
        'Profile Settings', 'Profile Settings - Coming Soon!');
  }
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('current_user_id');
      _usernameController.text = prefs.getString('current_username') ?? '';
    });
  }

  Future<void> _updateProfile() async {
    if (_userId == null) return;

    String newUsername = _usernameController.text.trim();
    String newPassword = _passwordController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    await DatabaseHelper().updateUser(
      _userId!,
      newUsername,
      newPassword.isNotEmpty ? newPassword : null,
      'student',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_username', newUsername);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen()._buildFeatureScreen(
        'Notification Settings', 'Notification Settings - Coming Soon!');
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen()._buildFeatureScreen(
        'Privacy Settings', 'Privacy Settings - Coming Soon!');
  }
}

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardScreen()
        ._buildFeatureScreen('Help & Support', 'Help & Support - Coming Soon!');
  }
}
