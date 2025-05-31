import 'package:flutter/material.dart';

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

  //InputDecorationTheme
  //ColorScheme? colorScheme,
  //Brightness? brightness,
  //cardColor: Color.fromARGB(255, 125, 125, 125),
  //Color? disabledColor,
  //Color? focusColor,
  //Color? highlightColor,
  //Color? hintColor,
  //Color? hoverColor,
  //Color? primaryColor,
  //Color? primaryColorDark,
  //Color? primaryColorLight,
  //Color? scaffoldBackgroundColor,
  //Color? secondaryHeaderColor,
  //Color? shadowColor,
  //Color? splashColor,
  //Color? unselectedWidgetColor,
  //Color? dialogBackgroundColor,
  //Color? indicatorColor,

  //IconThemeData? iconTheme,
  //IconThemeData? primaryIconTheme,
  //ActionIconThemeData? actionIconTheme,
  //AppBarTheme? appBarTheme,
  //BottomNavigationBarThemeData? bottomNavigationBarTheme,
  //BottomSheetThemeData? bottomSheetTheme,
  //ButtonThemeData? buttonTheme,
  //CardThemeData? cardTheme,
  //ChipThemeData? chipTheme,
  //DialogThemeData? dialogTheme,
  //DropdownMenuThemeData? dropdownMenuTheme,
  //ExpansionTileThemeData? expansionTileTheme,
  //IconButtonThemeData? iconButtonTheme,
  //ListTileThemeData? listTileTheme,
  //NavigationBarThemeData? navigationBarTheme,
  //ProgressIndicatorThemeData? progressIndicatorTheme,
  //SearchBarThemeData? searchBarTheme,
  //SnackBarThemeData? snackBarTheme,
  //SwitchThemeData? switchTheme,
  //TextButtonThemeData? textButtonTheme,
  //TooltipThemeData? tooltipTheme,

  //z.B. primary eichwaldeGreen => variable ersetzen durch theme.of
);
ThemeData eichwaldeDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
);
//ThemeData eichwaldeSpackenTheme = ThemeData(

//);

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme;
  bool _isDarkMode;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  ThemeNotifier({bool isDarkMode = false})
      : _isDarkMode = isDarkMode,
        _currentTheme = isDarkMode ? eichwaldeDarkTheme : eichwaldeStandardTheme;

  /*ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currentTheme = _isDarkMode ? eichwaldeDarkTheme : eichwaldeStandardTheme;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
  */

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? eichwaldeDarkTheme : eichwaldeStandardTheme;
    notifyListeners();
  }

  void setTheme(String theme) {
    if (theme == 'light') {
      _currentTheme = eichwaldeStandardTheme;
    } else if (theme == 'dark') {
      _currentTheme = eichwaldeDarkTheme;
    }//..weitere theme sachen wie adhs und so
    notifyListeners();
  }
}