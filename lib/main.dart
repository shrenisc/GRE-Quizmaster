import 'package:flutter/material.dart';
import 'ui/theme/app_theme.dart';
import 'ui/views/dashboard_view.dart';
import 'ui/views/group_list_view.dart';
import 'ui/views/group_drill_view.dart';
import 'ui/views/exam_mode_view.dart';
import 'ui/views/review_queue_view.dart';

void main() {
  runApp(const GreVocabQuestApp());
}

class GreVocabQuestApp extends StatelessWidget {
  const GreVocabQuestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRE Quizmaster',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const DashboardView());
          case '/group_list':
            return MaterialPageRoute(builder: (_) => const GroupListView());
          case '/drill':
            final groupId = settings.arguments as int? ?? 1;
            return MaterialPageRoute(builder: (_) => GroupDrillView(groupId: groupId));
          case '/exam_mode':
            return MaterialPageRoute(builder: (_) => const ExamModeView());
          case '/review_queue':
            return MaterialPageRoute(builder: (_) => const ReviewQueueView());
          default:
            return MaterialPageRoute(builder: (_) => const DashboardView());
        }
      },
    );
  }
}
