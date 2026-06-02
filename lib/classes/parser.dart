import 'package:compilador_lya/classes/token.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  void parse() {
    print('\nANÁLISIS SINTÁCTICO\n');
    programa();
    match('EOF');

    if(!isAtEnd()) {
      Token token = peek();
      throw Exception(
        "Token inesperado: '${token.lexeme}'/${token.type} en línea ${token.line}"
      );
    }
  }
  // helpers

  Token peek() {
    if(current >= tokens.length) {
      return tokens.last;
    }

    return tokens[current];
  }
  
  bool isAtEnd() {
    return current >= tokens.length;
  }

  Token match(String expectedType) {
    if (peek().type == expectedType) {
      return tokens[current++];
    }

    Token token = peek();
    throw Exception(
      "Error sintáctico en línea ${token.line}, columna ${token.column}. Se esperaba $expectedType y se encontró ${token.lexeme}"
    );
  }

  Token matchLexeme(String expectedLexeme) {
    if(peek().lexeme == expectedLexeme) {
      return tokens[current++];
    }

    throw Exception(
      "Se esperaba '$expectedLexeme' y se encontró '${peek().lexeme}' en línea ${peek().line}"
    );
  } 

  bool _isType(Token token) {
    return token.lexeme == 'int' ||
           token.lexeme == 'float' ||
           token.lexeme == 'booleano' ||
           token.lexeme == 'char';
  }

  bool _isStartOfSentence(Token token) {
    return _isType(token)||
           token.type == 'identificador' ||
           token.lexeme == 'si' ||
           token.lexeme == 'mientras';
  }


  // parser

  void programa() {
    sentencias();
  }

  void sentencias() {
    while(!isAtEnd() && _isStartOfSentence(peek())) {
      print('sentencia');
      sentencia();
    }
  }

  void sentencia() {
    Token token = peek();
    print(token.lexeme);
    
    if(_isType(token)) {
      declaracion();
    }
    else if(token.type == 'identificador') {
      asignacion();
    }
    else if(token.lexeme == 'si' && token.type == 'reservada') {
      secuenciaIf();
    }
    else if(token.lexeme == 'mientras' && token.type == 'reservada') {
      secuenciaWhile();
    }
    else {
      throw Exception(
        "Sentencia inválida en línea ${token.line}"
      );
    }
  }

  void declaracion() {
    print('declaracion');
    tipo();

    match('identificador');

    matchLexeme(';');
  }

  void tipo() {
    Token token = peek();

    if (_isType(token)) {
      current++;
    }
    else {
      throw Exception(
        "Se esperaba un tipo en línea ${token.line}"
      );
    }
  }

  void asignacion() {
    print('asignacion');
    match('identificador');

    matchLexeme('=');

    expresion();

    matchLexeme(';');
  }

  void expresion() {
    print('expresion');
    termino();
    
    expresionP();
  }

  void expresionP() {
    while (
      peek().lexeme == '+' ||
      peek().lexeme == '-') {
        current++;

        termino();
      }
  }

  void termino() {
    print('termino');
    factor();

    terminoP();
  }

  void terminoP() {
    while(
      peek().lexeme == '*' ||
      peek().lexeme == '/') {
        current++;

        factor();
      }
  }

  void factor() {
    print('factor');
    Token token = peek();

    if(token.type == 'identificador') {
      current++;
    }
    else if(token.type == 'numero') {
      current++;
    }
    else if(token.lexeme == '(') {
      current++;

      expresion();

      matchLexeme(')');
    }
    else {
      throw Exception(
        "Factor inválido en línea ${token.line}"
      );
    }
  }

  void secuenciaIf() {
    print('if');
    matchLexeme('si');

    matchLexeme('(');

    condicion();

    matchLexeme(')');

    bloque();

    elseOpcional();
  }

  void elseOpcional() {
    print('else');
    if(peek().lexeme == 'si_no') {
      matchLexeme('si_no');

      bloque();
    }
  }

  void condicion() {
    print('condicion');
    expresion();

    operadorRel();

    expresion();
  }

  void operadorRel() {
    String lexeme = peek().lexeme;

    if(
      lexeme == '<' ||
      lexeme == '>' ||
      lexeme == '<=' ||
      lexeme == '=<' ||
      lexeme == '==' ||
      lexeme == '!=') {
        current++;
      }
    else {
      throw Exception(
        "Se esperaba operador relacional en línea ${peek().line}"
      );
    }
  }

  void bloque() {
    print('bloque');
    matchLexeme('{');

    sentencias();

    matchLexeme('}');
  }

  void secuenciaWhile() {
    print('while');
    matchLexeme('mientras');

    matchLexeme('(');

    condicion();

    matchLexeme(')');

    bloque();
  }
}