import 'package:compilador_lya/utils/styles.dart';
import 'package:flutter/material.dart';
class FileWidget extends StatefulWidget {
  const FileWidget({super.key});

  @override
  State<FileWidget> createState() => _FileWidgetState();
}

class _FileWidgetState extends State<FileWidget> {
  List<String> list = ['Cargar', 'Exportar', 'Compilar'];

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      style: Styles.file_menu_style,
      children: [
        SubmenuButton(
          style: Styles.file_button_style,
          menuStyle: Styles.file_menu_style,
          menuChildren: [
            MenuItemButton(
              style: Styles.file_button_style,
              onPressed: (){},
              child: Text('Importar'),
            ),
            MenuItemButton(
              style: Styles.file_button_style,
              onPressed: (){},
              child: Text('Exportar'),
            ),
            MenuItemButton(
              style: Styles.file_button_style,
              onPressed: (){},
              child: Text('Compilar'),
            ),
          ], 
          child: Text('Archivo'))
      ],
    );
  }
}