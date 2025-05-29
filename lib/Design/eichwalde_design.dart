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
  //z.B. primary eichwaldeGreen => variable ersetzen durch theme.of
);
ThemeData eichwaldeDarkTheme = ThemeData(
  useMaterial3: true,
);
//ThemeData eichwaldeSpackenTheme = ThemeData(

//);