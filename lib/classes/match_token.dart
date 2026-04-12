class MatchToken {
  final String type;
  final String lexeme;
  final int length;

  MatchToken(this.type, this.lexeme) : length = lexeme.length;

  static MatchToken error (String lexeme) {
    return MatchToken('error', lexeme);
  }
}