import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

class AppSettingsState {
  final ThemeMode themeMode;
  const AppSettingsState({this.themeMode = ThemeMode.light});
  AppSettingsState copyWith({ThemeMode? themeMode}) => AppSettingsState(themeMode: themeMode ?? this.themeMode);
}

class SettingsNotifier extends StateNotifier<AppSettingsState> {
  SettingsNotifier() : super(const AppSettingsState()) { _load(); }
  static const String _key = 'is_dark_theme';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettingsState>((ref) => SettingsNotifier());
