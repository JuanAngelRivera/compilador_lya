import 'package:compilador_lya/views/editor_view.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ← agrega esto
  runApp(const CodeEditorApp());
}

class CodeEditorApp extends StatelessWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LyA IDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      ),
      home: const IDEScreen(),
    );
  }
}

class IDEScreen extends StatelessWidget {
  const IDEScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Column(
        children: [
          _buildMenuBar(),
          Expanded(
            child: Row(children: [const Expanded(child: EditorView())]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF181825), // ← color aquí dentro
        border: Border(
          bottom: BorderSide(color: Color(0xFF313145), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final item in ['Archivo', 'Editar', 'Ver', 'Ejecutar', 'Ayuda'])
            _MenuBarItem(label: item),
        ],
      ),
    );
  }
}

class _MenuBarItem extends StatelessWidget {
  final String label;
  const _MenuBarItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
        ),
      ),
    );
  }
}
