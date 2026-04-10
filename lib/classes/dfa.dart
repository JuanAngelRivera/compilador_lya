import 'package:compilador_lya/classes/token.dart';
import 'package:flutter/widgets.dart';

abstract class DFA {

  String input;
  int position;

  DFA(this.input, this.position);

  List<String> digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  bool is_digit(String input) {
    return digits.contains(input);
  }

  Token error(String input, int position) {
    return Token('error', input, position);
  }

  Token? recognize();
}