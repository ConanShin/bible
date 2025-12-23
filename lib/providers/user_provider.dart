
import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';

class UserProvider with ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  UserPreferences _preferences = UserPreferences();
  UserPreferences get preferences => _preferences;
  
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> loadState() async {
    _isLoading = true;
    notifyListeners();
    
    _hasCompletedOnboarding = await _storageService.getOnboardingStatus();
    _preferences = await _storageService.getUserPreferences();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storageService.saveOnboardingStatus(true);
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences newPrefs) async {
    _preferences = newPrefs;
    await _storageService.saveUserPreferences(newPrefs);
    notifyListeners();
  }
}
