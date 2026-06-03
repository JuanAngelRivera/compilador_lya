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
    required this.onParse,
  });

  @override
  State<Code_editor> createState() => Code_editorState();
}

class Code_editorState extends State<Code_editor> {
  final ScrollController scroll_controller = ScrollController();
  final ScrollController scroll_controller_h = ScrollController();

  List<Token> tokens = [];
  List<SyntaxError> syntaxErrors = [];
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
    syntaxErrors.clear();
    final symbolTable = await SymbolTableHash.create();
    final tokens = await Lexer(
      widget.controller.text,
    ).tokenizeAndRegister(symbolTable);
    Parser parser = Parser(tokens);

    try {
      parser.parse();
      syntaxErrors = parser.errors;
    } catch (e) {
      print(e);
    }

    setState(() {
      this.tokens = tokens;
      //symbolTable.printHashTable();
    });

    widget.onTokensChanged?.call(tokens);
    widget.onParse?.call(parser.errors);
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
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.tab) {
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

                                  return KeyEventResult.handled;
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
    final tokenErrors = syntaxErrors.where((e) => e.length > 1).toList();
    final missingErrors = syntaxErrors.where((e) => e.length == 1).toList();
    final tokenPositions = tokenErrors.map((e) => e.position).toSet();
    final missingPositions = missingErrors.map((e) => e.position).toSet();

    for (var e in missingErrors) {
      print('missing: pos=${e.position}, line=${e.line}, col=${e.column}');
    }

    for (var t in tokens) {
      print('${t.lexeme} pos=${t.position} len=${t.length}');
    }

    for (var t in tokens) {
      if (t.type == 'EOF') {
        continue;
      }

      bool hasError = tokenPositions.contains(t.position);
      bool missingAfter = missingPositions.contains(t.position + t.length);
      bool missingGap = missingErrors.any(
        (e) => e.position >= current && e.position < t.position,
      );

      print(hasError);
      print(missingAfter);
      print(missingGap);
      if (current < t.position) {
        spans.add(
          TextSpan(
            text: normalize(
              widget.controller.text.substring(current, t.position),
            ),
            style: Styles.code_editor_base.copyWith(
              decoration: missingGap ? TextDecoration.underline : null,
              color: missingGap ? Colors.red : Styles.code_editor_base.color,
            ),
          ),
        );
      }

      Color color = get_color(t.type);

      spans.add(
        TextSpan(
          text: normalize(t.lexeme),
          style: Styles.code_editor_base.copyWith(
            color: (hasError || missingAfter) ? Colors.red : color,
            decoration: (color == Colors.red || hasError || missingAfter)
                ? TextDecoration.underline
                : null,
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
    final errorLines = syntaxErrors.map((e) => e.line).toSet();

    return Container(
      width: 40,
      padding: EdgeInsets.only(right: 5),
      color: Styles.overlay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(line_count, (index) {
          final lineNumber = index + 1;
          final hasError = errorLines.contains(lineNumber);

          return Container(
            width: 40,
            color: hasError ? Colors.red.withValues(alpha: 0.15) : Colors.transparent,
            alignment: Alignment.centerRight,
            child: Text(
              '$lineNumber',
              style: Styles.code_editor_base.copyWith(
                color: hasError
                    ? Colors.red
                    : (lineNumber == current_line ? Colors.white : Colors.grey),
              ),
            ),
          );
        }),
      ),
    );
  }
}
