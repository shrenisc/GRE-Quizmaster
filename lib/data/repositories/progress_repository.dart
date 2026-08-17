import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<UserProgress> getProgress() async {
    if (_uid == null) {
      return UserProgress(xp: 0, streakDays: 0, lastActive: DateTime.now());
    }

    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserProgress(
          xp: (data['xp'] as num?)?.toInt() ?? 0,
          streakDays: (data['streak'] as num?)?.toInt() ?? 0,
          lastActive: data['lastActive'] != null
              ? (data['lastActive'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }
    } catch (e) {
      print('Error getting progress: $e');
    }
    return UserProgress(xp: 0, streakDays: 0, lastActive: DateTime.now());
  }

  Future<void> saveProgress(UserProgress progress) async {
    if (_uid == null) return;

    try {
      await _firestore.collection('users').doc(_uid).set({
        'xp': progress.xp,
        'streak': progress.streakDays,
        'lastActive': progress.lastActive,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  Future<int> getGroupScore(int groupId) async {
    if (_uid == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('group_progress')
          .doc(groupId.toString())
          .get();

      if (doc.exists) {
        return (doc.data()?['score'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      print('Error getting group score: $e');
    }
    return 0;
  }

  Future<void> saveGroupScore(int groupId, int score) async {
    if (_uid == null) return;

    try {
      final currentScore = await getGroupScore(groupId);
      if (score > currentScore) {
        await _firestore
            .collection('users')
            .doc(_uid)
            .collection('group_progress')
            .doc(groupId.toString())
            .set({'score': score}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving group score: $e');
    }
  }

  Future<List<String>> getMissedWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('missed_words') ?? [];
  }

  Future<void> addMissedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final missed = prefs.getStringList('missed_words') ?? [];
    if (!missed.contains(word)) {
      missed.add(word);
      await prefs.setStringList('missed_words', missed);
    }
  }

  Future<void> removeMissedWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final missed = prefs.getStringList('missed_words') ?? [];
    if (missed.contains(word)) {
      missed.remove(word);
      await prefs.setStringList('missed_words', missed);
    }
  }
}
