import 'package:flutter/material.dart';

class UserPreferences {
  String selectedBibleVersion;
  String appLanguage;
  double fontSize;
  bool isDarkMode;
  TimeOfDay dailyNotificationTime;
  bool isNotificationEnabled;

  UserPreferences({
    this.selectedBibleVersion = '',
    this.appLanguage = 'en', // Default to English, will be updated to system locale if possible
    this.fontSize = 16.0,
    this.isDarkMode = false,
    this.dailyNotificationTime = const TimeOfDay(hour: 6, minute: 0),
    this.isNotificationEnabled = false,
  });
}
