class Token{
  final String type;
  final String lexeme;
  final int position;
  final int line;
  final int column;
  final int length;
  
  Token(this.type, this.lexeme, this.position, this.line, this.column) : length = lexeme.length;
}