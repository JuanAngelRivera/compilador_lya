import 'package:compilador_lya/classes/lexer.dart';
import 'package:compilador_lya/utils/styles.dart';
import 'package:compilador_lya/widgets/code_editor_widget.dart';
import 'package:flutter/material.dart';

class EditorView extends StatefulWidget {
  final TextEditingController controller;
  const EditorView({super.key, required this.controller});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late Code_editor code_editor;
  int _currentLine = 1;
  int _currentCol = 1;

  @override
  void initState() {
    super.initState();
    code_editor = Code_editor(controller: widget.controller);
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
      color: Styles.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _ToolbarButton(
            label: '▶  Ejecutar',
            color: Styles.green,
            textColor: Styles.bg,
            onPressed: () => {} 
          ),
          /*const SizedBox(width: 6),
          _ToolbarButton(label: '↩  Deshacer', onPressed: () {}),
          const SizedBox(width: 6),
          _ToolbarButton(label: '↪  Rehacer', onPressed: () {}),
          const _ToolbarSeparator(),
          _ToolbarButton(label: '⚙  Configurar', onPressed: () {}),*/
          const Spacer(),
          Text(
            'LyA IDE',
            style: TextStyle(
              color: Styles.textMuted,
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
      color: Styles.bg,
      child: code_editor
    );
  }

  // barra de estatus

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: Styles.accent,
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
        backgroundColor: color ?? Styles.overlay,
        foregroundColor: textColor ?? Styles.textMain,
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
      color: Styles.overlay,
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
            style: const TextStyle(fontSize: 11, color: Styles.bg),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Styles.bg,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
