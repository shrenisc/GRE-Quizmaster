import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // You must generate this via FlutterFire CLI
import 'ui/theme/app_theme.dart';
import 'ui/views/dashboard_view.dart';
import 'ui/views/group_list_view.dart';
import 'ui/views/group_drill_view.dart';
import 'ui/views/exam_mode_view.dart';
import 'ui/views/review_queue_view.dart';
import 'ui/views/auth/login_screen.dart';
import 'ui/views/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
  }
  runApp(const GreVocabQuestApp());
}

class GreVocabQuestApp extends StatelessWidget {
  const GreVocabQuestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRE Quizmaster',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/group_list':
            return MaterialPageRoute(builder: (_) => const GroupListView());
          case '/drill':
            final groupId = settings.arguments as int? ?? 1;
            return MaterialPageRoute(builder: (_) => GroupDrillView(groupId: groupId));
          case '/exam_mode':
            return MaterialPageRoute(builder: (_) => const ExamModeView());
          case '/review_queue':
            return MaterialPageRoute(builder: (_) => const ReviewQueueView());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileView());
          default:
            return MaterialPageRoute(builder: (_) => const AuthGate());
        }
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const DashboardView();
        }
        return const LoginScreen();
      },
    );
  }
}
