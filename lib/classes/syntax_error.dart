class SyntaxError {
  final int line;
  final int column;
  final int position;
  final int length;
  final String message;

  SyntaxError(this.line, this.column, this.position, this.length, this.message);
}