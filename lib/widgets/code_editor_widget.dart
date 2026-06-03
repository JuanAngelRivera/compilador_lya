import 'dart:async';
import 'package:compilador_lya/classes/lexer.dart';
import 'package:compilador_lya/classes/parser.dart';
import 'package:compilador_lya/classes/symb_table.dart';
import 'package:compilador_lya/classes/syntax_error.dart';
import 'package:compilador_lya/classes/token.dart';
import 'package:compilador_lya/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Code_editor extends StatefulWidget {
  final TextEditingController controller;
  final Function(int line, int col)? onCursorChanged;
  final Function(List<Token>)? onTokensChanged;
  final Function(List<SyntaxError>)? onParse;

  const Code_editor({
    super.key,
    required this.controller,
    required this.onCursorChanged,
    required this.onTokensChanged,
    required this.onParse
  });

  @override
  State<Code_editor> createState() => Code_editorState();
}

class Code_editorState extends State<Code_editor> {
  final ScrollController scroll_controller = ScrollController();
  final ScrollController scroll_controller_h = ScrollController();

  List<Token> tokens = [];
  Timer? debounce;

  int get line_count {
    return '\n'.allMatches(widget.controller.text).length + 1;
  }

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      final line = get_current_line();
      final column = get_current_column();

      widget.onCursorChanged?.call(line, column);
      update_tokens();
    });
  }

  void update_tokens() {
    debounce?.cancel();
    debounce = Timer(Duration(milliseconds: 100), () {
      setState(() {
        tokens = Lexer(widget.controller.text).tokenize();
        widget.onTokensChanged?.call(tokens);
      });
    });
  }

  Future<void> runFullAnalysis() async {
    final symbolTable = await SymbolTableHash.create();
    final tokens = await Lexer(widget.controller.text).tokenizeAndRegister(symbolTable);
    Parser parser = Parser(tokens);

    try {
      parser.parse();

      print("Análisis sintáctico correcto");
    }
    catch(e) {
      print(e);

    }

    widget.onParse?.call(parser.errors);

    setState(() {
      this.tokens = tokens;
      //symbolTable.printHashTable();
    });

    widget.onTokensChanged?.call(tokens);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.overlay,
      padding: EdgeInsets.all(12),
      // 1. SCROLLBAR VERTICAL (Padre de todo)
      child: Scrollbar(
        controller: scroll_controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scroll_controller,
          scrollDirection: Axis.vertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              build_line_numbers(),
              Expanded(
                child: Scrollbar(
                  controller: scroll_controller_h,
                  thumbVisibility: true,
                  notificationPredicate: (n) => n.depth == 1,
                  child: SingleChildScrollView(
                    controller: scroll_controller_h,
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicWidth(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width + 100,
                        ),
                        child: Stack(
                          children: [
                            RichText(softWrap: false, text: build_text()),
                            Focus(
                              onKeyEvent: (node, event) {
                                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
                                  final selection = widget.controller.selection;
                                  final text = widget.controller.text;
                                  const tabSpaces = '    ';

                                  if (selection.isValid) {
                                    final newText = text.replaceRange(
                                      selection.start,
                                      selection.end,
                                      tabSpaces,
                                    );

                                    widget.controller.value = TextEditingValue(
                                      text: newText,
                                      selection: TextSelection.collapsed(
                                        offset:
                                            selection.start + tabSpaces.length,
                                      ),
                                    );
                                  }

                                  return KeyEventResult
                                      .handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: widget.controller,
                                maxLines: null,
                                style: Styles.code_editor_base.copyWith(
                                  color: Colors.transparent,
                                ),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            text: normalize(
              widget.controller.text.substring(current, t.position),
            ),
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

    if (current < widget.controller.text.length) {
      spans.add(
        TextSpan(
          text: widget.controller.text.substring(current),
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
        return Colors.greenAccent;
      case 'simbolo':
        return Colors.yellow;
      case 'EOF':
        return Colors.transparent;
      default:
        return Colors.red;
    }
  }

  int get_current_line() {
    int cursor = widget.controller.selection.start;

    if (cursor < 0 || cursor > widget.controller.text.length) {
      return 1;
    }

    String text_before_cursor = widget.controller.text.substring(0, cursor);
    return '\n'.allMatches(text_before_cursor).length + 1;
  }

  int get_current_column() {
    int cursor = widget.controller.selection.start;

    if (cursor < 0 || cursor > widget.controller.text.length) {
      return 1;
    }

    String text_before_cursor = widget.controller.text.substring(0, cursor);
    int last_newline = text_before_cursor.lastIndexOf('\n');

    return cursor - (last_newline + 1) + 1;
  }

  Container build_line_numbers() {
    int current_line = get_current_line();

    return Container(
      width: 40,
      padding: EdgeInsets.only(right: 5),
      color: Styles.overlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(line_count, (index) {
          return Text(
            '${index + 1}',
            style: Styles.code_editor_base.copyWith(
              color: (index + 1 == current_line) ? Colors.white : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}