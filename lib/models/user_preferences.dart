
import 'package:flutter/material.dart';

class UserPreferences {
  String selectedBibleVersion;
  double fontSize;
  bool isDarkMode;
  TimeOfDay dailyNotificationTime;
  bool isNotificationEnabled;

  UserPreferences({
    this.selectedBibleVersion = '개역개정',
    this.fontSize = 16.0,
    this.isDarkMode = false,
    this.dailyNotificationTime = const TimeOfDay(hour: 6, minute: 0),
    this.isNotificationEnabled = false,
  });
}
