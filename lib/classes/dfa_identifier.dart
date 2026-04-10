import 'package:compilador_lya/classes/dfa.dart';
import 'package:compilador_lya/classes/token.dart';

class DfaIdentifier extends DFA {
  DfaIdentifier(String input) : super(input, 0);

  @override
  Token? recognize() {
    return q0(input, position);
  }

  Token? q0(String input, int position) {

    if(input.isEmpty){
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_letter(char)){
      return q1(input, position + 1);
    }
    else if (char == '_' || char == '\$'){
      q1(input, position + 1);
    }
    else{
      error(input, position);
    }
  }

  Token? q1(String input, position){

    if(input.isEmpty){
      return error(input, position);
    }

    String char = input.substring(position);

    if (is_letter(char)){
      return q1(input, position + 1);
    }
    else if (char == '_'){
      q1(input, position + 1);
    }
    else{
      error(input, position);
    }
  }
}