// lib/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:gamified_cpla_v1/database/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:gamified_cpla_v1/models/quiz.dart';
import 'package:gamified_cpla_v1/models/game.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart' as flame;
import 'package:gamified_cpla_v1/games/code_worm_adventure.dart'; // Import the game
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

// Define the color palette as constants for easy reuse
const Color primaryColor = Color(0xff153448);
const Color secondaryColor = Color(0xffDFD0B8); // Light Beige
const Color accentColor = Colors.white; // Pure White

class AdminDashboardScreen extends StatelessWidget {
  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250); // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769); // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0); // Cream white
  static const Color backgroundColor = Color(0xFF153448); // Dark teal
  static const Color cardHoverColor = Color(0xFF676F9D); // Muted purple

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Manage Users',
      'icon': Icons.group,
      'screen': ManageUsersScreen()
    },
    {
      'title': 'Manage Tutorials',
      'icon': Icons.school,
      'screen': ManageTutorialsScreen()
    },
    {
      'title': 'Manage Games',
      'icon': Icons.games,
      'screen': ManageInteractiveGamesScreen()
    },
    {
      'title': 'Manage Locked Games',
      'icon': Icons.school,
      'screen': ManageLockedGamesScreen()
    },
    {
      'title': 'Manage Assessments',
      'icon': Icons.code,
      'screen': ManageCodingAssessmentsScreen()
    },
    {
      'title': 'Manage Analytics',
      'icon': Icons.analytics,
      'screen': ManageAnalyticsScreen()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar('Admin Dashboard'),
      drawer: _buildDrawer(context),
      body: _buildFeatureGrid(context),
      backgroundColor: backgroundColor,
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      elevation: 0,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: accentColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: primaryColor,
      iconTheme: IconThemeData(color: accentColor),
      actions: [
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.75,
      child: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
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
                    'Admin User',
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'admin@example.com',
                    style: GoogleFonts.inter(
                      color: accentColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, 'Edit Profile', Icons.edit_outlined,
                EditProfileScreen()),
            _buildDrawerItem(context, 'Change Password', Icons.lock_outline,
                ChangePasswordScreen()),
            _buildDrawerItem(
                context, 'Notification Settings', Icons.notifications_outlined,
                NotificationSettingsScreen()),
            _buildDrawerItem(
                context, 'Privacy Settings', Icons.privacy_tip_outlined,
                PrivacySettingsScreen()),
            _buildDrawerItem(context, 'Help & Support', Icons.help_outline,
                HelpSupportScreen()),
            Divider(color: accentColor.withOpacity(0.2), thickness: 1),
            _buildDrawerItem(context, 'Logout', Icons.logout, LoginScreen(),
                isLogoutButton: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon,
      Widget? screen, {bool isLogoutButton = false}) {
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
        onTap: () {
          if (isLogoutButton) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => screen!));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => screen!));
          }
        },
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
              context,
              feature['title'],
              feature['icon'],
              feature['screen'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon,
      Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: secondaryColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => screen)),
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
  // Placeholder method for feature screens
  Widget _buildFeatureScreen(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: accentColor)),
        backgroundColor: Color(0xff153448), // Your card background color
        iconTheme: IconThemeData(
          color:
          Colors.white, // This changes the back arrow button color to white
        ),
      ),
      body: Container(
        color: Color(0xff153448), // Set the body background color
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _users = [];

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  @override
  void initState() {
    super.initState();
    _refreshUserList();
  }

  Future<void> _refreshUserList() async {
    List<Map<String, dynamic>> users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final _formKey = GlobalKey<FormState>();
    String username = user?['username'] ?? '';
    String password = '';
    String role = user?['role'] ?? 'user';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            user == null ? 'Add User' : 'Edit User',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      label: 'Username',
                      initialValue: username,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                      onSaved: (value) => username = value!.trim(),
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      isPassword: true,
                      validator: user == null
                          ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      }
                          : null,
                      onSaved: (value) => password = value!.trim(),
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Role',
                      value: role,
                      items: ['admin', 'user'],
                      onChanged: (value) => setState(() => role = value!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                user == null ? 'Add' : 'Update',
                style: GoogleFonts.inter(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _handleSubmit(_formKey, user, username, password, role),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    bool isPassword = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: isPassword,
      style: GoogleFonts.inter(color: accentColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.3),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.inter(color: accentColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.3),
      ),
      dropdownColor: secondaryColor,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.capitalize(),
            style: GoogleFonts.inter(color: accentColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _confirmDelete(int userId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete User',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this user? This action cannot be undone.',
            style: GoogleFonts.inter(color: accentColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _dbHelper.deleteUser(userId);
      _refreshUserList();
      _showSnackBar('User deleted successfully');
    }
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Manage Users',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _refreshUserList,
            tooltip: 'Refresh List',
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
        child: _users.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: accentColor.withOpacity(0.6),
              ),
              SizedBox(height: 16),
              Text(
                'No users found',
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
          itemCount: _users.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> user = _users[index];
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
                  child: Text(
                    user['username'][0].toUpperCase(),
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  user['username'],
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Role: ${user['role']}',
                  style: GoogleFonts.inter(
                    color: accentColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: Colors.lightBlueAccent),
                      tooltip: 'Edit User',
                      onPressed: () => _showUserDialog(user: user),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: errorColor),
                      tooltip: 'Delete User',
                      onPressed: () => _confirmDelete(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: () => _showUserDialog(),
        icon: Icon(Icons.add, color: primaryColor),
        label: Text(
          'Add User',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ),
    );
  }

  void _handleSubmit(GlobalKey<FormState> formKey, Map<String, dynamic>? user,
      String username, String password, String role) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Check if any of the required fields are empty
      if (username.isEmpty || password.isEmpty || role.isEmpty) {
        _showSnackBar('Username, password, and role cannot be empty', isError: true);
        return;
      }

      try {
        if (user == null) {
          await _dbHelper.insertUser(username, password, role);
          _showSnackBar('User added successfully');
        } else {
          await _dbHelper.updateUser(
            user['id'],
            username,
            password.isEmpty ? null : password,
            role,
          );
          _showSnackBar('User updated successfully');
        }
        Navigator.of(context).pop();
        _refreshUserList();
      } catch (e) {
        Navigator.of(context).pop();
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }
}


// Extension to capitalize the first letter of a string
extension StringCasingExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

// Placeholder screens for other features with consistent theming
class ManageTutorialsScreen extends StatefulWidget {
  @override
  _ManageTutorialsScreenState createState() => _ManageTutorialsScreenState();
}

class _ManageTutorialsScreenState extends State<ManageTutorialsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _url = '';
  String? _filePath;

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _tutorialsFuture;

  @override
  void initState() {
    super.initState();
    _refreshTutorials();
  }

  void _refreshTutorials() {
    setState(() {
      _tutorialsFuture = _dbHelper.getAllTutorials();
    });
  }

  void _showTutorialForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Add Tutorial',
              style: GoogleFonts.poppins(
                color: accentColor,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              )
          ),
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor),
                      ),
                      filled: true,
                      fillColor: primaryColor.withOpacity(0.3),
                    ),
                    style: GoogleFonts.inter(color: accentColor),
                    onSaved: (value) => _title = value!.trim(),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor),
                      ),
                      filled: true,
                      fillColor: primaryColor.withOpacity(0.3),
                    ),
                    style: GoogleFonts.inter(color: accentColor),
                    maxLines: 3,
                    onSaved: (value) => _description = value!.trim(),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'URL Video',
                      labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentColor),
                      ),
                      filled: true,
                      fillColor: primaryColor.withOpacity(0.3),
                    ),
                    style: GoogleFonts.inter(color: accentColor),
                    onSaved: (value) => _url = value!.trim(),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a URL Video or upload a file'
                        : null,
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _filePath != null ? _filePath!.split('/').last : 'No File Selected',
                            style: GoogleFonts.inter(
                              color: accentColor.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _selectFile,
                          icon: Icon(Icons.upload_file, size: 18),
                          label: Text('Upload File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: accentColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Add Tutorial',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _dbHelper.insertTutorial(
          _title,
          _description,
          _url,
          _filePath,
        );
        _showSnackBar('Tutorial Added Successfully');
        _formKey.currentState!.reset();
        setState(() {
          _filePath = null;
        });
        _refreshTutorials();
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Error adding tutorial: $e', isError: true);
      }
    }
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

  Future<void> _deleteTutorial(int id, String? filePath) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Tutorial',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this tutorial? This action cannot be undone.',
            style: GoogleFonts.inter(color: accentColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        if (filePath != null) {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        }
        await _dbHelper.deleteTutorial(id);
        _showSnackBar('Tutorial Deleted Successfully');
        _refreshTutorials();
      } catch (e) {
        _showSnackBar('Error deleting tutorial: $e', isError: true);
      }
    }
  }

  void _editTutorial(Map<String, dynamic> tutorial) {
    final _editFormKey = GlobalKey<FormState>();
    String editedTitle = tutorial['title'];
    String editedDescription = tutorial['description'];
    String editedUrl = tutorial['url'];
    String? editedFilePath = tutorial['filePath'];

    showDialog(
        context: context,
        builder: (context) {
      return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(
    'Edit Tutorial',
    style: GoogleFonts.poppins(
    color: accentColor,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    ),
    ),
    content: Form(
    key: _editFormKey,
    child: SingleChildScrollView(
    child: Column(
    children: [
    TextFormField(
    initialValue: editedTitle,
    decoration: InputDecoration(
    labelText: 'Title',
    labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor),
    ),
    filled: true,
    fillColor: primaryColor.withOpacity(0.3),
    ),
    style: GoogleFonts.inter(color: accentColor),
    onSaved: (value) => editedTitle = value!.trim(),
    validator: (value) => value == null || value.trim().isEmpty
    ? 'Please enter a title'
        : null,
    ),
    SizedBox(height: 16),
    TextFormField(
    initialValue: editedDescription,
    decoration: InputDecoration(
    labelText: 'Description',
    labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor),
    ),
    filled: true,
    fillColor: primaryColor.withOpacity(0.3),
    ),
    style: GoogleFonts.inter(color: accentColor),
    maxLines: 3,
    onSaved: (value) => editedDescription = value!.trim(),
    validator: (value) => value == null || value.trim().isEmpty
    ? 'Please enter a description'
        : null,
    ),
    SizedBox(height: 16),
    TextFormField(
    initialValue: editedUrl,
    decoration: InputDecoration(
    labelText: 'URL Video',
    labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accentColor),
    ),
    filled: true,
    fillColor: primaryColor.withOpacity(0.3),
    ),
    style: GoogleFonts.inter(color: accentColor),
    onSaved: (value) => editedUrl = value!.trim(),
    validator: (value) => value == null || value.trim().isEmpty
    ? 'Please enter a URL Video or upload a file'
        : null,
    ),
    SizedBox(height: 24),
    Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: primaryColor.withOpacity(0.3),borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accentColor.withOpacity(0.2)),
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video File',
            style: GoogleFonts.inter(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  editedFilePath != null
                      ? editedFilePath!.split('/').last
                      : 'No file selected',
                  style: GoogleFonts.inter(
                    color: accentColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                  );
                  if (result != null) {
                    editedFilePath = result.files.single.path;
                    _showSnackBar('Video file selected');
                  }
                },
                icon: Icon(Icons.upload_file, size: 18),
                label: Text('Change File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: accentColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editFormKey.currentState!.validate()) {
                _editFormKey.currentState!.save();
                try {
                  await _dbHelper.updateTutorial(
                    tutorial['id'],
                    editedTitle,
                    editedDescription,
                    editedUrl,
                    editedFilePath,
                  );
                  _showSnackBar('Tutorial Updated Successfully');
                  _refreshTutorials();
                  Navigator.pop(context);
                } catch (e) {
                  _showSnackBar('Error updating tutorial: $e', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Update Tutorial',
              style: GoogleFonts.inter(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
        },
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    } else {
      setState(() {
        _filePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Manage Tutorials',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _refreshTutorials,
            tooltip: 'Refresh List',
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
          future: _tutorialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: accentColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading tutorials: ${snapshot.error}',
                  style: GoogleFonts.inter(color: accentColor),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
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

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tutorial = snapshot.data![index];
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
                      child: Icon(Icons.play_lesson, color: accentColor),
                    ),
                    title: Text(
                      tutorial['title'],
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      tutorial['description'],
                      style: GoogleFonts.inter(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Colors.lightBlueAccent),
                          tooltip: 'Edit Tutorial',
                          onPressed: () => _editTutorial(tutorial),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: errorColor),
                          tooltip: 'Delete Tutorial',
                          onPressed: () => _deleteTutorial(tutorial['id'], tutorial['filePath']),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: _showTutorialForm,
        icon: Icon(Icons.add, color: primaryColor),
        label: Text(
          'Add Tutorial',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ),
    );
  }
}

// ManageInteractiveGamesScreen
class ManageInteractiveGamesScreen extends StatefulWidget {
  @override
  _ManageInteractiveGamesScreenState createState() => _ManageInteractiveGamesScreenState();
}

class _ManageInteractiveGamesScreenState extends State<ManageInteractiveGamesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  var _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGameList();
  }

  Future<void> _fetchGameList() async {
    try {
      setState(() => _isLoading = true);
      _games = (await _dbHelper.getAllGames()).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to fetch games: ${e.toString()}', isError: true);
      }
    }
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

  Future<void> _confirmDelete(int gameId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Game',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this game? This action cannot be undone.',
            style: GoogleFonts.inter(color: accentColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _dbHelper.deleteGame(gameId);
        _fetchGameList();
        _showSnackBar('Game deleted successfully!');
      } catch (e) {
        _showSnackBar('Failed to delete game: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Manage Interactive Games',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _fetchGameList,
            tooltip: 'Refresh List',
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
            : _games.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.gamepad_outlined,
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
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              color: secondaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                collapsedIconColor: accentColor,
                iconColor: accentColor,
                leading: CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Icon(Icons.gamepad, color: accentColor),
                ),
                title: Text(
                  game.title,
                  style: GoogleFonts.inter(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Difficulty: ${game.difficultyLevel}',
                  style: GoogleFonts.inter(
                    color: accentColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Description:', game.description),
                        SizedBox(height: 8),
                        _buildInfoRow('Stage:', game.adventureStage),
                        SizedBox(height: 8),
                        _buildInfoRow('Points Reward:', game.pointsReward.toString()),
                        SizedBox(height: 8),
                        _buildInfoRow('Concept:', game.concept),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButton(
                              icon: Icons.visibility,
                              color: Colors.green[400]!,
                              tooltip: 'Play Game',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdventureGameScreen(game: game),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.edit_outlined,
                              color: Colors.lightBlueAccent,
                              tooltip: 'Edit Game',
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameForm(game: game),
                                  ),
                                );
                                if (result == true) _fetchGameList();
                              },
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.delete_outline,
                              color: errorColor,
                              tooltip: 'Delete Game',
                              onPressed: () => _confirmDelete(game.id!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GameForm()),
          );
          if (result == true) _fetchGameList();
        },
        icon: Icon(Icons.add, color: primaryColor),
        label: Text(
          'Add Game',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: accentColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: accentColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
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
//Game Form
class GameForm extends StatefulWidget {
  final Game? game;

  GameForm({this.game});

  @override
  _GameFormState createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> {
  final _formKey = GlobalKey<FormState>();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  String title = "File Stream Frontier";
  String description = "Explore the wilderness of file I/O operations. Read, write, and manipulate files to solve puzzles and uncover the secrets of persistent data!";
// Game Details
  String difficultyLevel = "Beginner-Intermediate";
  String adventureStage = "I/O Wilderness";
  int pointsReward = 500;
// Story and Choices
  String concept = "An adventure focused on file operations where players must correctly implement reading, writing, and error checking to progress through challenges";
  String storyText = "The knowledge of your world is scattered across mysterious files in the I/O Wilderness. You must master file operations to recover lost data and restore civilization.";
  List<String> storySegments = [
    "You need to open a critical file containing survival information",
    "You must write emergency instructions to a new file",
    "You encounter a binary file with important data",
    "You need to update information in an existing file"
  ];
  List<List<String>> choicesByStep = [
    ["Open with fopen() and check if NULL", "Use open() system call directly", "Hard-code the file path and assume it exists"],
    ["Use fprintf() with proper formatting", "Write raw memory blocks", "Use cout to write to the file"],
    ["Use fread() with correct size parameters", "Read the file character by character", "Convert to text file first"],
    ["Use fseek() to position, then write", "Rewrite the entire file", "Create a new file with updated info"]
  ];
  List<int> correctAnswers = [0, 0, 0, 0];
  List<String> consequences = [
    "File opened successfully with proper error handling",
    "Instructions written correctly and formatted for humans",
    "Binary data extracted with optimal efficiency",
    "File updated in-place without data loss"
  ];
// Points for Choices
  List<List<int>> pointsForChoices = [
    [100, 50, 0],
    [100, 50, 0],
    [100, 50, 25],
    [100, 25, 50]
  ];
  bool isPlayed = false;

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      // Initialize with existing game data
      title = widget.game!.title;
      description = widget.game!.description;
      difficultyLevel = widget.game!.difficultyLevel;
      adventureStage = widget.game!.adventureStage;
      pointsReward = widget.game!.pointsReward;
      concept = widget.game!.concept;
      storyText = widget.game!.storyText;
      storySegments = widget.game!.storySegments;
      choicesByStep = widget.game!.choicesByStep;
      pointsForChoices = widget.game!.pointsForChoices;
      correctAnswers = widget.game!.correctAnswers;
      consequences = widget.game!.consequences;
      isPlayed = widget.game!.isPlayed;
    }
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

  void _saveGame() async {
    if (_formKey.currentState!.validate()) {
      final newGame = Game(
        id: widget.game?.id,
        title: title,
        description: description,
        difficultyLevel: difficultyLevel,
        adventureStage: adventureStage,
        pointsReward: pointsReward,
        concept: concept,
        storyText: storyText,
        storySegments: storySegments,
        choicesByStep: choicesByStep,
        pointsForChoices: pointsForChoices,
        correctAnswers: correctAnswers,
        consequences: consequences,
        isPlayed: isPlayed,
      );

      try {
        if (widget.game == null) {
          int result = await DatabaseHelper().insertGame(newGame);
          if (result > 0) {
            Navigator.pop(context, true);
            _showSnackBar('Game added successfully!');
          } else {
            throw Exception('Failed to add game');
          }
        } else {
          int result = await DatabaseHelper().updateGame(newGame);
          if (result > 0) {
            Navigator.pop(context, true);
            _showSnackBar('Game updated successfully!');
          } else {
            throw Exception('Failed to update game');
          }
        }
      } catch (e) {
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Widget _buildTextFormField(
      String label, String initialValue, Function(String) onChanged,
      {bool isRequired = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.inter(color: accentColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: accentColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: errorColor),
          ),
          filled: true,
          fillColor: primaryColor.withOpacity(0.3),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          if (isNumber && value != null && int.tryParse(value) == null) {
            return '$label must be a number';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          widget.game == null ? 'Add Adventure Game' : 'Edit Adventure Game',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSection(
                  'General Information',
                  [
                    _buildTextFormField('Title', title,
                            (value) => setState(() => title = value),
                        isRequired: true),
                    _buildTextFormField('Description', description,
                            (value) => setState(() => description = value),
                        isRequired: true),
                  ],
                ),
                SizedBox(height: 16),
                _buildSection(
                  'Game Details',
                  [
                    _buildTextFormField('Difficulty Level', difficultyLevel,
                            (value) => setState(() => difficultyLevel = value),
                        isRequired: true),
                    _buildTextFormField('Adventure Stage', adventureStage,
                            (value) => setState(() => adventureStage = value),
                        isRequired: true),
                    _buildTextFormField(
                        'Points Reward',
                        pointsReward.toString(),
                            (value) => setState(() => pointsReward = int.parse(value)),
                        isRequired: true,
                        isNumber: true),
                  ],
                ),
                SizedBox(height: 16),_buildSection(
                  'Story and Choices',
                  [
                    _buildTextFormField('Concept', concept,
                            (value) => setState(() => concept = value),
                        isRequired: true),
                    _buildTextFormField('Story Text', storyText,
                            (value) => setState(() => storyText = value),
                        isRequired: true),
                    _buildTextFormField(
                        'Story Segments',
                        storySegments.join(', '),
                            (value) => setState(() => storySegments = value.split(',')),
                        isRequired: true),
                    _buildTextFormField(
                        'Choices by Step',
                        choicesByStep.map((choices) => choices.join(', ')).join(' | '),
                            (value) => setState(() => choicesByStep = value
                            .split('|')
                            .map((step) => step.split(',').toList())
                            .toList()),
                        isRequired: true),
                    _buildTextFormField(
                        'Correct Answers',
                        correctAnswers.join(', '),
                            (value) => setState(() => correctAnswers = value
                            .split(',')
                            .map((e) => int.parse(e.trim()))
                            .toList()),
                        isRequired: true,
                        isNumber: true),
                    _buildTextFormField(
                        'Consequences',
                        consequences.join(', '),
                            (value) => setState(() => consequences = value.split(',')),
                        isRequired: true),
                  ],
                ),
                SizedBox(height: 16),
                _buildSection(
                  'Points for Choices',
                  [
                    _buildTextFormField(
                        'Points for Choices',
                        pointsForChoices
                            .map((stepPoints) => stepPoints.join(', '))
                            .join(' | '),
                            (value) => setState(() {
                          pointsForChoices = value
                              .split('|')
                              .map((step) => step
                              .split(',')
                              .map((e) => int.parse(e))
                              .toList())
                              .toList();
                        }),
                        isRequired: true),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: _saveGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      widget.game == null ? 'Add Game' : 'Update Game',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: accentColor,
          collapsedIconColor: accentColor,
          childrenPadding: EdgeInsets.all(16),
          children: children,
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
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  void _playBackgroundMusic() {
    _audioPlayer.stop();
    _audioPlayer.play(
      AssetSource('assets/audio/background.mp3'),
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

                            await DatabaseHelper().markGameAsPlayedForUser(
                              widget.game.id!,
                              username,
                            );

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
//Manage Lock Games
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
      requiredPoints: 200,
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
    final user = await _dbHelper.getCurrentUser(); // Fetch the current user

    if (user == null) {
      debugPrint('No user is logged in.');
      return;
    }

    final userId = user['id'] as int; // Ensure userId is an int

    // Fetch game scores and progress points
    final gameScores = await _dbHelper.getGameScores(userId);
    int totalGameScore = gameScores.fold(0, (sum, game) => sum + (game['score'] ?? 0) as int);


    // Fetch saved totalPoints from the database
    int totalPointsEarned = gameScores.fold(0, (sum, game) => sum + (game['total_points'] ?? 0) as int);

    final assessments = await _dbHelper.fetchSubmittedAnswers(userId);
    int totalAssessmentPoints = assessments.fold(0, (sum, assessment) => sum + (assessment['updated_points'] ?? 0) as int);
    // Fetch high score for the game
    final highScore = await _dbHelper.getHighScore();

    // Calculate total score including totalPoints from game progress
    int totalScore = totalGameScore + totalAssessmentPoints + highScore + totalPointsEarned;

    setState(() {
      userPoints = totalScore; // Use totalScore as userPoints
    });
  }



  void _unlockGame(int index) {
    if (!games[index].isUnlocked && userPoints >= games[index].requiredPoints) {
      setState(() {
        games[index].isUnlocked = true;
        userPoints -= games[index].requiredPoints; // Deduct points after unlocking
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${games[index].title} unlocked successfully!'),
          backgroundColor: unlockedColor,
        ),
      );
    } else if (!games[index].isUnlocked) {
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
          'C Programming Games',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,

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
// Manage Coding Assessments Screen
class ManageCodingAssessmentsScreen extends StatefulWidget {
  @override
  _ManageCodingAssessmentsScreenState createState() =>
      _ManageCodingAssessmentsScreenState();
}

class _ManageCodingAssessmentsScreenState extends State<ManageCodingAssessmentsScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _assessments = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  String _assessmentType = 'Code Completion';
  String _difficultyLevel = 'Medium';

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

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
    final assessments = await _databaseHelper.fetchAssessments();
    setState(() {
      _assessments = assessments;
    });
  }

  Future<void> _addAssessment(String title, String description, String type,
      String difficulty, int points) async {
    await _databaseHelper.insertAssessment(
        title, description, type, difficulty, points);
    _loadAssessments();
    _titleController.clear();
    _descriptionController.clear();
    _showSnackBar('Assessment added successfully');
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: accentColor),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.3),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.inter(color: accentColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: accentColor.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.3),
      ),
      dropdownColor: secondaryColor,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.inter(color: accentColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _editAssessment(int id, String title, String description,
      String type, String difficulty, String points) async {
    setState(() {
      _titleController.text = title;
      _descriptionController.text = description;
      _pointsController.text = points;
      _assessmentType = type;
      _difficultyLevel = difficulty;
    });

    final _formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Text(
                      'Edit Coding Assessment',
                      style: GoogleFonts.poppins(
                        color: accentColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFormField(
                              label: 'Assessment Title',
                              controller: _titleController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            _buildFormField(
                              label: 'Description',
                              controller: _descriptionController,
                              isMultiline: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            _buildFormField(
                              label: 'Points',
                              controller: _pointsController,
                              isNumber: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter points';
                                }
                                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                  return 'Please enter a valid positive number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Assessment Type',
                              value: _assessmentType,
                              items: ['Code Completion', 'Bug Fixing', 'Problem Solving'],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _assessmentType = value);
                                }
                              },
                            ),
                            SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Difficulty Level',
                              value: _difficultyLevel,
                              items: ['Easy', 'Medium', 'Hard'],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _difficultyLevel = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
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
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await _databaseHelper.updateAssessment(
                                  id,
                                  _titleController.text,
                                  _descriptionController.text,
                                  _assessmentType,
                                  _difficultyLevel,
                                  int.parse(_pointsController.text),
                                );
                                await _loadAssessments();
                                Navigator.pop(context);
                                _showSnackBar('Assessment updated successfully');
                              } catch (e) {
                                _showSnackBar('Failed to update assessment: ${e.toString()}', isError: true);
                              }
                            }
                          },
                          child: Text(
                            'Update',
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
      },
    );
  }
  Future<void> _deleteAssessment(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Assessment',
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this assessment? This action cannot be undone.',
            style: GoogleFonts.inter(color: accentColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: accentColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _databaseHelper.deleteAssessment(id);
        _loadAssessments();
        _showSnackBar('Assessment deleted successfully');
      } catch (e) {
        _showSnackBar('Failed to delete assessment: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showAddAssessmentDialog() async {
    final _formKey = GlobalKey<FormState>();
    _titleController.clear();
    _descriptionController.clear();
    _pointsController.clear();

    await showDialog(
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
    Text(
    'Add Coding Assessment',
    style: GoogleFonts.poppins(
    color: accentColor,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    ),
    ),
    SizedBox(height: 24),
    Form(
    key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormField(
              label: 'Title',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildFormField(
              label: 'Description',
              controller: _descriptionController,
              isMultiline: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildFormField(
              label: 'Points',
              controller: _pointsController,
              isNumber: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'Assessment Type',
              value: _assessmentType,
              items: ['Code Completion', 'Bug Fixing', 'Problem Solving'],
              onChanged: (value) {
                if (value != null) setState(() => _assessmentType = value);
              },
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              label: 'Difficulty Level',
              value: _difficultyLevel,
              items: ['Easy', 'Medium', 'Hard'],
              onChanged: (value) {
                if (value != null) setState(() => _difficultyLevel = value);
              },
            ),
          ],
        ),
      ),

    ),
      SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _addAssessment(
                  _titleController.text,
                  _descriptionController.text,
                  _assessmentType,
                  _difficultyLevel,
                  int.parse(_pointsController.text),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Manage Coding Assessment',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _loadAssessments,
            tooltip: 'Refresh List',
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
                Icons.code_off_outlined,
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
            :ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _assessments.length,
          itemBuilder: (context, index) {
            final assessment = _assessments[index];

            // Check if title and description are available
            final title = assessment['title'] ?? 'No Title Available';
            final description = assessment['description'] ?? 'No Description Available';

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
                  child: Icon(Icons.code, color: accentColor),
                ),
                title: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200), // Limit the width of the title
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis, // Add ellipsis if the title is too long
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        color: accentColor.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow for long descriptions
                      maxLines: 2, // Limit to 2 lines
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            assessment['difficulty'] ?? 'No Difficulty',
                            style: GoogleFonts.inter(
                              color: accentColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text(
                                assessment['points']?.toString() ?? '0',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Make row take minimum space
                    children: [
                      // Assessment Level and Points - Fixed position
                      Container(
                        constraints: BoxConstraints(maxHeight: 56.0), // Match parent constraints
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Take minimum vertical space
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reduced vertical padding
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                assessment['difficulty'] ?? 'No Difficulty',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 11, // Slightly smaller font
                                ),
                              ),
                            ),
                            SizedBox(height: 4), // Reduced spacing
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reduced vertical padding
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 12), // Smaller icon
                                  SizedBox(width: 2), // Reduced spacing
                                  Text(
                                    assessment['points']?.toString() ?? '0',
                                    style: GoogleFonts.inter(
                                      color: accentColor,
                                      fontSize: 11, // Slightly smaller font
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8), // Space between information and buttons
                      // Scrollable Action Buttons - Now in a constrained container
                      Container(
                        height: 56.0, // Match parent height constraint
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row( // Changed from Wrap to Row for horizontal layout
                            children: [
                              _buildActionButton(
                                icon: Icons.visibility_outlined,
                                color: Colors.green[400]!,
                                tooltip: 'View Submissions',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminSubmittedAnswersScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 8), // Manual spacing
                              _buildActionButton(
                                icon: Icons.edit_outlined,
                                color: Colors.lightBlueAccent,
                                tooltip: 'Edit Assessment',
                                onPressed: () => _editAssessment(
                                  assessment['id'],
                                  title,
                                  description,
                                  assessment['type'],
                                  assessment['difficulty'],
                                  assessment['points']?.toString() ?? '0',
                                ),
                              ),
                              SizedBox(width: 8), // Manual spacing
                              _buildActionButton(
                                icon: Icons.delete_outline,
                                color: errorColor,
                                tooltip: 'Delete Assessment',
                                onPressed: () => _deleteAssessment(assessment['id']),
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
          },
        )


        ,
      ),


      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor,
        onPressed: _showAddAssessmentDialog,
        icon: Icon(Icons.add, color: primaryColor),
        label: Text(
          'Add Assessment',
          style: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
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

class AdminSubmittedAnswersScreen extends StatefulWidget {
  @override
  _AdminSubmittedAnswersScreenState createState() => _AdminSubmittedAnswersScreenState();
}

class _AdminSubmittedAnswersScreenState extends State<AdminSubmittedAnswersScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  static const Color primaryColor = Color(0xFF2D3250);
  static const Color secondaryColor = Color(0xFF424769);
  static const Color accentColor = Color(0xFFF4EEE0);
  static const Color backgroundColor = Color(0xFF153448);
  static const Color errorColor = Color(0xFFE57373);

  List<Map<String, dynamic>> _submissions = [];
  Map<int, TextEditingController> _pointsControllers = {}; // Map of controllers

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    final submissions = await _databaseHelper.fetchSubmittedAnswers();
    setState(() {
      _submissions = submissions;
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    for (var submission in _submissions) {
      int submissionId = submission['id'];
      if (!_pointsControllers.containsKey(submissionId)) {
        _pointsControllers[submissionId] = TextEditingController();
      }
    }
  }

  // Method to assign points
  void _assignPoints(int submissionId, int userId, String submittedAnswer) async {
    // Get the points entered in the TextField for this submissionId
    String enteredPoints = _pointsControllers[submissionId]?.text.trim() ?? "";

    // If points are not entered or invalid, show error message
    int score = 0;
    if (enteredPoints.isNotEmpty && int.tryParse(enteredPoints) != null) {
      score = int.parse(enteredPoints);  // Convert entered points to integer
    } else {
      // Show error snack bar if points are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number for points.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Update the points in the database using the DatabaseHelper
      int updatedScore = await _databaseHelper.updatePoints(submissionId, userId, score);

      // Show success or error message based on the result
      if (updatedScore > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Score successfully assigned!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign score. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle any error during the process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning score: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Submitted Answers',
          style: GoogleFonts.poppins(color: accentColor, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _loadSubmissions,
            tooltip: 'Refresh List',
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
        child: _submissions.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: accentColor.withOpacity(0.6)),
              SizedBox(height: 16),
              Text(
                'No submissions available',
                style: GoogleFonts.inter(color: accentColor, fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _submissions.length,
          itemBuilder: (context, index) {
            final submission = _submissions[index];
            final int submissionId = submission['id'];

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              color: secondaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                submission['assessment_title'] ?? 'Unknown Assessment',
                                style: GoogleFonts.inter(color: accentColor, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Submitted by: ${submission['username'] ?? 'Unknown'}',
                                style: GoogleFonts.inter(color: accentColor.withOpacity(0.8), fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Padding to add margin to the left
                                  Padding(
                                    padding: EdgeInsets.only(left: 12), // Adjust the left margin here
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, // Ensure it takes minimal space
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Points: ${submission['updated_points'] ?? 'N/A'}',
                                            style: GoogleFonts.inter(color: accentColor, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  // Icon for Submitted At
                                  Icon(Icons.schedule, color: accentColor.withOpacity(0.6), size: 14),
                                  SizedBox(width: 4),

                                  // Text for Submitted Date with flexible space handling
                                  Flexible(
                                    child: Text(
                                      submission['submitted_at'] ?? 'N/A',
                                      style: GoogleFonts.inter(color: accentColor.withOpacity(0.8), fontSize: 12),
                                      overflow: TextOverflow.ellipsis, // Ensure long text is truncated with ellipsis
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
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.code,
                                color: accentColor.withOpacity(0.8),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Submitted Code:',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              submission['code'] ?? 'No code submitted',
                              style: GoogleFonts.firaCode(
                                color: accentColor,
                                fontSize: 14,
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (submission['code'] != null &&
                              submission['code'].toString().length > 200)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: TextButton(
                                onPressed: () {
                                  _showFullCode(
                                    context,
                                    submission['code'],
                                    submission['assessment_title'] ?? 'Code Submission',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: primaryColor.withOpacity(0.3),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  'View Full Code',
                                  style: GoogleFonts.inter(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // TextField to enter points
                    TextField(
                      controller: _pointsControllers[submissionId],
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(color: accentColor, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Enter Points',
                        labelStyle: GoogleFonts.inter(color: accentColor, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Call _assignPoints method with submissionId, userId, and code
                        _assignPoints(submissionId, submission['user_id'], submission['code']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: accentColor,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        'Assign Points',
                        style: GoogleFonts.inter(color: accentColor, fontSize: 14),
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

  void _showFullCode(BuildContext context, String code, String title) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        code,
                        style: GoogleFonts.firaCode(
                          color: accentColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


//MANAGE ANALYTICS
class ManageAnalyticsScreen extends StatefulWidget {
  @override
  _ManageAnalyticsScreenState createState() => _ManageAnalyticsScreenState();
}

class _ManageAnalyticsScreenState extends State<ManageAnalyticsScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2D3250);    // Deep blue-grey
  static const Color secondaryColor = Color(0xFF424769);  // Lighter blue-grey
  static const Color accentColor = Color(0xFFF4EEE0);     // Cream white
  static const Color backgroundColor = Color(0xFF153448);  // Dark teal
  static const Color errorColor = Color(0xFFE57373);      // Soft red

  List<Map<String, dynamic>> _leaderboardData = [];
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> users = await _dbHelper.getAllUsers();

      final enhancedData = await Future.wait(
        users.map((user) async {
          final userId = user['id'];

          // Fetch game scores for the specific user
          final gameScores = await _dbHelper.getGameScores(userId);
          int totalGameScore = gameScores.fold(0, (sum, score) => sum + (score['score'] ?? 0) as int);

          // Fetch assessment scores for the specific user
          final assessments = await _dbHelper.fetchSubmittedAnswers(userId);
          int totalAssessmentPoints = assessments.fold(0, (sum, assessment) => sum + (assessment['updated_points'] ?? 0) as int);

          // Fetch high score for the specific user
          final highScore = await _dbHelper.getHighScore(userId);

          // Fetch last active time
          final lastActive = await _dbHelper.getLastActiveTime(userId);

          int totalScore = totalGameScore + totalAssessmentPoints + highScore;

          return totalScore > 0
              ? {
            ...user,
            'gameScore': totalGameScore,
            'assessmentScore': totalAssessmentPoints,
            'totalScore': totalScore,
            'highScore': highScore,
            'lastActive': lastActive,
          }
              : null; // Return null if total score is 0
        }),
      );

      // Filter out null values and cast to a non-nullable list
      final List<Map<String, dynamic>> filteredData =
      enhancedData.where((user) => user != null).cast<Map<String, dynamic>>().toList();

      // Sort leaderboard data by total score (highest to lowest)
      filteredData.sort((a, b) => (b['totalScore'] as int).compareTo(a['totalScore'] as int));

      setState(() {
        _leaderboardData = filteredData;
        _errorMessage = '';
        _isLoading = false;
      });
    } catch (e, stacktrace) {
      setState(() {
        _errorMessage = 'Error loading analytics data: $e';
        _isLoading = false;
      });
      debugPrint('Database Error: $e\nStacktrace: $stacktrace');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Student Analytics',
          style: GoogleFonts.poppins(
            color: accentColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _loadLeaderboardData,
            tooltip: 'Refresh Data',
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
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: secondaryColor,
          onRefresh: _loadLeaderboardData,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: accentColor),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: errorColor, size: 64),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(
                color: errorColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadLeaderboardData,
              icon: Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
      );
    }

    if (_leaderboardData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              color: accentColor.withOpacity(0.6),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No analytics data available yet.\nStudents need to complete activities.',
              style: GoogleFonts.inter(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _leaderboardData.length,
      itemBuilder: (context, index) {
        final entry = _leaderboardData[index];
        return _buildStudentCard(entry, index);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> entry, int index) {
    final totalScore = entry['totalScore'] as int;
    final gameScore = entry['gameScore'] as int;
    final highScore = entry['highScore'] as int;
    final assessmentScore = entry['assessmentScore'] as int;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: secondaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: accentColor,
          iconColor: accentColor,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getRankColor(index),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                  color: index <= 2 ? primaryColor : accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            entry['username'] ?? 'Unknown User',
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
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          totalScore.toString(),
                          style: GoogleFonts.inter(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Rank #${index + 1}',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreRow(
                      'Total Game Score',
                      highScore + gameScore, // Combining highScore and gameScore
                      Icons.sports_esports, // Using a more general icon
                    ),

                    SizedBox(height: 12),

                    _buildScoreRow(
                      'Assessment Points',
                      assessmentScore,
                      Icons.assessment,
                    ),

                    if (entry['lastActive'] != null) ...[
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: accentColor.withOpacity(0.8),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Last Active: ${_formatDate(entry['lastActive'])}',
                            style: GoogleFonts.inter(
                              color: accentColor.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int score, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 16),
          SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.inter(
              color: accentColor,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
          Text(
            score.toString(),
            style: GoogleFonts.inter(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber[400]!; // Gold
      case 1:
        return Colors.grey[300]!; // Silver
      case 2:
        return Colors.brown[300]!; // Bronze
      default:
        return primaryColor;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final minutes = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} ${date.hour}:$minutes';
  }
}

class ProfileSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()._buildFeatureScreen(
        'Profile Settings', 'Profile Settings - Coming Soon!');
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()
        ._buildFeatureScreen('Edit Profile', 'Edit Profile - Coming Soon!');
  }
}

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()._buildFeatureScreen(
        'Change Password', 'Change Password - Coming Soon!');
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()._buildFeatureScreen(
        'Notification Settings', 'Notification Settings - Coming Soon!');
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()._buildFeatureScreen(
        'Privacy Settings', 'Privacy Settings - Coming Soon!');
  }
}

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen()
        ._buildFeatureScreen('Help & Support', 'Help & Support - Coming Soon!');
  }
}
