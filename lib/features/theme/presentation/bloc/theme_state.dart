import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial(super.isDarkMode);
}

class ThemeChanged extends ThemeState {
  const ThemeChanged(super.isDarkMode);
}