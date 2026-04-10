import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/token.dart';

class DfaNumber extends DFA {
  DfaNumber(String input) : super(input, 0);

  @override
  Token? recognize() {
    return q0(input, position);
  }

  Token? q0(String input, int position) {
    if (input.isEmpty) {
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q1(input, position++);
    }
    else if (char == '+' || char == '-') {
      q2(input, position++);
    }
    else {
      error(input, position);
    }
  }

  Token? q1(String input, int position) {
    if (position == input.length) {
      return Token('entero', input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q1(input, position++);
    }
    else if (char == 'e' || char == 'E') {
      q5(input, position++);
    }
    else if (char == '.') {
      q3(input, position++);
    }
    else {
      error(input, position);
    }
  }
  
  Token? q2(String input, int position) {
    if (position == input.length) {
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q1(input, position++);
    }
    else if (char == '.') {
      q3(input, position++);
    }
    else {
      return error(input, position);
    }
  }

  Token? q3(String input, int position) {
    if (position == input.length) {
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q4(input, position++);
    }
    else {
      return error(input, position);
    }
  }

  Token? q4(String input, int position) {
    if (position == input.length) {
      return Token('real', input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q4(input, position++);
    }
    else if (char == 'e' || char == 'E'){
      q5(input, position++);
    }
    else {
      return error(input, position);
    }
  }

  Token? q5(String input, int position) {
    if (position == input.length) {
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_digit(char)) {
      q7(input, position++);
    }
    else if (char == '+' || char == '-') {
      q6(input, position++);
    }
    else {
      error(input, position);
    }
  }

  Token? q6(String input, int position) {
    if (position == input.length) {
      return error(input, position);
    }

    String char = input.substring(position);
    
    if (is_digit(char)) {
      q7(input, position++);
    }
  }
}
