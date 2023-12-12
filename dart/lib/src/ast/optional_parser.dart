import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';

import 'node.dart';
import 'parameter_parser.dart';
import 'text_parser.dart';

const optionalParser = OptionalParser();

class OptionalParser extends Parser
{
  static const parsers = <Parser>[
    optionalParser,
    parameterParser,
    textParser,
  ];

  const OptionalParser();

  /// optional := '(' + option* + ')'
  /// option := optional | parameter | text
  @override
  Result parse(String expression, List<Token> tokens, int current) =>
      parseBetween(
        NodeType.optionalNode,
        TokenType.beginOptional,
        TokenType.endOptional,
        parsers,
        expression,
        tokens,
        current,
      );

}