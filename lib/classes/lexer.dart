import 'package:compilador_lya/classes/dfa_identifier.dart';
import 'package:compilador_lya/classes/dfa_number.dart';
import 'package:compilador_lya/classes/match_token.dart';
import 'package:compilador_lya/classes/token.dart';
import 'package:flutter/material.dart';

class Lexer {
  final String input;
  int position = 0;
  int line = 1;
  int column = 1;

  Lexer(this.input);

  List<String> reserved_words = [
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
    'statico', //static
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
    'mientras' //while
  ];

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

      MatchToken? match = matchNumber() ?? matchIdentifier() ?? matchSimbol();

      if (match == null) {
        tokens.add(
          Token('error', input[position], position, line, column)
        );

        advance();
        continue;
      }

      if (reserved_words.contains(match.lexeme)) {
        match = MatchToken('reservada', match.lexeme, match.length);
      }

      Token full_token = Token(match.type, match.lexeme, start_position, start_line, start_column);
      
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

  MatchToken? matchSimbol() {
    String char = input[position];

    if (char == '=' || char == ';' || char == '{' || char == '}' || char == '(' || char == ')') {
      return MatchToken('simbolo', char, 1);
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
  }

  bool is_white_space(String char) {
    return char == ' ' || char == '\n' || char == '\t';
  }

  void advance() {
    if (input[position] == '\n') {
      line++;
      column = 1;
    }
    else {
      column++;
    }
    position++;
  }
}

