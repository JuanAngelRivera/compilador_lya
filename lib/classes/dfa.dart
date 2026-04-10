import 'package:compilador_lya/classes/token.dart';

abstract class DFA {

  String input;
  int position;

  DFA(this.input, this.position);

  static List<String> digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  static const List<String> letters = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
                          'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ',
                          'Z', 'X', 'C', 'V', 'B', 'N', 'M',
                          'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
                          'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ',
                          'z', 'x', 'c', 'v', 'b', 'n', 'm'];

  static const List<String> special = ['_', '\$'];

  bool is_digit(String input) {
    return digits.contains(input);
  }

  bool is_letter(String input){
    return letters.contains(input);
  }

  bool is_special(String input){
    return special.contains(input);
  }

  Token error(String input, int position) {
    return Token('error', input, position);
  }

  Token? recognize();
}