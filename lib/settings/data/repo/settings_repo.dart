import 'package:quest_board/settings/data/repo/abstract_settings_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepo extends AbstractSettingsRepo {
  final SharedPreferences preferences;

  SettingsRepo({required this.preferences});

  static const _isDarkThemeSelectedKey = 'dark_theme_selected';

  @override
  Future<void> setDarkThemeSelected(bool selected) async {
    await preferences.setBool(_isDarkThemeSelectedKey, selected);
  }

  @override
  bool isDarkThemeSelected() {
    final value = preferences.getBool(_isDarkThemeSelectedKey);
    return value ?? false;
  }
}
