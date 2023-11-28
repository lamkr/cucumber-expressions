import 'package:dart/src/ast/node.dart';

import 'ast/located.dart';

class CucumberExpressionException implements Exception {
  final String _message;
  final Exception? cause;

  CucumberExpressionException(this._message, [this.cause]);

  static CucumberExpressionException createInvalidParameterTypeName(
          String name) =>
      CucumberExpressionException(
          "Illegal character in parameter name {$name}. "
          "Parameter names may not contain '{', '}', '(', ')', '\\' or '/'");

  static CucumberExpressionException createOptionalIsNotAllowedInOptional(
          Node node, String expression) =>
      CucumberExpressionException(
        message(
          node.start,
          expression,
          pointAt(node),
          'An optional may not contain an other optional',
          "If you did not mean to use an optional type you "
              "can use '\\(' to escape the the '('. "
              "For more complicated expressions consider "
              "using a regular expression instead.",
        ),
      );

  static CucumberExpressionException createOptionalMayNotBeEmpty(
          Node node, String expression) =>
      CucumberExpressionException(
        message(
          node.start,
          expression,
          pointAt(node),
          'An optional must contain some text',
          "If you did not mean to use an optional "
              "you can use '\\(' to escape the the '('",
        ),
      );

  static CucumberExpressionException createParameterIsNotAllowedInOptional(
          Node node, String expression) =>
      CucumberExpressionException(
        message(
          node.start,
          expression,
          pointAt(node),
          'An optional may not contain a parameter type',
          "If you did not mean to use an parameter type "
              "you can use '\\{' to escape the the '{'",
        ),
      );

  static String message(int index, String expression, String pointer,
          String problem, String solution) =>
      '${_thisCucumberExpressionHasAProblemAt(index)}\n$expression\n$pointer\n$problem.\n$solution';

  static String _thisCucumberExpressionHasAProblemAt(int index) =>
      'This Cucumber Expression has a problem at column ${index + 1}:\n';

  static String pointAt(Located node) {
    StringBuffer pointer = StringBuffer(_pointAtIndex(node.start));
    if (node.start + 1 < node.end) {
      for (int i = node.start + 1; i < node.end - 1; i++) {
        pointer.write('-');
      }
      pointer.write('^');
    }
    return pointer.toString();
  }

  static String _pointAtIndex(int index) {
    final pointer = StringBuffer();
    for (int i = 0; i < index; i++) {
      pointer.write(' ');
    }
    pointer.write('^');
    return pointer.toString();
  }

  @override
  String toString() {
    if( cause != null ) {
      return '$_message\nCaused by: $cause';
    }
    return _message;
  }
}
