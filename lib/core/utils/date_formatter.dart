import 'package:intl/intl.dart';

/// Date and time formatting helpers
class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    // Within the same week
    if (date.difference(now).inDays.abs() < 7) {
      return DateFormat('EEEE').format(date); // e.g., "Friday"
    }

    return DateFormat('MMM d, y').format(date); // e.g., "Jun 20, 2026"
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date); // e.g., "5:00 PM"
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} at ${formatTime(date)}';
  }

  static String formatDayHeader(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date); // e.g., "Friday, June 20"
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }
}
