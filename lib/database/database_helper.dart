import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:gamified_cpla_v1/models/quiz.dart';
import 'package:gamified_cpla_v1/models/game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  DatabaseHelper._internal();

  // Enhanced database getter with better error handling
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String dbPath = await getDatabasesPath();
      String path = join(dbPath, 'gamified_app.db');

      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        readOnly: false
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.rawUpdate('UPDATE game_locks SET user_id = NULL');
    }

    if (oldVersion < 2) { // Upgrade logic for version 2
      await _addHasCompletedStoryColumn(db);
    }
  }


  //Code Worm Game
  static const String tableGameStats = 'game_stats';
  static const String columnId = 'id';
  static const String columnUserId = 'user_id';
  static const String columnScore = 'score';
  static const String columnLevel = 'level';
  static const String columnTimeLeft = 'time_left';
  static const String columnLives = 'lives';
  static const String columnChallengesCompleted = 'challenges_completed';
  static const String columnTimestamp = 'timestamp';

  Future<void> _onCreate(Database db, int version) async {

    // Users table
      await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL,
      hasCompletedStory INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    )
  ''');

    // Create index for username lookups
    await db.execute('CREATE INDEX idx_users_username ON users(username)');


    // Tutorials table
    await db.execute('''
        CREATE TABLE tutorials(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL CHECK(length(title) >= 3),
          description TEXT,
          url TEXT,
          filePath TEXT,
          is_active BOOLEAN DEFAULT 1,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

    // Quizzes table
    await db.execute('''
        CREATE TABLE quizzes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tutorial_id INTEGER NOT NULL,
          question TEXT NOT NULL,
          option1 TEXT NOT NULL,
          option2 TEXT NOT NULL,
          option3 TEXT NOT NULL,
          option4 TEXT NOT NULL,
          correct_option TEXT NOT NULL,
          explanation TEXT,
          points INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (tutorial_id) REFERENCES tutorials (id) 
            ON DELETE CASCADE
            ON UPDATE CASCADE
        )
      ''');

    // Assessments table
    await db.execute('''
        CREATE TABLE assessments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          title TEXT NOT NULL CHECK(length(title) >= 3),
          description TEXT,
          type TEXT NOT NULL,
          difficulty TEXT NOT NULL,
          points INTEGER NOT NULL CHECK(points >= 0),
          is_active BOOLEAN DEFAULT 1,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

    // Submitted answers table
    await db.execute('''
        CREATE TABLE submitted_answers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          assessment_id INTEGER NOT NULL,
          user_id INTEGER,
          code TEXT NOT NULL,
          score INTEGER DEFAULT 0,
          feedback TEXT,
          submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (assessment_id) REFERENCES assessments (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');



    // Games table
    await db.execute('''
          CREATE TABLE games (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            difficultyLevel TEXT NOT NULL,
            adventureStage TEXT NOT NULL,
            pointsReward INTEGER NOT NULL,
            concept TEXT NOT NULL,
            storyText TEXT NOT NULL,
            storySegments TEXT NOT NULL,
            choicesByStep TEXT NOT NULL,
            pointsForChoices TEXT NOT NULL,
            correctAnswers TEXT NOT NULL,
            consequences TEXT NOT NULL,
            isPlayed INTEGER NOT NULL DEFAULT 0
          )
        ''');


    //Code Worm Game
    await db.execute('''
  CREATE TABLE $tableGameStats (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnUserId INTEGER NOT NULL,
    $columnScore INTEGER NOT NULL,
    $columnLevel INTEGER NOT NULL,
    $columnTimeLeft INTEGER NOT NULL,
    $columnLives INTEGER NOT NULL,
    $columnChallengesCompleted INTEGER NOT NULL,
    $columnTimestamp TEXT NOT NULL,
    is_unlocked INTEGER DEFAULT 0,  
    FOREIGN KEY ($columnUserId) REFERENCES users(id) ON DELETE CASCADE
  )
''');



    // Game locks table
    await db.execute('''
        CREATE TABLE game_locks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          user_id INTEGER,
          username TEXT,
          is_locked BOOLEAN DEFAULT 1,
          locked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          unlock_condition TEXT,
          FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE (game_id, user_id)
        )
      ''');
    //GAME USER STATUS
    await db.execute('''CREATE TABLE game_user_status (
        id INTEGER PRIMARY KEY,
        game_id INTEGER,
        username TEXT,
        is_played INTEGER DEFAULT 0,
        played_at TIMESTAMP, -- To track when the game was played
        UNIQUE (game_id, username)
      )
      ''');
    //Unlock Games From GameLocks-Codeworm
    await db.execute('''CREATE TABLE IF NOT EXISTS unlocked_games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        game_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (game_id) REFERENCES games (id),
        UNIQUE (user_id, game_id) -- Prevents duplicate unlocks
        )
      ''');

    // Game progress table
    await db.execute('''
        CREATE TABLE game_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          game_id INTEGER,
          score INTEGER NOT NULL DEFAULT 0,
          progress INTEGER NOT NULL DEFAULT 0,
          time_spent INTEGER NOT NULL DEFAULT 0,
          completed_at TIMESTAMP,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
        )
      ''');

    //Create indexes for frequently queried columns
    await db.execute(
        'CREATE INDEX idx_game_progress_user ON game_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_game_progress_game ON game_progress(game_id)');
  }

// Ensure column exists before altering the table
  Future<void> _addHasCompletedStoryColumn(Database db) async {
    try {
      var res = await db.rawQuery("PRAGMA table_info(users);");
      bool columnExists = res.any((column) => column['name'] == 'hasCompletedStory');

      if (!columnExists) {
        await db.execute('ALTER TABLE users ADD COLUMN hasCompletedStory INTEGER DEFAULT 0');
        print("✅ Column 'hasCompletedStory' added successfully.");
      } else {
        print("⚠️ Column 'hasCompletedStory' already exists.");
      }
    } catch (e) {
      print("❌ Error adding 'hasCompletedStory' column: $e");
    }
  }

// Secure password hashing
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

// Insert new user
  Future<int> insertUser(String username, String password, String role) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);

    try {
      return await db.insert(
        'users',
        {
          'username': username.trim(),
          'password': hashedPassword,
          'role': role,
          'hasCompletedStory': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

// Retrieve user data
  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    String hashedPassword = _hashPassword(password);

    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (results.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      int userId = results.first['id'];
      bool hasCompletedStory = (results.first['hasCompletedStory'] ?? 0) == 1;

      await prefs.setString('current_username', results.first['username']);
      await prefs.setInt('current_user_id', userId);
      await prefs.setBool('story_completed_$userId', hasCompletedStory);

      return {
        ...results.first,
        'hasCompletedStory': hasCompletedStory,
      };
    }
    return null;
  }

// Update story completion status
  Future<int> updateUserStoryCompletion(int userId, bool hasCompletedStory) async {
    final db = await database;

    return await db.update(
      'users',
      {'hasCompletedStory': hasCompletedStory ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Update a user with optional password
  Future<int> updateUser(
      int id, String username, String? password, String role) async {
    final db = await database;
    Map<String, dynamic> updatedData = {
      'username': username,
      'role': role,
    };
    if (password != null && password.isNotEmpty) {
      updatedData['password'] = _hashPassword(password);
    }
    return await db.update(
      'users',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('current_user_id');

      if (userId == null) {
        print('No user ID found in SharedPreferences.'); // Debugging log
        return null; // No user is logged in
      }

      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (results.isNotEmpty) {
        return results.first; // Return the logged-in user data
      } else {
        print('User ID $userId found in SharedPreferences but missing in database.');
      }

      return null;
    } catch (e) {
      throw Exception('Error fetching current user: $e');
    }
  }

  Future<int?> getCurrentUserId() async {
    final user = await getCurrentUser();
    return user?['id']; // Ensure that 'id' exists in the user table
  }



  // Update a tutorial with filePath
  Future<int> updateTutorial(int id, String title, String description,
      String url, String? filePath) async {
    final db = await database;
    return await db.update(
      'tutorials',
      {
        'title': title,
        'description': description,
        'url': url,
        'filePath': filePath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //Edit Profile Methods-Admin
  Future<Map<String, dynamic>?> getAdminProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['admin'],
      limit: 1, // Get only one admin
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateAdminProfile(String username, String password) async {
    final db = await database;
    Map<String, dynamic> updatedData = {'username': username};

    if (password.isNotEmpty) {
      updatedData['password'] = password; // Store hashed password if needed
    }

    return await db.update(
      'users',
      updatedData,
      where: 'role = ?',
      whereArgs: ['admin'],
    );
  }

  // Update an existing quiz
  Future<void> updateQuiz(Quiz quiz) async {
    final db = await database;
    await db
        .update('quizzes', quiz.toMap(), where: 'id = ?', whereArgs: [quiz.id]);
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateGame(Game game) async {
    final db = await database;
    return await db.update(
      'games',
      {
        'title': game.title,
        'description': game.description,
        'difficultyLevel': game.difficultyLevel,
        'adventureStage': game.adventureStage,
        'pointsReward': game.pointsReward,
        'concept': game.concept,
        'storyText': game.storyText,
        'storySegments': jsonEncode(game.storySegments),
        'choicesByStep': jsonEncode(game.choicesByStep),
        'pointsForChoices': jsonEncode(game.pointsForChoices),
        'correctAnswers': jsonEncode(game.correctAnswers),
        'consequences': jsonEncode(game.consequences),
        'isPlayed': game.isPlayed ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }


  Future<List<Map<String, dynamic>>> fetchSubmittedAnswers([int? userId]) async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT sa.*, sa.score AS updated_points, a.title AS assessment_title, u.username
    FROM submitted_answers sa
    JOIN assessments a ON sa.assessment_id = a.id
    JOIN users u ON sa.user_id = u.id
    ${userId != null ? 'WHERE sa.user_id = ?' : ''}  -- Fetch specific user if provided
  ''', userId != null ? [userId] : []);

    return result;
  }




// Method to update score and then fetch the updated score
  Future<int> updatePoints(int submissionId, int userId, int score) async {
    try {
      final db = await database;

      // Update the score for the specific user and submission
      int count = await db.update(
        'submitted_answers',
        {'score': score},
        where: 'id = ? AND user_id = ?',
        whereArgs: [submissionId, userId],
      );

      // If update was successful (at least one row affected), return the new score
      return count > 0 ? score : 0;
    } catch (e) {
      print("Error updating points: $e");
      return 0; // Return 0 in case of an error
    }
  }



  // ------------------- ANALYTICS/LEADERBOARDS------------------
  // Add these methods to your DatabaseHelper class
  Future<bool> isAnalyticsEnabled(int userId) async {
    final db = await database;

    // First check if user is admin
    final userRole = await db.query(
      'users',
      columns: ['role'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userRole.isNotEmpty && userRole.first['role'] == 'admin') {
      return false;
    }

    // Check if analytics have been pushed by admin
    final analytics = await db.query(
      'student_analytics',
      where: 'user_id = ? AND is_enabled = 1',
      whereArgs: [userId],
    );

    return analytics.isNotEmpty;
  }

  // Add this method to get filtered leaderboard data
  Future<List<Map<String, dynamic>>> getLeaderboardData() async {
    final db = await database;
    final users = await getAllUsers();

    List<Map<String, dynamic>> enhancedData = [];
    for (var user in users) {
      final userId = user['id'];

      // Check if analytics are enabled for this user
      final analyticsEnabled = await isAnalyticsEnabled(userId);
      if (!analyticsEnabled) continue;

      // Get game and assessment scores only if analytics are enabled
      final gameScores = await getGameScores(userId);
      final assessmentScores = await getAssessmentScores(userId);

      int totalGameScore = 0;
      for (var score in gameScores) {
        if (score['score'] != null) {
          totalGameScore += score['score'] as int;
        }
      }

      int totalAssessmentScore = 0;
      for (var assessment in assessmentScores) {
        if (assessment['points'] != null) {
          totalAssessmentScore += assessment['points'] as int;
        }
      }

      enhancedData.add({
        ...user,
        'gameScore': totalGameScore,
        'assessmentScore': totalAssessmentScore,
        'totalScore': totalGameScore + totalAssessmentScore,
      });
    }

    // Sort by total score
    enhancedData.sort((a, b) => (b['totalScore'] as int).compareTo(a['totalScore'] as int));
    return enhancedData;
  }
  Future<List<Map<String, dynamic>>> getGameScores(int userId) async {
    final db = await database;
    final user = await db.query(
      'users',
      columns: ['role'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty && user.first['role'] == 'admin') {
      return [];
    }

    return await db.query(
      'game_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getAssessmentScores(int userId) async {
    final db = await database;
    final user = await db.query(
      'users',
      columns: ['role'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty && user.first['role'] == 'admin') {
      return [];
    }

    final assessments = await db.query(
      'assessments',
      columns: ['points'],
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
    );

    return assessments.isNotEmpty ? assessments : [];
  }


  Future<String?> getLastActiveTime(int userId) async {
    final db = await database;
    final user = await db.query(
      'users',
      columns: ['role'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isNotEmpty && user.first['role'] == 'admin') {
      return null;
    }

    final gameProgress = await db.query(
      'game_progress',
      columns: ['created_at'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    final assessmentProgress = await db.query(
      'assessments',
      columns: ['created_at'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    final lastGameTime = gameProgress.isNotEmpty ? gameProgress.first['created_at'] as String : null;
    final lastAssessmentTime = assessmentProgress.isNotEmpty ? assessmentProgress.first['created_at'] as String : null;

    if (lastGameTime == null && lastAssessmentTime == null) return null;
    if (lastGameTime == null) return lastAssessmentTime;
    if (lastAssessmentTime == null) return lastGameTime;

    return DateTime.parse(lastGameTime).isAfter(DateTime.parse(lastAssessmentTime))
        ? lastGameTime
        : lastAssessmentTime;
  }

  // Delete a quiz
  Future<void> deleteQuiz(int id) async {
    final db = await database;
    await db.delete('quizzes', where: 'id = ?', whereArgs: [id]);
  }

  //Readstatus
  Future<bool> isTutorialRead(int tutorialId) async {
    final db = await database;
    final result = await db.query(
      'tutorials',
      columns: ['isRead'],
      where: 'id = ?',
      whereArgs: [tutorialId],
    );

    if (result.isNotEmpty) {
      return result.first['isRead'] == 1;
    }
    return false;
  }

  // Delete a tutorial
  Future<int> deleteTutorial(int id) async {
    final db = await database;
    return await db.delete(
      'tutorials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> deleteUser(int id) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsAffected > 0;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Tutorial Methods
  Future<int> insertTutorial(
      String title, String description, String url, String? filePath) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    try {
      final db = await database;
      return await db.insert(
        'tutorials',
        {
          'title': title.trim(),
          'description': description.trim(),
          'url': url.trim(),
          'filePath': filePath?.trim(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to insert tutorial: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllTutorials(
      {bool activeOnly = true}) async {
    try {
      final db = await database;
      String query = 'SELECT * FROM tutorials';
      if (activeOnly) {
        query += ' WHERE is_active = 1';
      }
      query += ' ORDER BY created_at DESC';
      return await db.rawQuery(query);
    } catch (e) {
      throw Exception('Failed to fetch tutorials: $e');
    }
  }

  // Quiz Methods
  Future<void> insertQuiz(Quiz quiz) async {
    try {
      final db = await database;
      await db.insert('quizzes', quiz.toMap());
    } catch (e) {
      throw Exception('Failed to insert quiz: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuizzesByTutorial(
      int tutorialId) async {
    try {
      final db = await database;
      return await db.query(
        'quizzes',
        where: 'tutorial_id = ?',
        whereArgs: [tutorialId],
      );
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  // Game Methods

  //Code Worm Methods
  // Insert game stats
  Future<int> insertGameStats(Map<String, dynamic> gameStats) async {
    Database db = await database;

    // Ensure `user_id` is included
    if (!gameStats.containsKey(columnUserId)) {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('current_user_id');
      if (userId == null) {
        throw Exception("User ID is required for inserting game stats.");
      }
      gameStats[columnUserId] = userId; // Assign user_id
    }

    // Add a timestamp
    gameStats[columnTimestamp] = DateTime.now().toIso8601String();

    return await db.insert(tableGameStats, gameStats);
  }


  // Get last game stats
  Future<Map<String, dynamic>?> getLastGameStats() async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      tableGameStats,
      orderBy: '$columnId DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get specific game stats by ID
  Future<Map<String, dynamic>?> getGameStats(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      tableGameStats,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

// Get high score
  Future<int> getHighScore([int? userId]) async {
    final db = await database;

    // Fetch userId from SharedPreferences if not provided
    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('current_user_id');
      print("Fetched userId from SharedPreferences: $userId");
    }

    if (userId == null) {
      print("No userId found. Returning 0.");
      return 0; // No user logged in or user ID not found
    }

    // Debug: Check if user_id exists in the table
    final checkUser = await db.rawQuery('SELECT COUNT(*) as count FROM $tableGameStats WHERE $columnUserId = ?', [userId]);
    int userCount = (checkUser.isNotEmpty) ? (checkUser.first['count'] as int) : 0;
    print("User record count: $userCount");

    if (userCount == 0) {
      print("No records found for userId: $userId");
      return 0;
    }

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT MAX($columnScore) AS high_score
    FROM $tableGameStats
    WHERE $columnUserId = ?
  ''', [userId]);

    int highScore = (results.isNotEmpty) ? (results.first['high_score'] as int? ?? 0) : 0;
    print("High score for userId $userId: $highScore");

    return highScore;
  }


  // Get all game stats
  Future<List<Map<String, dynamic>>> getAllGameStats() async {
    final db = await database;
    return await db.query(
        tableGameStats,
        orderBy: '$columnId DESC'
    );
  }

  Future<Map<String, dynamic>?> getGlobalHighScoreWithUser() async {
    final db = await database;

    // Check if tableGameStats has data before querying
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableGameStats');
    int count = countResult.first['count'] as int;

    if (count == 0) {
      print("No game stats available.");
      return null; // Avoid running query on an empty table
    }

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT $columnUserId, $columnScore
    FROM $tableGameStats
    WHERE $columnScore = (SELECT MAX($columnScore) FROM $tableGameStats)
    LIMIT 1
  ''');

    return results.isNotEmpty ? results.first : null;
  }

// Codeworm unlock game permanently
  Future<bool> isGameUnlockedForUser(int userId, int level) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      tableGameStats,
      where: '$columnUserId = ? AND $columnLevel = ? AND is_unlocked = 1',
      whereArgs: [userId, level],
    );

    print("Unlock status query results for user $userId and level $level: $results");

    return results.isNotEmpty;
  }





  // // Game Methods
  // Future<int> insertGame(Game game) async {
  //   try {
  //     final db = await database;
  //
  //     // Convert Easy/Medium/Hard to beginner/intermediate/advanced
  //     Map<String, dynamic> gameMap = game.toMap();
  //     String difficultyLevel = gameMap['difficulty_level'] as String;
  //
  //     final difficultyMapping = {
  //       'Easy': 'beginner',
  //       'Medium': 'intermediate',
  //       'Hard': 'advanced'
  //     };
  //
  //     gameMap['difficulty_level'] =
  //         difficultyMapping[difficultyLevel] ?? 'beginner';
  //
  //     return await db.insert('games', gameMap);
  //   } catch (e) {
  //     throw Exception('Failed to insert game: $e');
  //   }
  // }

  Future<int> insertGame(Game game) async {
    final db = await database;
    return await db.insert(
      'games',
      {
        'title': game.title,
        'description': game.description,
        'difficultyLevel': game.difficultyLevel,
        'adventureStage': game.adventureStage,
        'pointsReward': game.pointsReward,
        'concept': game.concept,
        'storyText': game.storyText,
        'storySegments': jsonEncode(game.storySegments),
        'choicesByStep': jsonEncode(game.choicesByStep),
        'pointsForChoices': jsonEncode(game.pointsForChoices),
        'correctAnswers': jsonEncode(game.correctAnswers),
        'consequences': jsonEncode(game.consequences),
        'isPlayed': game.isPlayed ? 1 : 0,
      },
    );
  }

  // Future<List<Game>> getAllGames({bool activeOnly = true}) async {
  //   try {
  //     final db = await database;
  //     String query = 'SELECT * FROM games';
  //     if (activeOnly) {
  //       query += ' WHERE is_active = 1';
  //     }
  //     final List<Map<String, dynamic>> maps = await db.rawQuery(query);
  //
  //     return maps.map((map) {
  //       final difficultyMapping = {
  //         'beginner': 'Easy',
  //         'intermediate': 'Medium',
  //         'advanced': 'Hard'
  //       };
  //
  //       map['difficulty_level'] =
  //           difficultyMapping[map['difficulty_level']] ?? 'Easy';
  //       return Game.fromMap(map);
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Failed to fetch games: $e');
  //   }
  // }

  Future<List<Game>> getAllGames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('games');

    return List.generate(maps.length, (i) {
      return Game(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        difficultyLevel: maps[i]['difficultyLevel'],
        adventureStage: maps[i]['adventureStage'],
        pointsReward: maps[i]['pointsReward'],
        concept: maps[i]['concept'],
        storyText: maps[i]['storyText'],
        storySegments: List<String>.from(jsonDecode(maps[i]['storySegments'])),
        choicesByStep: (jsonDecode(maps[i]['choicesByStep']) as List)
            .map((step) => List<String>.from(step))
            .toList(),
        pointsForChoices: (jsonDecode(maps[i]['pointsForChoices']) as List)
            .map((step) => List<int>.from(step))
            .toList(),
        correctAnswers: List<int>.from(jsonDecode(maps[i]['correctAnswers'])),
        consequences: List<String>.from(jsonDecode(maps[i]['consequences'])),
        isPlayed: maps[i]['isPlayed'] == 1,
      );
    });
  }

  Future<void> saveGameProgress(
      int userId, int gameId, int score, int progress, int timeSpent) async {
    try {
      final db = await database;
      await db.insert(
        'game_progress',
        {
          'user_id': userId,
          'game_id': gameId,
          'score': score,
          'progress': progress,
          'time_spent': timeSpent,
          'created_at': DateTime.now().toIso8601String(),
          'completed_at':
              progress == 100 ? DateTime.now().toIso8601String() : null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to save game progress: $e');
    }
  }

  // Assessment Methods
  Future<int> insertAssessment(String title, String description, String type,
      String difficulty, int points) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    try {
      final db = await database;
      return await db.insert(
        'assessments',
        {
          'title': title.trim(),
          'description': description.trim(),
          'type': type,
          'difficulty': difficulty,
          'points': points,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to insert assessment: $e');
    }
  }
  Future<int> updateAssessment(int id, String title, String description,
      String type, String difficulty, int points) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    try {
      final db = await database;
      return await db.update(
        'assessments',
        {
          'title': title.trim(),
          'description': description.trim(),
          'type': type,
          'difficulty': difficulty,
          'points': points,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update assessment: $e');
    }
  }

  // Delete Assessment
  Future<int> deleteAssessment(int id) async {
    final db = await database;
    return await db.delete(
      'assessments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> submitAnswer(int assessmentId, int userId, String code) async {
    try {
      final db = await database;
      await db.insert(
        'submitted_answers',
        {
          'assessment_id': assessmentId,
          'user_id': userId,
          'code': code,
          'submitted_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Leaderboard and Analytics Methods

  // Game Lock Management
  Future<void> lockGame(int gameId, int userId,
      {String? unlockCondition}) async {
    try {
      final db = await database;
      await db.insert(
        'game_locks',
        {
          'game_id': gameId,
          'user_id': userId,
          'is_locked': 1,
          'locked_at': DateTime.now().toIso8601String(),
          'unlock_condition': unlockCondition,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to lock game: $e');
    }
  }

  Future<void> unlockGame(int gameId, int userId) async {
    try {
      final db = await database;
      await db.update(
        'game_locks',
        {
          'is_locked': 0,
          'unlock_condition': null,
        },
        where: 'game_id = ? AND user_id = ?',
        whereArgs: [gameId, userId],
      );
    } catch (e) {
      throw Exception('Failed to unlock game: $e');
    }
  }

  //CodewormManageLockGames
  Future<List<String>> getUnlockedGames(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'unlocked_games',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return results.map((game) => game['game_title'] as String).toList();
  }


  Future<void> unlockGameForCodeWorm(int userId, String gameTitle) async {
    final db = await database;
    await db.insert(
      'unlocked_games',
      {'user_id': userId, 'game_title': gameTitle},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Debug: Fetch all unlocked games for this user after insertion
    final List<Map<String, dynamic>> unlockedGames = await db.query(
      'unlocked_games',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    print("Unlocked Games in DB for User $userId: $unlockedGames");
  }










  //GAME LOCKING
  Future<bool> isGamePlayedForUser(int gameId, String username) async {
    final db = await database;
    final result = await db.query(
      'game_user_status',
      columns: ['is_played'],
      where: 'game_id = ? AND username = ?',
      whereArgs: [gameId, username],
    );

    if (result.isNotEmpty) {
      return result.first['is_played'] == 1; // Game is played
    }
    return false; // Game is not played yet
  }

  // Method to lock a game for a specific user
  Future<void> markGameAsLockedForUser(int gameId, String username) async {
    final db = await database;
    await db.insert(
      'game_locks',
      {
        'game_id': gameId,
        'username': username,
        'is_locked': 1,
        'locked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplicate entries
    );
  }

  //UNLOCK GAME FOR A OTHER USER
  Future<void> unlockGameForUser(int gameId, String username) async {
    final db = await database;
    await db.update(
      'game_locks',
      {'is_locked': 0},
      where: 'game_id = ? AND username = ?',
      whereArgs: [gameId, username],
    );
  }

// Fetch all assessments
  Future<List<Map<String, dynamic>>> fetchAssessments() async {
    final db = await database;
    return await db.query('assessments', orderBy: 'id DESC'); // Ensures latest assessments appear first
  }

// Fetch all users (excluding admins)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role != ?',
      whereArgs: ['admin'], // Excludes users with role 'admin'
      orderBy: 'id ASC', // Orders users by ID
    );
  }


  //STUDENT SUBMIT ANSWER
  Future<void> insertSubmittedAnswer(int assessmentId, String code) async {
    final db = await database;

    try {
      final prefs = await SharedPreferences.getInstance();
      int? currentUserId = prefs.getInt('current_user_id'); // Retrieve user_id

      await db.insert(
        'submitted_answers',
        {
          'assessment_id': assessmentId,
          'user_id': currentUserId, // Include user_id
          'code': code,
          'submitted_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (e.toString().contains('no such table')) {
        throw Exception('Database table missing. Please contact support.');
      } else if (e.toString().contains('FOREIGN KEY constraint failed')) {
        throw Exception('Invalid assessment reference. Please check the assessment ID.');
      } else {
        throw Exception('Database error: $e');
      }
    }
  }


  //GAME PROGRESS
  Future<List<Map<String, dynamic>>> getGameProgress(int userId) async {
    final db = await database;

    return await db.query(
      'game_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> markGameAsPlayedForUser(int gameId, String username) async {
    final db = await database;
    try {
      await db.insert(
        'game_user_status',
        {
          'game_id': gameId,
          'username': username,
          'is_played': 1,
          'played_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplicates
      );
    } catch (e) {
      print('Error marking game as played: $e');
      throw Exception('Database operation failed');
    }
  }

// Method to check if the game is locked for a specific user
  Future<bool> isGameLockedForUser(int gameId, String username) async {
    final db = await database;
    final result = await db.query(
      'game_locks',
      where: 'game_id = ? AND username = ? AND is_locked = ?',
      whereArgs: [gameId, username, 1],
    );
    return result.isNotEmpty; // Return true if game is locked, false if not
  }

  Future<bool> isGameLocked(int gameId, int userId) async {
    try {
      final db = await database;
      final result = await db.query(
        'game_locks',
        where: 'game_id = ? AND user_id = ? AND is_locked = 1',
        whereArgs: [gameId, userId],
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check game lock status: $e');
    }
  }

  // Admin Account Management
  Future<void> seedAdminIfNeeded() async {
    try {
      final db = await database;
      final adminExists = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['admin'],
      );

      if (adminExists.isEmpty) {
        await insertUser('admin', 'admin123', 'admin');
        print('Admin account created successfully');
      }
    } catch (e) {
      throw Exception('Failed to seed admin account: $e');
    }
  }

  // Cleanup and Reset Methods
  Future<void> resetUserProgress(int userId) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // Reset game progress
        await txn.delete(
          'game_progress',
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // Reset submitted answers
        await txn.delete(
          'submitted_answers',
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // Reset game locks
        await txn.delete(
          'game_locks',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      });
    } catch (e) {
      throw Exception('Failed to reset user progress: $e');
    }
  }

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // Clear all tables except users
        await txn.delete('game_progress');
        await txn.delete('submitted_answers');
        await txn.delete('game_locks');
        await txn.delete('games');
        await txn.delete('assessments');
        await txn.delete('quizzes');
        await txn.delete('tutorials');
      });
    } catch (e) {
      throw Exception('Failed to clear database: $e');
    }
  }

  // Close database connection
  Future<void> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      throw Exception('Failed to close database: $e');
    }
  }
}
