import 'package:dart/src/argument.dart';

import 'ast/node.dart';
import 'cucumber_expression_exception.dart';
import 'expression.dart';
import 'parameter_type.dart';
import 'parameter_type_registry.dart';

class CucumberExpression implements Expression {

  final List<ParameterType> parameterTypes = <ParameterType>[];
  final String _source;
  late final RegExp _regexp;
  final ParameterTypeRegistry parameterTypeRegistry;

  CucumberExpression(this._source, this.parameterTypeRegistry) {
    final parser = CucumberExpressionParser();
    Node ast = parser.parse(expression);
    String pattern = _rewriteToRegex(ast);
    _regexp = RegExp(pattern);
  }

  @override
  List<Argument> match(String text, List<Type> typeHints) {
    // TODO: implement match
    throw UnimplementedError();
  }

  @override
  Pattern get regexp => _regexp.pattern;

  @override
  String get source => _source;

  String _rewriteToRegex(Node node) {
    switch (node.type) {
      case NodeType.textNode:
        return _escapeRegex(node.text);
      case NodeType.optionalNode:
        return _rewriteOptional(node);
      case NodeType.alternationNode:
        return rewriteAlternation(node);
      case NodeType.alternativeNode:
        return rewriteAlternative(node);
      case NodeType.parameterNode:
        return rewriteParameter(node);
      case NodeType.expressionNode:
        return rewriteExpression(node);
      default:
        // Can't happen as long as the switch case is exhaustive
        throw ArgumentError(node.type.name);
    }
  }

  static final RegExp _escapePatternRe = RegExp(r'([\\^\[({$.|?*+})\]])');

  String _escapeRegex(String text) {
    return text.replaceAllMapped(_escapePatternRe, (match) {
      final value = text.substring(match.start, match.end);
      return '\\$value';
    });
  }

  String _rewriteOptional(Node node) {
    _assertNoParameters(node, (astNode) => CucumberExpressionException.createParameterIsNotAllowedInOptional(astNode, source));
    _assertNoOptionals(node, (astNode) => CucumberExpressionException.createOptionalIsNotAllowedInOptional(astNode, source));
    _assertNotEmpty(node, (astNode) => CucumberExpressionException.createOptionalMayNotBeEmpty(astNode, source));
    final nodesInString = node.nodes
        .map((astNode) => _rewriteToRegex(astNode));
    final text = '(?:${nodesInString.join()})?';
    return text;
  }

  void _assertNotEmpty(Node node,
  CucumberExpressionException Function(Node) createNodeWasNotEmptyException) {
    final filtered = node.nodes
        .where((astNode) => NodeType.textNode == astNode.type);
    if(filtered.isEmpty) {
      throw createNodeWasNotEmptyException(node);
    }
  }

  void _assertNoParameters(Node node, CucumberExpressionException Function (Node) createNodeContainedAParameterException) {
    _assertNoNodeOfType(NodeType.parameterNode, node, createNodeContainedAParameterException);
  }

  void _assertNoOptionals(Node node,
    CucumberExpressionException Function(Node) createNodeContainedAnOptionalException) {
    _assertNoNodeOfType(NodeType.optionalNode, node, createNodeContainedAnOptionalException);
  }

  void _assertNoNodeOfType(NodeType nodeType, Node node,
    CucumberExpressionException Function (Node) createException)
  {
    final filtered = node.nodes.where((astNode) => nodeType == astNode.type);
    if( filtered.isNotEmpty ) {
      throw createException(filtered.first);
    }
  }

}