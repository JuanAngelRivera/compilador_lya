import 'dart:async';

import 'package:compilador_lya/classes/lexer.dart';
import 'package:compilador_lya/classes/token.dart';
import 'package:compilador_lya/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Code_editor extends StatefulWidget {
  const Code_editor({super.key});

  @override
  State<Code_editor> createState() => _Code_editorState();
}

class _Code_editorState extends State<Code_editor> {

  TextEditingController controller = TextEditingController();
  final ScrollController scroll_controller = ScrollController();

  List<Token> tokens = [];
  Timer? debounce;

  int get line_count {
    return '\n'.allMatches(controller.text).length + 1;
  }
  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      update_tokens();
    });
  }

  void update_tokens() {
    debounce?.cancel();
    debounce = Timer(Duration(milliseconds: 100), () {
      setState(() {
        tokens = Lexer(controller.text).tokenize();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.overlay,
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        controller: scroll_controller,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            build_line_numbers(),
        
            Expanded(
              child: Stack(
                children: [
                  RichText(text: build_text()),
                  Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.tab) {
                        final selection = controller.selection;
                        final text = controller.text;
                        const tab_spaces = '    ';
              
                        if (selection.isValid) {
                          final newText = text.replaceRange(
                            selection.start,
                            selection.end,
                            tab_spaces,
                          );
                          controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(
                              offset: selection.start + tab_spaces.length,
                            ),
                          );
                        }
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      style: Styles.code_editor_base.copyWith(
                        color: Colors.transparent,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan build_text() {
    List<InlineSpan> spans = [];
    int current = 0;

    for (var t in tokens) {
      if (current < t.position) {
        spans.add(
          TextSpan(
            text: normalize(controller.text.substring(current, t.position)),
            style: Styles.code_editor_base,
          ),
        );
      }

      Color color = get_color(t.type);

      spans.add(
        TextSpan(
          text: normalize(t.lexeme),
          style: Styles.code_editor_base.copyWith(
            color: color,
            decoration: color == Colors.red ? TextDecoration.underline : null,
          ),
        ),
      );

      current = t.position + t.length;
    }

    if (current < controller.text.length) {
      spans.add(
        TextSpan(
          text: controller.text.substring(current),
          style: Styles.code_editor_base,
        ),
      );
    }

    return TextSpan(style: Styles.code_editor_base, children: spans);
  }

  String normalize(String text) {
    return text.replaceAll('\t', '    ');
  }

  Color get_color(String type) {
    switch (type) {
      case 'reservada':
        return Colors.blue;
      case 'identificador':
        return Colors.white;
      case 'numero':
        return Colors.orange;
      case 'simbolo':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  int get_current_line() {
    int cursor = controller.selection.start;

    if (cursor < 0) {
      return 1;
    }

    String text_before_cursor = controller.text.substring(0, cursor);
    return  '\n'.allMatches(text_before_cursor).length + 1;
  }

  Container build_line_numbers() {
    int current_line = get_current_line();

    return Container(
      width: 40,
      padding: EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(line_count, (index) {
          return Text(
            '${index + 1}',
            style: Styles.code_editor_base.copyWith(
              color: (index + 1 == current_line) ? Colors.white : Colors.grey),
          );
        }),
      ),
    );
  }
}
