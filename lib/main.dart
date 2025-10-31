import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:gamified_cpla_v1/screens/login_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  final Future _init = _initialize();

  static Future<void> _initialize() async {
    // await Firebase.initializeApp();
    await DatabaseHelper().database;
    // Add minimum display duration to show the loading screen
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gamified C Programming Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return LoginScreen();
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Initialization failed',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            );
          } else {
            // ✅ Enhanced loading screen with improved design
            return Scaffold(
              backgroundColor: Color(0xff2a4a60),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decorative container with glow effect
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer circle background
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff3d5a73),
                            ),
                          ),
                          // Progress indicator
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          // Center icon
                          Icon(
                            Icons.code,
                            size: 50,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}