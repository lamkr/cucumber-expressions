class CucumberExpressionException implements Exception {
  final String message;
  final Exception? cause;

  CucumberExpressionException(this.message, [this.cause]);

  static CucumberExpressionException createInvalidParameterTypeName(
          String name) =>
      CucumberExpressionException(
          "Illegal character in parameter name {$name}. Parameter names may not contain '{', '}', '(', ')', '\\' or '/'");
}
