import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class ProgressRepository {
  static const String _xpKey = 'xp';
  static const String _streakKey = 'streak';
  static const String _lastActiveKey = 'lastActive';

  Future<UserProgress> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_xpKey) ?? 0;
    final streak = prefs.getInt(_streakKey) ?? 0;
    final lastActiveStr = prefs.getString(_lastActiveKey);
    final lastActive = lastActiveStr != null ? DateTime.parse(lastActiveStr) : DateTime.now();

    return UserProgress(xp: xp, streakDays: streak, lastActive: lastActive);
  }

  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, progress.xp);
    await prefs.setInt(_streakKey, progress.streakDays);
    await prefs.setString(_lastActiveKey, progress.lastActive.toIso8601String());
  }

  Future<int> getGroupScore(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('group_score_$groupId') ?? 0;
  }

  Future<void> saveGroupScore(int groupId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentScore = await getGroupScore(groupId);
    if (score > currentScore) {
      await prefs.setInt('group_score_$groupId', score);
    }
  }
}
