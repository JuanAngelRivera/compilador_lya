import 'dart:io';

import 'package:compilador_lya/views/editor_view.dart';
<<<<<<< HEAD
=======
import 'package:file_picker/file_picker.dart';
>>>>>>> a4d1832e2b614655422bbd24ca56a15693e998ad
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ← agrega esto
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatefulWidget {
  const CodeEditorApp({super.key});

  @override
  State<CodeEditorApp> createState() => _CodeEditorAppState();
}

class _CodeEditorAppState extends State<CodeEditorApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LyA IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      ),
      home: IDEScreen(),
    );
  }
}

class IDEScreen extends StatefulWidget {
  IDEScreen({super.key});

  @override
  State<IDEScreen> createState() => _IDEScreenState();
}

class _IDEScreenState extends State<IDEScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Column(
        children: [
          _buildMenuBar(),
          Expanded(
<<<<<<< HEAD
            child: Row(children: [const Expanded(child: EditorView())]),
=======
            child: Row(
              children: [
                Expanded(child: EditorView(controller: controller)),
              ],
            ),
>>>>>>> a4d1832e2b614655422bbd24ca56a15693e998ad
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF181825),
        border: Border(
          bottom: BorderSide(color: Color(0xFF313145), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _MenuBarItem(label: 'Importar', onTap: open_file)
        ],
      ),
    );
  }

  Future<void> open_file() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'java', 'lya']
    );

    if(result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      setState(() {
        controller.value = TextEditingValue(
        text: content,
        selection: TextSelection.collapsed(offset: content.length) 
        );
      });
    }
  }
}

class _MenuBarItem extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  const _MenuBarItem({required this.label, required this.onTap});

  @override
  State<_MenuBarItem> createState() => _MenuBarItemState();
}

class _MenuBarItemState extends State<_MenuBarItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          widget.label,
          style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
        ),
      ),
    );
  }
}
