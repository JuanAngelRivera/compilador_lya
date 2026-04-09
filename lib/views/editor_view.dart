//import 'package:compilador_lya/widgets/file_widget.dart';
import 'package:compilador_lya/widgets/lya_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/languages/dart.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final codeController = LyaCodeController(
    text: 
      '''
      void main() {
        print("Hello, Flutter Code Editor!");
      }
      ''',
    language: dart,
    );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    codeController.analyzeCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CodeTheme(
        data: CodeThemeData(styles: githubTheme),
        child: CodeField(controller: codeController),
      ),
    );
  }
}
