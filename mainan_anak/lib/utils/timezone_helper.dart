import 'package:intl/intl.dart';

class TimezoneHelper {
  static DateTime getCurrentTime() {
    return DateTime.now();
  }

  // Get time in WIB (UTC+7)
  static DateTime getWIB() {
    final now = DateTime.now().toUtc();
    return now.add(const Duration(hours: 7));
  }

  // Get time in WITA (UTC+8)
  static DateTime getWITA() {
    final now = DateTime.now().toUtc();
    return now.add(const Duration(hours: 8));
  }

  // Get time in WIT (UTC+9)
  static DateTime getWIT() {
    final now = DateTime.now().toUtc();
    return now.add(const Duration(hours: 9));
  }

  // Get time in London (UTC+0 or UTC+1 during BST)
  static DateTime getLondon() {
    return DateTime.now().toUtc();
    // Note: For BST (British Summer Time), add 1 hour during summer months
  }

  // Format time as 24-hour format
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Get all timezones with formatted strings
  static Map<String, String> getAllTimezones() {
    return {
      'WIB': formatTime(getWIB()),
      'WITA': formatTime(getWITA()),
      'WIT': formatTime(getWIT()),
      'London': formatTime(getLondon()),
    };
  }
}
