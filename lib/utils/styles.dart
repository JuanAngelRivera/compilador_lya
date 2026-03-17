import 'package:flutter/material.dart';

class Styles {
  static Size button_size = Size(100, 20);
  static MenuStyle file_menu_style = MenuStyle(
    fixedSize: WidgetStatePropertyAll(button_size),
    backgroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
    shadowColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
  );

  static ButtonStyle file_button_style  = ButtonStyle(
    fixedSize: WidgetStatePropertyAll(button_size),
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0)
  );
}