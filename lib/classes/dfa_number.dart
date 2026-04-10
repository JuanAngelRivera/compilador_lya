import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/token.dart';

class DfaNumber extends DFA {
  DfaNumber(String input) : super(input, 0);

  @override
  Token? recognize() {
    return q0(input, position, 0);
  }

  Token? q0(String input, int position, int start) {
    if (position >= input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];

    if (is_digit(char)) {
      return q1(input, position + 1, start);
    }
    else if (char == '+' || char == '-') {
      return q2(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  

  Token? q1(String input, int position, int start) {
    if (position == input.length) {
      return Token('entero', input.substring(start, position), start);
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
      return Token('entero', input.substring(start, position), start);
    }
  }
  
  Token? q2(String input, int position, int start) {
    if (position == input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];

    if (is_digit(char)) {
      return q1(input, position + 1, start);
    }
    else if (char == '.') {
      return q3(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  Token? q3(String input, int position, int start) {
    if (position == input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];

    if (is_digit(char)) {
      return q4(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  Token? q4(String input, int position, int start) {
    if (position == input.length) {
      return Token('real', input.substring(start, position), start);
    }

    String char = input[position];

    if (is_digit(char)) {
      return q4(input, position + 1, start);
    }
    else if (char == 'e' || char == 'E'){
      return q5(input, position + 1, start);
    }
    else {
      return Token('real', input.substring(start, position), position);
    }
  }

  Token? q5(String input, int position, int start) {
    if (position == input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];

    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else if (char == '+' || char == '-') {
      return q6(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  Token? q6(String input, int position, int start) {
    if (position == input.length) {
      return error(input.substring(start, position), start);
    }

    String char = input[position];
    
    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else {
      return error(input.substring(start, position), start);
    }
  }

  Token? q7(String input, int position, int start) {
    if (position == input.length) {
      return Token('cientifico', input.substring(start, position), start);
    }

    String char = input[position];
    
    if (is_digit(char)) {
      return q7(input, position + 1, start);
    }
    else {
      return Token('cientifico', input.substring(start, position), start);
    }
  }
}
