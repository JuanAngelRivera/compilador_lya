import 'package:compilador_lya/classes/dfa_identifier.dart';
import 'package:compilador_lya/classes/dfa_number.dart';
import 'package:compilador_lya/classes/match_token.dart';
import 'package:compilador_lya/classes/symb_table.dart';
import 'package:compilador_lya/classes/token.dart';

class Lexer {
  final String input;
  int position = 0;
  int line = 1;
  int column = 1;

  Lexer(this.input);

  static List<String> reserved_words = [
    'abstracto', //abstract
    'asume', //assert
    'booleano', //boolean
    'rompe', //break
    'byte',
    'caso', //case
    'atrapa', //catch
    'char',
    'clase', //class
    'constante', //const
    'continua', //continue
    'por_defecto', //default
    'haz', //do
    'double',
    'si_no', //else
    'enumerado', //enum
    'hereda', //extends
    'final',
    'finalmente', //finally
    'float',
    'para', //for
    'ir_a', //goto
    'si', //if
    'implementa', //implements
    'importa', //import
    'instancia_de', //instanceof
    'int',
    'interfaz', //interface
    'long',
    'nativo', //native
    'nuevo', //new
    'paquete', //package
    'privado', //private
    'protegido', //protected
    'publico', //public
    'retorna', //return
    'short',
    'estatico', //static
    'pf_estricto', //estrictfp
    'super',
    'compara', //switch
    'syncronizado', //sinchronized
    'esto', //this
    'lanza', //throw
    'lanza_varios', //throws
    'no_serializar', //transient
    'intenta', //try
    'vacio', //void
    'volatil', //volatile
    'mientras', //while
    'cadena', // String
    'verdadero',
    'falso'
  ];

  List<String> symbols = [
    // asignación
    '=', '+=', '-=', '*=', '/=', '%=',
    // aritméticos
    '+', '-', '*', '/', '%', '++', '--',
    // relacionales
    '<', '>', '<=', '>=', '==', '!=',
    // lógicos
    '&&', '||', '!',
    // delimitadores
    '(', ')', '{', '}', '[', ']', ';', ',',
    // acceso / otros
    '.', ':', '?', '@',
  ];

  bool is_symbol(String char) {
    return symbols.contains(char);
  }

  List<Token> tokenize() {
    List<Token> tokens = [];

    while (position < input.length) {
      if (is_white_space(input[position])) {
        advance();
        continue;
      }

      int start_position = position;
      int start_line = line;
      int start_column = column;

      MatchToken? match = matchString() ?? matchNumber() ?? matchIdentifier() ?? matchSimbol();

      if (match == null) {
        int error_start = position;
        int error_line = line;
        int error_column = column;

        advance();

        while (position < input.length &&
            !is_white_space(input[position]) &&
            !is_symbol(input[position])) {
          advance();
        }

        String error_lexeme = input.substring(error_start, position);

        tokens.add(
          Token('error', error_lexeme, error_start, error_line, error_column),
        );

        continue;
      }

      if (reserved_words.contains(match.lexeme)) {
        match = MatchToken('reservada', match.lexeme);
      }

      Token full_token = Token(
        match.type,
        match.lexeme,
        start_position,
        start_line,
        start_column,
      );

      tokens.add(full_token);

      for (int i = 0; i < match.length; i++) {
        advance();
      }
    }

    return tokens;
  }

  MatchToken? matchNumber() {
    var dfa = DfaNumber(input, position);
    return dfa.recognize();
  }

  MatchToken? matchIdentifier() {
    var dfa = DfaIdentifier(input, position);
    return dfa.recognize();
  }

  MatchToken? matchString() {
    if(position >= input.length) {
      return null;
    }

    String delimiter = input[position];

    if(delimiter != "'" && delimiter != '"') {
      return null;
    }

    int i = position + 1;

    while(i < input.length && input[i] != delimiter) {
      i++;
    }

    if(i >= input.length) {
      return MatchToken('error', input.substring(position));
    }

    String lexeme = input.substring(position, i + 1);

    return MatchToken('cadena', lexeme);
  }

  MatchToken? matchSimbol() {
    String char = input[position];

    if (position + 1 < input.length) {
      String twoChars = input.substring(position, position + 2);
      if (symbols.contains(twoChars)) {
        return MatchToken('simbolo', twoChars);
      }
    }
    
    if (is_symbol(char)) {
      return MatchToken('simbolo', char);
    }
    /*switch(char) {
      case '=':
        return MatchToken('igual', char, 1);
      case ';':
        return MatchToken('punto_coma', char, 1);
      case '{':
        return MatchToken('llave_abierta', char, 1);
      case '}':
        return MatchToken('llave_cierra', char, 1);
      case '(':
        return MatchToken('parentesis_abierto', char, 1);
      case ')':
        return MatchToken('parentesis_cerrado', char, 1);
      default:
        return null;
    }*/
    return null;
  }

  bool is_white_space(String char) {
    return char == ' ' || char == '\n' || char == '\t' || char == '\r';
  }

  void advance() {
    if (input[position] == '\n') {
      line++;
      column = 1;
    } else {
      column++;
    }
    position++;
  }

  //Registro de tokens en la tabla de simbolos y captura de colisiones 

  Future<List<Token>> tokenizeAndRegister(SymbolTableHash symbolTable) async {
    List<Token> tokens = [];
    int absolutePosition = 0;

    while (position < input.length) {
      if (is_white_space(input[position])) {
        advance();
        absolutePosition++;
        continue;
      }

      int startPosition = absolutePosition;
      int startLine = line;
      int startColumn = column;
      MatchToken? match = matchString() ?? matchNumber() ?? matchIdentifier() ?? matchSimbol();

      if (match == null) {
        int error_start = position;
        int error_line = line;
        int error_column = column;

        advance();

        while (position < input.length &&
            !is_white_space(input[position]) &&
            !is_symbol(input[position])) {
          advance();
        }

        String error_lexeme = input.substring(error_start, position);
        tokens.add(
          Token('error', error_lexeme, error_start, error_line, error_column),
        );

        int prevCollisions =
            symbolTable.getHashStats()['total_collisions'] as int;

        SymbolEntry entry = await symbolTable.registerToken(
          lexeme: error_lexeme,
          type: 'error',
          position: error_start,
          line: error_line,
          column: error_column,
        );

        int newCollisions =
            (symbolTable.getHashStats()['total_collisions'] as int) -
            prevCollisions;
        if (newCollisions > 0) {
          print(
            'Colisión en error "$error_lexeme" | Renglón final: ${entry.memoryAddress} | Saltos requeridos: $newCollisions',
          );
        }

        absolutePosition++;
        continue;
      }

      String finalType = match.type;
      if (reserved_words.contains(match.lexeme)) {
        finalType = 'reservada';
      }

      tokens.add(
        Token(finalType, match.lexeme, startPosition, startLine, startColumn),
      );

      if (finalType != 'reservada' && !symbolTable.existsLexeme(match.lexeme)) {
        // colisiones actuales
        int prevCollisions =
            symbolTable.getHashStats()['total_collisions'] as int;

        SymbolEntry entry = await symbolTable.registerToken(
          lexeme: match.lexeme,
          type: finalType,
          position: startPosition,
          line: startLine,
          column: startColumn,
          value: finalType == 'numero' ? num.tryParse(match.lexeme) : null,
        );

        // captura de colisiones

        int newCollisions =
            (symbolTable.getHashStats()['total_collisions'] as int) -
            prevCollisions;
        if (newCollisions > 0) {
          print(
            'Colisión en token "${match.lexeme}" | Renglón final: ${entry.memoryAddress} | Saltos requeridos: $newCollisions',
          );
        }
      }

      for (int i = 0; i < match.length; i++) {
        advance();
        absolutePosition++;
      }
    }

    tokens.add(Token('EOF', 'EOF', position, line, column));

    return tokens;
  }
}
