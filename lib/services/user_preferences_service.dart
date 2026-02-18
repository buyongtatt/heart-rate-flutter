import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static final UserPreferencesService instance = UserPreferencesService._init();
  static SharedPreferences? _prefs;

  UserPreferencesService._init();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String get userName => _prefs?.getString('user_name') ?? 'Alex Johnson';

  Future<void> setUserName(String name) async {
    await _prefs?.setString('user_name', name);
  }
}
