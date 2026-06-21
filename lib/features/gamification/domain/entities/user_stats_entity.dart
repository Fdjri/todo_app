import 'package:equatable/equatable.dart';

enum UserLevel {
  newbie(1, '🌱 Newbie', 0),
  risingStar(2, '💫 Rising Star', 100),
  goGetter(3, '💪 Go-Getter', 300),
  hustler(4, '🔥 Hustler', 600),
  bossBabe(5, '💼 Boss Babe', 1000),
  queen(6, '👑 Queen', 1500),
  ceoEnergy(7, '✨ CEO Energy', 2500);

  final int level;
  final String title;
  final int xpRequired;

  const UserLevel(this.level, this.title, this.xpRequired);

  static UserLevel fromXP(int xp) {
    if (xp >= 2500) return ceoEnergy;
    if (xp >= 1500) return queen;
    if (xp >= 1000) return bossBabe;
    if (xp >= 600) return hustler;
    if (xp >= 300) return goGetter;
    if (xp >= 100) return risingStar;
    return newbie;
  }

  UserLevel? get nextLevel {
    final index = UserLevel.values.indexOf(this);
    if (index < UserLevel.values.length - 1) {
      return UserLevel.values[index + 1];
    }
    return null;
  }

  int get xpForNextLevel => nextLevel?.xpRequired ?? xpRequired;
}

class UserStatsEntity extends Equatable {
  final int totalTasksCompleted;
  final int currentStreak;
  final int longestStreak;
  final int xp;
  final String? dailyMood;
  final DateTime? lastActiveDate;

  const UserStatsEntity({
    this.totalTasksCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xp = 0,
    this.dailyMood,
    this.lastActiveDate,
  });

  UserLevel get level => UserLevel.fromXP(xp);

  double get xpProgress {
    final current = level;
    final next = current.nextLevel;
    if (next == null) return 1.0;
    final earned = xp - current.xpRequired;
    final needed = next.xpRequired - current.xpRequired;
    return (earned / needed).clamp(0.0, 1.0);
  }

  UserStatsEntity copyWith({
    int? totalTasksCompleted,
    int? currentStreak,
    int? longestStreak,
    int? xp,
    String? dailyMood,
    DateTime? lastActiveDate,
  }) {
    return UserStatsEntity(
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xp: xp ?? this.xp,
      dailyMood: dailyMood ?? this.dailyMood,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  List<Object?> get props => [
        totalTasksCompleted, currentStreak, longestStreak,
        xp, dailyMood, lastActiveDate,
      ];
}
