import 'package:dart/src/cucumber_expression_exception.dart';
import 'package:meta/meta.dart';

import 'node.dart';
import 'result.dart';
import 'token.dart';
import 'token_type.dart';

abstract class Parser
{
  const Parser();

  @protected
  Result parseBetween(
      NodeType nodeType,
      TokenType beginToken,
      TokenType endToken,
      List<Parser> parsers,
      String expression,
      List<Token> tokens,
      int current,
      ) {
    if (!lookingAt(tokens, current, beginToken)) {
      return Result.invalid;
    }
    int subCurrent = current + 1;
    Result result = parseTokensUntil(
      expression,
      parsers,
      tokens,
      subCurrent,
      [endToken, TokenType.endOfLine],
    );
    subCurrent += result.consumed;

    // endToken not found
    if (!lookingAt(tokens, subCurrent, endToken)) {
      throw CucumberExpressionException.createMissingEndToken(
        expression,
        beginToken,
        endToken,
        tokens[current],
      );
    }
    // consumes endToken
    int start = tokens[current].start;
    int end = tokens[subCurrent].end;
    return Result(
      subCurrent + 1 - current,
      [
        Node.withNodes(nodeType, start, end, result.ast),
      ],
    );
  }

  bool lookingAt(List<Token> tokens, int at, TokenType token) {
    if (at < 0) {
      // If configured correctly this will never happen
      // Keep for completeness
      return token == TokenType.startOfLine;
    }
    if (at >= tokens.length) {
      return token == TokenType.endOfLine;
    }
    return tokens[at].type == token;
  }
  
  bool lookingAtAny(List<Token> tokens, int at, List<TokenType> tokenTypes) {
    for (TokenType tokeType in tokenTypes) {
      if (lookingAt(tokens, at, tokeType)) {
        return true;
      }
    }
    return false;
  }

  Result parseTokensUntil(
      String expression,
      List<Parser> parsers,
      List<Token> tokens,
      int startAt,
      List<TokenType> endTokens,)
  {
    int current = startAt;
    int size = tokens.length;
    final ast = <Node>[];
    while (current < size) {
      if (lookingAtAny(tokens, current, endTokens)) {
        break;
      }

      Result result = _parseToken(expression, parsers, tokens, current);
      if (result.consumed == 0) {
        // If configured correctly this will never happen
        // Keep to avoid infinite loops
        throw StateError('No eligible parsers for $tokens');
      }
      current += result.consumed;
      ast.addAll(result.ast);
    }
    return Result(current - startAt, ast);
  }

  Result _parseToken(String expression, List<Parser> parsers,
      List<Token> tokens,
      int startAt,) {
    for (Parser parser in parsers) {
      Result result = parser.parse(expression, tokens, startAt);
      if (result.consumed != 0) {
        return result;
      }
    }
    // If configured correctly this will never happen
    throw StateError('No eligible parsers for $tokens');
  }

  Result parse(String expression, List<Token> tokens, int current);

  List<Node> splitAlternatives(int start, int end, List<Node> alternation) {
    final separators = <Node>[];
    final List<List<Node>> alternatives = [];
    var alternative = <Node>[];
    for (Node n in alternation) {
      if (n.type == NodeType.alternativeNode) {
        separators.add(n);
        alternatives.add(alternative);
        alternative = <Node>[];
      } else {
        alternative.add(n);
      }
    }
    alternatives.add(alternative);

    return createAlternativeNodes(start, end, separators, alternatives);
  }

  List<Node> createAlternativeNodes(int start, int end, List<Node> separators, List<List<Node>> alternatives)
    => _createAlternativeNodesRefined(start, end, separators, alternatives);

  List<Node> _createAlternativeNodesOriginal(int start, int end, List<Node> separators, List<List<Node>> alternatives) {
    final nodes = <Node>[];
    for (int i = 0; i < alternatives.length; i++) {
      final List<Node> subNodes = alternatives[i];
      if (i == 0) {
        final rightSeparator = separators[i];
        nodes.add( Node.withNodes(NodeType.alternativeNode, start, rightSeparator.start, subNodes) );
      } else if (i == alternatives.length - 1) {
        final leftSeparator = separators[i - 1];
        nodes.add( Node.withNodes(NodeType.alternativeNode, leftSeparator.end, end, subNodes));
      } else {
        final leftSeparator = separators[i - 1];
        final rightSeparator = separators[i];
        nodes.add( Node.withNodes(NodeType.alternativeNode, leftSeparator.end, rightSeparator.start, subNodes));
      }
    }
    return nodes;
  }

  List<Node> _createAlternativeNodesRefined(int start, int end, List<Node> separators, List<List<Node>> alternatives) =>
      List.generate(alternatives.length, (i) {
        if (i == 0) {
          final rightSeparator = separators[i];
          return Node.withNodes(NodeType.alternativeNode, start, rightSeparator.start, alternatives[i]);
        } else if (i == alternatives.length - 1) {
          final leftSeparator = separators[i - 1];
          return Node.withNodes(NodeType.alternativeNode, leftSeparator.end, end, alternatives[i]);
        } else {
          final leftSeparator = separators[i - 1];
          final rightSeparator = separators[i];
          return Node.withNodes(
            NodeType.alternativeNode,
            leftSeparator.end,
            rightSeparator.start,
            alternatives[i],
          );
        }
      });
}
