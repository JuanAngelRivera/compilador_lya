import 'package:compilador_lya/classes/syntax_error.dart';
import 'package:compilador_lya/classes/token.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;
  final List<SyntaxError> errors = [];

  Parser(this.tokens);

  void parse() {
    if(tokens.isEmpty) {
      return;
    }

    print('\nANÁLISIS SINTÁCTICO\n');
    programa();
    match('EOF');

    if(!isAtEnd()) {
      Token token = peek();
      error(
        token.line, 
        token.column,
        token.position,
        token.length,
        "Token inesperado: '${token.lexeme}'/${token.type}");
      current++;
      return;
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
    return current >= tokens.length || tokens[current].type == 'EOF';
  }

  Token match(String expectedType) {
  Token token = peek();

  if (token.type == expectedType) {
    if (!isAtEnd()) {
      current++;
    }
    return token;
  }

  error(
    token.line,
    token.column,
    token.position,
    1,
    "Se esperaba $expectedType");
  synchronize();
  
  return token;
}

  Token matchLexeme(String expectedLexeme) {
    Token token = peek();

    if(token.lexeme == expectedLexeme) {
      current++;
      return token;
    }

    error(
      token.line,
      token.column,
      token.position,
      1, 
      "Se esperaba '$expectedLexeme'");
    synchronize();

    return token;
  } 

  bool _isType(Token token) {
    return token.lexeme == 'int' ||
           token.lexeme == 'float' ||
           token.lexeme == 'booleano' ||
           token.lexeme == 'cadena' ||
           token.lexeme == 'char';
  }

  bool _isStartOfSentence(Token token) {
    return _isType(token)||
           token.type == 'identificador' ||
           token.lexeme == 'si' ||
           token.lexeme == 'mientras';
  }

  void error(int line, int column, int position, int length, String message) {
    errors.add(
      SyntaxError(
        line,
        column,
        position,
        length, 
        message
      ));
  }

  void synchronize() {
    current++;

    while(!isAtEnd()) {
      if(_isStartOfSentence(peek())) return;

      if(peek().lexeme == ";") {
        current++;
        return;
      }
      current++;
    }
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
      error(
        token.line,
        token.column,
        token.position,
        token.length,
        "Sentencia inválida");
      current++;
      return;
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
      error(
        token.line,
        token.column,
        token.position,
        1,
        "Se esperaba un tipo de dato");
      current++;
      return;
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
    else if(_isLiteral()) {
      current++;
    }
    else if(token.lexeme == '(') {
      current++;

      expresion();

      matchLexeme(')');
    }
    else {
      error(
        token.line,
        token.column,
        token.position,
        token.length, 
        "Factor inválido");
      current++;
      return;
    }
  }

  bool _isLiteral() {
    print('literal');
    Token token = peek();

    return token.type == 'numero' ||
       token.type == 'cadena' ||
       token.lexeme == 'verdadero' ||
       token.lexeme == 'falso';
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

    condicionP();
  }

  void condicionP() {
    Token token = peek();

    if (token.lexeme == '&&' || token.lexeme == '||') {
      current++;

      condicion();
    }
  }

  void operadorRel() {
    Token token = peek();
    String lexeme = token.lexeme;

    if(
      lexeme == '<' ||
      lexeme == '>' ||
      lexeme == '<=' ||
      lexeme == '>=' ||
      lexeme == '==' ||
      lexeme == '!=') {
        current++;
      }
    else {
      error(
        token.line,
        token.column,
        token.position,
        1,
        "Se esperaba operador relacional");
      current++;
      return;
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