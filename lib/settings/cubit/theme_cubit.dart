import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:quest_board/settings/data/repo/abstract_settings_repo.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({required this._settingsRepo})
    : super(ThemeState(brightness: Brightness.light)) {
    _checkCurrentTheme();
  }

  final AbstractSettingsRepo _settingsRepo;

  Future<void> setThemeBrightness(Brightness brightness) async {
    emit(ThemeState(brightness: brightness));
    await _settingsRepo.setDarkThemeSelected(brightness == Brightness.dark);
    GetIt.I<Talker>().debug('Save theme settings');
  }

  void _checkCurrentTheme() {
    final brightness = _settingsRepo.isDarkThemeSelected()
        ? Brightness.dark
        : Brightness.light;
    emit(ThemeState(brightness: brightness));
  }
}
