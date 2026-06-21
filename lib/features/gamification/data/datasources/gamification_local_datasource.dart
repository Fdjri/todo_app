import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_stats_entity.dart';

class GamificationLocalDataSource {
  static const String _statsKey = 'user_stats_data';
  final SharedPreferences _prefs;

  GamificationLocalDataSource(this._prefs);

  UserStatsEntity getStats() {
    final jsonStr = _prefs.getString(_statsKey);
    if (jsonStr == null || jsonStr.isEmpty) return const UserStatsEntity();
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UserStatsEntity(
      totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      dailyMood: json['dailyMood'] as String?,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
    );
  }

  Future<void> saveStats(UserStatsEntity stats) async {
    final json = {
      'totalTasksCompleted': stats.totalTasksCompleted,
      'currentStreak': stats.currentStreak,
      'longestStreak': stats.longestStreak,
      'xp': stats.xp,
      'dailyMood': stats.dailyMood,
      'lastActiveDate': stats.lastActiveDate?.toIso8601String(),
    };
    await _prefs.setString(_statsKey, jsonEncode(json));
  }

  Future<UserStatsEntity> addTaskXP() async {
    var stats = getStats();
    stats = stats.copyWith(
      totalTasksCompleted: stats.totalTasksCompleted + 1,
      xp: stats.xp + 10,
    );
    await saveStats(stats);
    return stats;
  }

  Future<UserStatsEntity> addSubtaskXP() async {
    var stats = getStats();
    stats = stats.copyWith(xp: stats.xp + 5);
    await saveStats(stats);
    return stats;
  }

  Future<UserStatsEntity> updateStreak() async {
    var stats = getStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = stats.lastActiveDate;

    if (lastActive == null) {
      stats = stats.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: today,
        xp: stats.xp + 25,
      );
    } else {
      final lastDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 1) {
        final newStreak = stats.currentStreak + 1;
        stats = stats.copyWith(
          currentStreak: newStreak,
          longestStreak: newStreak > stats.longestStreak ? newStreak : stats.longestStreak,
          lastActiveDate: today,
          xp: stats.xp + 25,
        );
      } else if (diff > 1) {
        stats = stats.copyWith(
          currentStreak: 1,
          lastActiveDate: today,
        );
      }
      // diff == 0 means same day, no streak change
    }

    await saveStats(stats);
    return stats;
  }

  Future<UserStatsEntity> setMood(String mood) async {
    var stats = getStats();
    stats = stats.copyWith(dailyMood: mood);
    await saveStats(stats);
    return stats;
  }
}
