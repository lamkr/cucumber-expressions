import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';

import 'node.dart';
import 'optional_parser.dart';
import 'parameter_parser.dart';
import 'text_parser.dart';

const alternativeSeparator = AlternativeSeparator();

class AlternativeSeparator extends Parser {
  static const parsers = <Parser>[
    alternativeSeparator,
    optionalParser,
    parameterParser,
    textParser,
  ];

  const AlternativeSeparator();

  /// alternation := alternative* + ( '/' + alternative* )+
  @override
  Result parse(String expression, List<Token> tokens, int current) {
    if (!lookingAt(tokens, current, TokenType.alternation)) {
      return Result.invalid;
    }
    Token token = tokens[current];
    return Result(
      1,
      [
        Node.withToken(
          NodeType.alternativeNode,
          token.start,
          token.end,
          token.text,
        ),
      ],
    );
  }
}
