import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';
import 'package:dart/src/cucumber_expression_exception.dart';

import 'node.dart';

const textParser = TextParser();

class TextParser extends Parser {
  static const parsers = <Parser>[
    textParser,
  ];

  const TextParser();

  /// text := whitespace | ')' | '}' | .
  @override
  Result parse(String expression, List<Token> tokens, int current) {
    Token token = tokens[current];
    switch (token.type) {
      case TokenType.whiteSpace:
      case TokenType.text:
      case TokenType.endParameter:
      case TokenType.endOptional:
        return Result(
          1,
          [
            Node.withToken(
              NodeType.textNode,
              token.start,
              token.end,
              token.text,
            )
          ],
        );
      case TokenType.alternation:
        throw CucumberExpressionException.createAlternationNotAllowedInOptional(expression, token,);
      case TokenType.beginParameter:
      case TokenType.startOfLine:
      case TokenType.endOfLine:
      case TokenType.beginOptional:
      default:
        // If configured correctly this will never happen
        return Result.invalid;
    }
  }
}
