import 'dart:math';

/// String constants and motivational quotes in coquette style
class AppStrings {
  AppStrings._();

  static const String appName = 'Workaholic';
  static const String appTagline = 'Slay your day, bestie ✨';

  // ─── Greeting Templates ───
  static const List<String> greetings = [
    'Hey, queen! 👑',
    'Hey, bestie! 💕',
    'Hey, gorgeous! ✨',
    'Hey, superstar! 🌟',
    'Hey, boss babe! 💼',
  ];

  // ─── Empty State Quotes ───
  static const List<String> emptyStateQuotes = [
    "No tasks yet, bestie!\nTime to slay your day ✨",
    "All caught up! You ate that 💅",
    "Main character energy —\nno tasks pending ✨",
    "Queen of getting things done 👑",
    "Your to-do list? ✅ Defeated.",
    "Time to add new goals, bestie 🎯",
    "Clean slate energy! 🌸\nWhat's the plan today?",
  ];

  // ─── Completion Messages ───
  static const List<String> completionMessages = [
    'Yass! Task complete! 💅',
    'Slayed it! ✨',
    'Another one done! 🎉',
    'Boss move! 💼',
    'You ate that up! 👑',
    'Main character moment! 🌟',
    'Period! Task destroyed! 💕',
  ];

  // ─── Level Names ───
  static const Map<int, String> levelNames = {
    1: '🌱 Newbie',
    2: '💫 Rising Star',
    3: '💪 Go-Getter',
    4: '🔥 Hustler',
    5: '💼 Boss Babe',
    6: '👑 Queen',
    7: '✨ CEO Energy',
  };

  // ─── XP Thresholds ───
  static const Map<int, int> xpThresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2500,
  };

  // ─── Quick Add Placeholder ───
  static const String quickAddHint = 'What do you need to do, babe?';
  static const String descriptionHint = 'Add details...';
  static const String fabTooltip = 'Add a task, bestie!';

  // ─── Date Shortcuts ───
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String nextWeek = 'Next Week';

  /// Get a random greeting
  static String get randomGreeting =>
      greetings[Random().nextInt(greetings.length)];

  /// Get a random empty state quote
  static String get randomEmptyQuote =>
      emptyStateQuotes[Random().nextInt(emptyStateQuotes.length)];

  /// Get a random completion message
  static String get randomCompletionMessage =>
      completionMessages[Random().nextInt(completionMessages.length)];
}
