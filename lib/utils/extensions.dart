import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String toDateString() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    return isSameDay(DateTime.now());
  }

  bool isTomorrow() {
    return isSameDay(DateTime.now().add(const Duration(days: 1)));
  }
}

extension StringExtension on String {
  bool get isEmail => contains('@') && contains('.');

  bool get isEmpty => trim().length == 0;

  bool get isNotEmpty => !isEmpty;

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String truncate(int length) {
    if (this.length <= length) return this;
    return substring(0, length) + '...';
  }
}

extension NumExtension on num {
  String toFormattedString() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}
