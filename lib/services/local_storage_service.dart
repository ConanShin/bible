
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../models/bookmark.dart';

class LocalStorageService {
  static const String KEY_ONBOARDING_COMPLETED = 'onboarding_completed';
  static const String KEY_THEME_MODE = 'is_dark_mode'; // true: dark, false: light
  static const String KEY_FONT_SIZE = 'font_size';
  static const String KEY_BIBLE_VERSION = 'bible_version';
  static const String KEY_NOTIF_ENABLED = 'notification_enabled';
  static const String KEY_NOTIF_TIME_HOUR = 'notification_time_hour';
  static const String KEY_NOTIF_TIME_MINUTE = 'notification_time_minute';
  static const String KEY_BOOKMARKS = 'bookmarks';

  Future<void> saveOnboardingStatus(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_ONBOARDING_COMPLETED, completed);
  }

  Future<bool> getOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_ONBOARDING_COMPLETED) ?? false;
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(KEY_THEME_MODE, prefs.isDarkMode);
    await sp.setDouble(KEY_FONT_SIZE, prefs.fontSize);
    await sp.setString(KEY_BIBLE_VERSION, prefs.selectedBibleVersion);
    await sp.setBool(KEY_NOTIF_ENABLED, prefs.isNotificationEnabled);
    await sp.setInt(KEY_NOTIF_TIME_HOUR, prefs.dailyNotificationTime.hour);
    await sp.setInt(KEY_NOTIF_TIME_MINUTE, prefs.dailyNotificationTime.minute);
  }

  Future<UserPreferences> getUserPreferences() async {
    final sp = await SharedPreferences.getInstance();
    return UserPreferences(
      isDarkMode: sp.getBool(KEY_THEME_MODE) ?? false,
      fontSize: sp.getDouble(KEY_FONT_SIZE) ?? 16.0,
      selectedBibleVersion: sp.getString(KEY_BIBLE_VERSION) ?? '개역개정',
      isNotificationEnabled: sp.getBool(KEY_NOTIF_ENABLED) ?? false,
      dailyNotificationTime: TimeOfDay(
        hour: sp.getInt(KEY_NOTIF_TIME_HOUR) ?? 6,
        minute: sp.getInt(KEY_NOTIF_TIME_MINUTE) ?? 0,
      ),
    );
  }
  
  // Future: Implement bookmarks save/load
}
