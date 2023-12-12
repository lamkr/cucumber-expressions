import 'package:dart/src/ast/alternation_parser.dart';
import 'package:dart/src/ast/token_type.dart';

import 'ast/optional_parser.dart';
import 'ast/parameter_parser.dart';
import 'ast/text_parser.dart';
import 'cucumber_expression_tokenizer.dart';
import 'ast/node.dart';
import 'ast/parser.dart';
import 'ast/result.dart';
import 'ast/token.dart';

/// cucumber-expression :=  ( alternation | optional | parameter | text )*
class CucumberExpressionParser {
  static const cucumberExpressionParser = _InternalCucumberExpressionParser();

  Node parse(String expression) {
    final tokenizer = CucumberExpressionTokenizer();
    List<Token> tokens = tokenizer.tokenize(expression);
    Result result = cucumberExpressionParser.parse(expression, tokens, 0);
    return result.ast[0];
  }
}

final class _InternalCucumberExpressionParser extends Parser {

  static const parsers = <Parser>[
    alternationParser,
    optionalParser,
    parameterParser,
    textParser,
  ];

  const _InternalCucumberExpressionParser();

  @override
  Result parse(String expression, List<Token> tokens, int current) =>
      parseBetween(
        NodeType.expressionNode,
        TokenType.startOfLine,
        TokenType.endOfLine,
        parsers,
        expression,
        tokens,
        current,
      );
}
