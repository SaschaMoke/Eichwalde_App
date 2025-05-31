import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Colors
Color eichwaldeGreen = const Color.fromARGB(255, 50, 150, 50);
Color eichwaldeGradientGreen = const Color.fromARGB(255, 80, 175, 50);
Color eichwaldeGradientBlue = const Color.fromARGB(255, 0, 80, 160);

LinearGradient eichwaldeGradient = LinearGradient(colors: [eichwaldeGradientGreen, eichwaldeGradientBlue]);

class EichwaldeGradientBar extends StatelessWidget {
  const EichwaldeGradientBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: eichwaldeGradient,
        borderRadius: BorderRadius.circular(5)
      ),
      height: 5,
    );
  }
} 

//Borders
InputBorder textFeldNormalBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(
    width: 1.5,
    color: Color.fromARGB(255, 100, 100, 100),
  )
);
InputBorder textFeldfocusBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(
    width: 2,
    color: eichwaldeGreen,
  )
);

//Logo
AssetImage eichwaldeLogo = const AssetImage('Assets/IconEichwalde.png');

//Themes
ThemeData eichwaldeStandardTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: eichwaldeGreen,
    selectionHandleColor: eichwaldeGreen,
  ),
);
ThemeData eichwaldeDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: eichwaldeGreen,
    selectionHandleColor: eichwaldeGreen,
  ),
);

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = eichwaldeStandardTheme;
  bool _isDarkMode = false;
  bool _isLoaded = false;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _isLoaded;

  ThemeNotifier() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? eichwaldeDarkTheme : eichwaldeStandardTheme;
    notifyListeners();
    _saveTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currentTheme = _isDarkMode ? eichwaldeDarkTheme : eichwaldeStandardTheme;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}