import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/token.dart';

class DfaIdentifier extends DFA {
  DfaIdentifier(String input) : super(input, 0);

  @override
  Token? recognize() {
    return q0(input, position, 0);
  }

  Token? q0(String input, int position, int start) {

    if(position >= input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];

    if (is_letter(char) || char == '_') {
      return q1(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  Token? q1(String input, int position, int start) {
    if (position >= input.length) {
      return Token('identificador', input.substring(start, position), start);
    }

    String char = input[position];

    if (is_letter(char) || is_digit(char) || char == '_' || char == '\$'){
      return q1(input, position + 1, start);
    }
    else{
      return Token('identificador', input.substring(start, position), start);
    }
  }
}