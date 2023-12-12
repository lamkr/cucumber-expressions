import 'package:dart/src/ast/node.dart';
import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';

void originalCode(int count, List<Node> separators, List<List<Node>> alternatives) {
  OriginalParser().createAlternativeNodes(0, count, separators, alternatives);
}

class OriginalParser extends Parser {
  const OriginalParser();

  @override
  Result parse(String expression, List<Token> tokens, int current) {
    throw UnimplementedError();
  }
}