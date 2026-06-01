class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  Token peek() {
    return tokens[current];
  }
  
}