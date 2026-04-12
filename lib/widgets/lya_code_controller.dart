import 'package:compilador_lya/classes/lexer.dart';
import 'package:compilador_lya/classes/symb_table.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/highlight.dart' show Mode;

final _lyaLanguage = Mode(
  refs: {},
  keywords: {'keyword': Lexer.reserved_words},
  contains: [
    Mode(className: 'number',      begin: r'\b\d+(\.\d+)?\b'),
    Mode(className: 'string',      begin: '"',  end: '"'),
    Mode(className: 'comment',     begin: '//', end: r'$'),
    Mode(className: 'comment',     begin: r'/\*', end: r'\*/'),
    Mode(className: 'punctuation', begin: r'[=;{}\(\)]'),
  ],
);

class LyaCodeController extends CodeController {
  SymbolTableHash? _symbolTable;

  LyaCodeController({required String text})
      : super(text: text, language: _lyaLanguage) {
    _initSymbolTable();
  }

  Future<void> _initSymbolTable() async {
    _symbolTable = await SymbolTableHash.create();
    print('Tabla de símbolos lista');
  }

  @override
  Future<void> analyzeCode() async {
    if (_symbolTable == null) {
      print('Tabla aún no inicializada');
      return;
    }

    // Limpieza de la tabla antes de cada análisis
    await _symbolTable!.clear();

    final lexer  = Lexer(text);

    final tokens = await lexer.tokenizeAndRegister(_symbolTable!);

    for (final token in tokens) {
      print(token);
    }

    _symbolTable!.printHashTable();
  }
}