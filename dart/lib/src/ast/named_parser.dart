import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';
import 'package:dart/src/cucumber_expression_exception.dart';

import 'node.dart';

const namedParser = NamedParser();

class NamedParser extends Parser {
  static const parsers = <Parser>[
    namedParser,
  ];

  const NamedParser();

  /// name := whitespace | .
  @override
  Result parse(String expression, List<Token> tokens, int current) {
    Token token = tokens[current];
    switch (token.type) {
      case TokenType.whiteSpace:
      case TokenType.text:
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
      case TokenType.beginOptional:
      case TokenType.endOptional:
      case TokenType.beginParameter:
      case TokenType.endParameter:
      case TokenType.alternation:
        throw CucumberExpressionException.createInvalidParameterTypeNameByToken(
          token,
          expression,
        );
      case TokenType.startOfLine:
      case TokenType.endOfLine:
      default:
        // If configured correctly this will never happen
        return Result.invalid;
    }
  }
}
