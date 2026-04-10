import 'package:compilador_lya/widgets/code_editor_widget.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lya_code_editor',
      home: Scaffold(
        body: Code_editor(),
      ),
    );
  }
}