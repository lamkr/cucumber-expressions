import 'package:dart/src/ast/token_type.dart';

import 'ast/node.dart';
import 'ast/located.dart';
import 'ast/token.dart';

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
          _pointAt(node),
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
          _pointAt(node),
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
          _pointAt(node),
          'An optional may not contain a parameter type',
          "If you did not mean to use an parameter type "
              "you can use '\\{' to escape the the '{'",
        ),
      );

  static CucumberExpressionException createAlternativeMayNotBeEmpty(
          Node node, String expression) =>
      CucumberExpressionException(
        message(
          node.start,
          expression,
          _pointAt(node),
          'Alternative may not be empty',
          "If you did not mean to use an alternative you can use '\\/' to escape the the '/'",
        ),
      );

  static CucumberExpressionException
      createAlternativeMayNotExclusivelyContainOptionals(
              Node node, String expression) =>
          CucumberExpressionException(
            message(
              node.start,
              expression,
              _pointAt(node),
              'An alternative may not exclusively contain optionals',
              "If you did not mean to use an optional you can use '\\(' to escape the the '('",
            ),
          );

  static CucumberExpressionException createMissingEndToken(String expression,
          TokenType beginToken, TokenType endToken, Token current) =>
      CucumberExpressionException(
        message(
          current.start,
          expression,
          _pointAt(current),
          "The '${beginToken.symbol}' does not have a matching '${endToken.symbol}'",
          "If you did not intend to use ${beginToken.purpose} "
              "you can use '\\${beginToken.symbol}' to escape the ${beginToken.purpose}",
        ),
      );

  static CucumberExpressionException createCantEscape(String expression, int index) =>
      CucumberExpressionException(
        message(
          index,
          expression,
          _pointAtIndex(index),
          "Only the characters '{', '}', '(', ')', '\\', '/' and whitespace can be escaped",
          r"If you did mean to use an '\' you can use '\\' to escape it",
        ),
      );

  static CucumberExpressionException createTheEndOfLineCanNotBeEscaped(String expression) {
    final index = expression.codeUnits.length - 1;
    return CucumberExpressionException(
        message(
          index,
          expression,
          _pointAtIndex(index),
        'The end of line can not be escaped',
        r"You can use '\\' to escape the the '\'"
    ));
  }

  static String message(int index, String expression, String pointer,
          String problem, String solution) =>
      '${_thisCucumberExpressionHasAProblemAt(index)}\n$expression\n$pointer\n$problem.\n$solution';

  static String _thisCucumberExpressionHasAProblemAt(int index) =>
      'This Cucumber Expression has a problem at column ${index + 1}:\n';

  static String _pointAt(Located node) {
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
    if (cause != null) {
      return '$_message\nCaused by: $cause';
    }
    return _message;
  }

}
