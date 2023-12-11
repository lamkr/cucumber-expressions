import 'node.dart';
import 'result.dart';
import 'token.dart';
import 'token_type.dart';

abstract class Parser {
  final NodeType nodeType;
  final TokenType beginToken;
  final TokenType endToken;
  final List<Parser> parsers;

  Parser(this.nodeType, this.beginToken, this.endToken, this.parsers);

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

      Result result = parseToken(expression, parsers, tokens, current);
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

  Result parseToken(String expression, List<Parser> parsers,
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
}

typedef ParseFunction = Result Function(String expression, List<Token> tokens, int current);
