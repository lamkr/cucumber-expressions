import 'package:dart/src/ast/alternative_parser.dart';
import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';

import 'node.dart';

const alternationParser = AlternationParser();

class AlternationParser extends Parser {
  const AlternationParser();

  /// alternation := (?<=left-boundary) + alternative* + ( '/' + alternative* )+ + (?=right-boundary)
  /// left-boundary := whitespace | } | ^
  /// right-boundary := whitespace | { | $
  /// alternative: = optional | parameter | text
  @override
  Result parse(String expression, List<Token> tokens, int current) {
    int previous = current - 1;
    var tokenTypes = [
      TokenType.startOfLine,
      TokenType.whiteSpace,
      TokenType.endParameter,
    ];
    if (!lookingAtAny(tokens, previous, tokenTypes)) {
      return Result.invalid;
    }

    tokenTypes = [
      TokenType.whiteSpace,
      TokenType.endOfLine,
      TokenType.beginParameter,
    ];
    Result result = parseTokensUntil(
      expression,
      AlternativeSeparator.parsers,
      tokens,
      current,
      tokenTypes,
    );
    var subCurrent = current + result.consumed;
    if (!result.ast
        .any((astNode) => astNode.type == NodeType.alternativeNode)) {
      return Result.invalid;
    }

    int start = tokens[current].start;
    int end = tokens[subCurrent].start;
    // Does not consume right hand boundary token
    return Result(
      result.consumed,
      [
        Node.withNodes(
          NodeType.alternationNode,
          start,
          end,
          splitAlternatives(start, end, result.ast),
        ),
      ],
    );
  }
}
