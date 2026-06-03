import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/match_token.dart';

class DfaNumber extends DFA {
  DfaNumber(String input, int position) : super(input, position);

  @override
  MatchToken? recognize() {
    return q0(input, position, position);
  }

  MatchToken? q0(String input, int position, int start) {
    if (position >= input.length) {
      return null;
    }

    String char = input[position];

    if (is_digit(char)) {
      return q1(input, position + 1, start);
    }
    else if (char == '.') {
      return q3(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  

  MatchToken? q1(String input, int position, int start) {
    if (position == input.length) {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('entero', input.substring(start, position));
    }

    String char = input[position];

    if (is_digit(char)) {
      return q1(input, position + 1, start);
    }
    else if (char == 'e' || char == 'E') {
      return q5(input, position + 1, start);
    }
    else if (char == '.') {
      return q3(input, position + 1, start);
    }
    else {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('entero', input.substring(start, position));
    }
  }
  
  MatchToken? q2(String input, int position, int start) {
    if (position == input.length) {
      return null;
    }

    String char = input[position];

    if (is_digit(char)) {
      return q1(input, position + 1, start);
    }
    else if (char == '.') {
      return q3(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  MatchToken? q3(String input, int position, int start) {
    if (position == input.length) {
      return null;
    }

    String char = input[position];

    if (is_digit(char)) {
      return q4(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  MatchToken? q4(String input, int position, int start) {
    if (position == input.length) {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('real', input.substring(start, position));
    }

    String char = input[position];

    if (is_digit(char)) {
      return q4(input, position + 1, start);
    }
    else if (char == 'e' || char == 'E'){
      return q5(input, position + 1, start);
    }
    else {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('real', input.substring(start, position));
    }
  }

  MatchToken? q5(String input, int position, int start) {
    if (position == input.length) {
      return null;
    }

    String char = input[position];

    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else if (char == '+' || char == '-') {
      return q6(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  MatchToken? q6(String input, int position, int start) {
    if (position == input.length) {
      return null;
    }

    String char = input[position];
    
    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else {
      return null;
    }
  }

  MatchToken? q7(String input, int position, int start) {
    if (position == input.length) {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('cientifico', input.substring(start, position));
    }

    String char = input[position];
    
    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else {
      return MatchToken('numero', input.substring(start, position));
      return MatchToken('cientifico', input.substring(start, position));
    }
  }
}
