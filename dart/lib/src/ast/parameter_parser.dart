import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';
import 'package:dart/src/ast/token_type.dart';

import 'named_parser.dart';
import 'node.dart';

const parameterParser = ParameterParser();

class ParameterParser extends Parser
{
  static const parsers = <Parser>[
    namedParser,
  ];

  const ParameterParser();

  /// parameter := '{' + name* + '}'
  @override
  Result parse(String expression, List<Token> tokens, int current) =>
      parseBetween(
        NodeType.parameterNode,
        TokenType.beginParameter,
        TokenType.endParameter,
        parsers,
        expression,
        tokens,
        current,
      );

}