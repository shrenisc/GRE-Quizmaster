class UserProgress {
  final int xp;
  final int streakDays;
  final DateTime lastActive;

  const UserProgress({
    required this.xp,
    required this.streakDays,
    required this.lastActive,
  });

  UserProgress copyWith({
    int? xp,
    int? streakDays,
    DateTime? lastActive,
  }) {
    return UserProgress(
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
