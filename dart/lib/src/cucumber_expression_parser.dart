import 'package:dart/src/ast/alternation_parser.dart';
import 'package:dart/src/ast/token_type.dart';
import 'package:dart/src/cucumber_expression_exception.dart';

import 'cucumber_expression_tokenizer.dart';
import 'ast/node.dart';
import 'ast/parser.dart';
import 'ast/result.dart';
import 'ast/token.dart';

class CucumberExpressionParser {

  /// cucumber-expression :=  ( alternation | optional | parameter | text )*
  static final Parser cucumberExpressionParser = InternalParser
  (
    NodeType.expressionNode,
    TokenType.startOfLine,
    TokenType.endOfLine,
    <Parser>[
      AlternationParser(),
      optionalParser,
      parameterParser,
      textParser,
    ],
  );

  static Parser parseBetween(
      NodeType nodeType,
      TokenType beginToken,
      TokenType endToken,
      List<Parser> parsers) => ParserBetween(nodeType, beginToken, endToken, parsers);

  Node parse(String expression) {
    final tokenizer = CucumberExpressionTokenizer();
    List<Token> tokens = tokenizer.tokenize(expression);
    Result result = cucumberExpressionParser.parse(expression, tokens, 0);
    return result.ast[0];
  }
}

final class InternalParser extends Parser {
  InternalParser(super.nodeType, super.beginToken, super.endToken, super.parsers);

  @override
  Result parse(String expression, List<Token> tokens, int current) {
    if (!lookingAt(tokens, current, beginToken)) {
      return Result.invalid;
    }
    int subCurrent = current + 1;
    Result result = parseTokensUntil(expression, parsers, tokens, subCurrent, [endToken, TokenType.endOfLine]);
    subCurrent += result.consumed;

    // endToken not found
    if (!lookingAt(tokens, subCurrent, endToken)) {
      throw CucumberExpressionException.createMissingEndToken(expression, beginToken, endToken, tokens[current]);
    }
    // consumes endToken
    int start = tokens[current].start;
    int end = tokens[subCurrent].end;
    return Result(subCurrent + 1 - current, [Node.withNodes(nodeType, start, end, result.ast)]);
  }

}
