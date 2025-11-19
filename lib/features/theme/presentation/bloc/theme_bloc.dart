import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_app/features/theme/presentation/bloc/theme_event.dart';
import 'package:property_app/features/theme/presentation/bloc/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'isDarkMode';
  final SharedPreferences _prefs;

  ThemeBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeInitial(_getInitialTheme(prefs))) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  static bool _getInitialTheme(SharedPreferences prefs) {
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> _onToggleTheme(
      ToggleThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    final newDarkMode = !state.isDarkMode;
    await _prefs.setBool(_themeKey, newDarkMode);
    emit(ThemeChanged(newDarkMode));
    print('🎨 Theme changed to: ${newDarkMode ? 'Dark' : 'Light'}');
  }

  Future<void> _onSetTheme(
      SetThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    await _prefs.setBool(_themeKey, event.isDarkMode);
    emit(ThemeChanged(event.isDarkMode));
    print('🎨 Theme set to: ${event.isDarkMode ? 'Dark' : 'Light'}');
  }
}