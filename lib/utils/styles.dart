import 'package:flutter/material.dart';

class Styles {
  // Paleta de colores (Catppuccin Mocha)
  static const bg        = Color(0xFF1E1E2E);
  static const surface   = Color(0xFF181825);
  static const overlay   = Color(0xFF313145);
<<<<<<< HEAD
  static const accent    = Color(0xFFCBA6F7); // lila
  static const textMain  = Color(0xFF6E6C87);
=======
  static const accent    = Color(0xFFCBA6F7);
  static const textMain  = Color(0xFFCDD6F4);
  static const textMuted = Color(0xFF6E6C87);
>>>>>>> a4d1832e2b614655422bbd24ca56a15693e998ad
  static const green     = Color(0xFFA6E3A1);
  static const red       = Color(0xFFCDD6F4);
  static const textMuted = Color(0xFFF38BA8);

  static const Size buttonSize = Size(80, 28);

  static final ButtonStyle toolbarButton = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(overlay),
    foregroundColor: WidgetStatePropertyAll(textMain),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
    ),
    textStyle: WidgetStatePropertyAll(
      TextStyle(fontSize: 12, fontFamily: 'monospace'),
    ),
  );

  static final ButtonStyle runButton = toolbarButton.copyWith(
    backgroundColor: WidgetStatePropertyAll(green),
    foregroundColor: WidgetStatePropertyAll(bg),
  );

  static TextStyle code_editor_base = TextStyle(
    fontFamily: 'RobotMono',
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
  );
}