class SyntaxError {
  final int line;
  final int column;
  final String message;

  SyntaxError(this.line, this.column, this.message);
}