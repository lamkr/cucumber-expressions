import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';

/// alternation := (?<=left-boundary) + alternative* + ( '/' + alternative* )+ + (?=right-boundary)
/// left-boundary := whitespace | } | ^
/// right-boundary := whitespace | { | $
/// alternative: = optional | parameter | text
class AlternationParser extends Parser
{
  final alternativeParsers = <Parser>[
      alternativeSeparator,
      optionalParser,
      parameterParser,
      textParser,
  ];

  AlternationParser(super.nodeType, super.beginToken, super.endToken, super.parsers);

  @override
  Result parse(String expression, List<Token> tokens, int current) {
    int previous = current - 1;
    if (!lookingAtAny(tokens, previous,
        [TokenType.startOfLine,
        TokenType.whiteSpace,
        TokenType.endParameter,],)) {
      return Result.invalid;
    }

    Result result = parseTokensUntil(
      expression,
      alternativeParsers,
      tokens,
      current,
      [TokenType.whiteSpace,
        TokenType.endOfLine,
        TokenType.beginParameter,
      ],
    );
    int subCurrent = current + result.consumed;
    if (result.ast.stream().noneMatch(astNode -> astNode.type() == ALTERNATIVE_NODE)) {
      return Result.invalid;
    }

    int start = tokens[current].start;
    int end = tokens[subCurrent].start;
    // Does not consume right hand boundary token
    return Result(result.consumed,
      Node(ALTERNATION_NODE, start, end, splitAlternatives(start, end, result.ast)));
    };
  }
}