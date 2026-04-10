import 'package:compilador_lya/widgets/lya_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final LyaCodeController codeController = LyaCodeController(
    text: '''void main() {
  print("Hello, Flutter Code Editor!");
}''',
    language: dart,
  );

  int _currentLine = 1;
  int _currentCol = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeController.analyzeCode();
    });
    codeController.addListener(_onCursorMove);
  }

  void _onCursorMove() {
    final text = codeController.text;
    final selection = codeController.selection;
    if (!selection.isValid) return;

    final before = text.substring(0, selection.baseOffset);
    final lines = before.split('\n');
    setState(() {
      _currentLine = lines.length;
      _currentCol = lines.last.length + 1;
    });
  }

  @override
  void dispose() {
    codeController.removeListener(_onCursorMove);
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(child: _buildEditor()),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 40,
      color: IDEColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _ToolbarButton(
            label: '▶  Ejecutar',
            color: IDEColors.green,
            textColor: IDEColors.bg,
            onPressed: () => codeController.analyzeCode(),
          ),
          const SizedBox(width: 6),
          _ToolbarButton(label: '↩  Deshacer', onPressed: () {}),
          const SizedBox(width: 6),
          _ToolbarButton(label: '↪  Rehacer', onPressed: () {}),
          const _ToolbarSeparator(),
          _ToolbarButton(label: '⚙  Configurar', onPressed: () {}),
          const Spacer(),
          Text(
            'LyA IDE',
            style: TextStyle(
              color: IDEColors.textMuted,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      color: IDEColors.bg,
      child: CodeTheme(
        data: CodeThemeData(styles: monokaiSublimeTheme),
        child: SingleChildScrollView(
          child: CodeField(
            controller: codeController,
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  // barra de estatus

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: IDEColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatusItem(icon: '✓', label: 'Sin errores'),
          const SizedBox(width: 16),
          _StatusItem(label: 'LyA'),
          const Spacer(),
          _StatusItem(label: 'Ln $_currentLine, Col $_currentCol'),
          const SizedBox(width: 16),
          _StatusItem(label: 'UTF-8'),
          const SizedBox(width: 16),
          _StatusItem(label: 'Espacios: 2'),
        ],
      ),
    );
  }
}

// Paleta de colores

class IDEColors {
  static const bg = Color(0xFF1E1E2E);
  static const surface = Color(0xFF181825);
  static const overlay = Color(0xFF313145);
  static const accent = Color(0xFFCBA6F7);
  static const textMain = Color(0xFFCDD6F4);
  static const textMuted = Color(0xFF6E6C87);
  static const green = Color(0xFFA6E3A1);
  static const red = Color(0xFFF38BA8);
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const _ToolbarButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color ?? IDEColors.overlay,
        foregroundColor: textColor ?? IDEColors.textMain,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        textStyle: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
      ),
      child: Text(label),
    );
  }
}

class _ToolbarSeparator extends StatelessWidget {
  const _ToolbarSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: IDEColors.overlay,
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String? icon;

  const _StatusItem({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Text(
            icon!,
            style: const TextStyle(fontSize: 11, color: IDEColors.bg),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: IDEColors.bg,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
