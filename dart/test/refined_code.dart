
import 'package:dart/src/ast/node.dart';
import 'package:dart/src/ast/parser.dart';
import 'package:dart/src/ast/result.dart';
import 'package:dart/src/ast/token.dart';

void refinedCode(int count, List<Node> separators, List<List<Node>> alternatives) {
  RefinedParser().createAlternativeNodes(0, count, separators, alternatives);
}

class RefinedParser extends Parser {
  const RefinedParser();

  @override
  Result parse(String expression, List<Token> tokens, int current) {
    throw UnimplementedError();
  }

  @override
  List<Node> createAlternativeNodes(int start, int end, List<Node> separators, List<List<Node>> alternatives) =>
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