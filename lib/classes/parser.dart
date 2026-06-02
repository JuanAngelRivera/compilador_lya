import 'package:compilador_lya/classes/token.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  void parse() {
    programa();

    if(!isAtEnd()) {
      Token token = peek();
      throw Exception(
        "Token inesperado: '${token.lexeme}' en línea ${token.line}"
      );
    }
  }
  // helpers

  Token peek() {
    return tokens[current];
  }
  
  bool isAtEnd() {
    return current >= tokens.length;
  }

  Token match(String expectedType) {
    if (peek().type == expectedType) {
      return tokens[current++];
    }

    throw Exception(
      "Se esperaba $expectedType pero se encontró ${peek().type}"
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
           token.lexeme == 'identificador' ||
           token.lexeme == 'si' ||
           token.lexeme == 'mientras';
  }


  // parser

  void programa() {
    sentencias();
  }

  void sentencias() {
    while(!isAtEnd() && _isStartOfSentence(peek())) {
      sentencia();
    }
  }

  void sentencia() {
    Token token = peek();
    
    if(_isType(token)) {
      declaracion();
    }
    else if(token.type == 'identificador') {
      asignacion();
    }
    else if(token.lexeme == 'si') {
      secuenciaIf();
    }
    else if(token.lexeme == 'mientras') {
      secuenciaWhile();
    }
    else {
      throw Exception(
        "Sentencia inválida en línea ${token.line}"
      );
    }
  }

  void declaracion() {
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
    match('identificador');

    matchLexeme('=');

    expresion();

    matchLexeme(';');
  }

  void expresion() {
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
    matchLexeme('si');

    matchLexeme('(');

    condicion();

    matchLexeme(')');

    bloque();

    elseOpcional();
  }

  void elseOpcional() {
    if(peek().lexeme == 'si_no') {
      matchLexeme('si_no');

      bloque();
    }
  }

  void condicion() {
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
    matchLexeme('{');

    sentencias();

    matchLexeme('}');
  }

  void secuenciaWhile() {
    matchLexeme('mientras');

    matchLexeme('(');

    condicion();

    matchLexeme(')');

    bloque();
  }
}