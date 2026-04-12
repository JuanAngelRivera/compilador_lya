import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/match_token.dart';

class DfaIdentifier extends DFA {
  DfaIdentifier(String input, int position) : super(input, position);

  @override
  MatchToken? recognize() {
    return q0(input, position, position);
  }

  MatchToken? q0(String input, int position, int start) {

    if(position >= input.length) {
      return null;
    }

    String char = input[position];

    if (is_letter(char) || char == '_' || char == '\$') {
      return q1(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  MatchToken? q1(String input, position, int start) {
    if (position >= input.length) {
      return MatchToken('identificador', input.substring(start, position));
    }

    String char = input[position];

    if (is_letter(char) || is_digit(char) || char == '_'){
      return q1(input, position + 1, start);
    }
    else{
      return MatchToken('identificador', input.substring(start, position));
    }
  }
}