import 'package:dart/cucumber_expressions.dart';
import 'package:dart/src/argument.dart';
import 'package:dart/src/core/collections.dart';
import 'package:dart/src/undefined_parameter_type_exception.dart';

import 'cucumber_expression_parser.dart';
import 'ast/node.dart';
import 'cucumber_expression_exception.dart';
import 'expression.dart';
import 'parameter_by_type_transformer.dart';
import 'parameter_type.dart';
import 'parameter_type_registry.dart';

class CucumberExpression implements Expression {

  final List<ParameterType> parameterTypes = <ParameterType>[];
  final String _source;
  late final TreeRegexp _treeRegexp;
  final ParameterTypeRegistry parameterTypeRegistry;

  CucumberExpression(this._source, this.parameterTypeRegistry) {
    final parser = CucumberExpressionParser();
    Node ast = parser.parse(_source);
    String pattern = _rewriteToRegex(ast);
    _treeRegexp = TreeRegexp(RegExp(pattern));
  }

  @override
  List<Argument> match(String text, [List<Type> typeHints=const <Type>[]]) {
    final group = _treeRegexp.match(text);
    if(group.isInvalid) {
      return <Argument>[];
    }

    final parameterTypes = List<ParameterType>.from(this.parameterTypes);
    for (int i = 0; i < parameterTypes.length; i++) {
      final parameterType = parameterTypes[i];
      Type type = i < typeHints.length ? typeHints[i] : String;
      if (parameterType.isAnonymous) {
        ParameterByTypeTransformer defaultTransformer = parameterTypeRegistry.defaultParameterTransformer;
        parameterTypes[i] = parameterType.deAnonymize(type,
                (arg) => defaultTransformer.transform(arg, type));
      }
    }

    return Argument.build(group, parameterTypes);
  }

  @override
  RegExp get regexp => _treeRegexp.regexp;

  @override
  String get source => _source;

  String _rewriteToRegex(Node node) {
    switch (node.type) {
      case NodeType.textNode:
        return _escapeRegex(node.text);
      case NodeType.optionalNode:
        return _rewriteOptional(node);
      case NodeType.alternationNode:
        return _rewriteAlternation(node);
      case NodeType.alternativeNode:
        return _rewriteAlternative(node);
      case NodeType.parameterNode:
        return _rewriteParameter(node);
      case NodeType.expressionNode:
        return _rewriteExpression(node);
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
    final text = nodesInString.joining(prefix: '(?:', suffix: ')?');
    return text;
  }

  String _rewriteAlternation(Node node) {
    // Make sure the alternative parts aren't empty and don't contain parameter types
    for (Node alternative in node.nodes) {
      if (alternative.nodes.isEmpty) {
        throw CucumberExpressionException.createAlternativeMayNotBeEmpty(alternative, source);
      }
      _assertNotEmpty(alternative, (astNode) =>
        CucumberExpressionException.createAlternativeMayNotExclusivelyContainOptionals(astNode, source));
    }
    final nodesInString = node.nodes
        .map((astNode) => _rewriteToRegex(astNode));
    final text = nodesInString.joining(delimiter: '|', prefix: '(?:', suffix: ')');
    return text;
  }

  String _rewriteAlternative(Node node) {
    final nodesInString = node.nodes
        .map((astNode) => _rewriteToRegex(astNode));
    final text = nodesInString.join();
    return text;
  }

  String _rewriteParameter(Node node) {
    String name = node.text;
    ParameterType parameterType = parameterTypeRegistry.lookupByTypeName(name);
    if (parameterType.isInvalid) {
      throw UndefinedParameterTypeException.createUndefinedParameterType(node, source, name);
    }
    parameterTypes.add(parameterType);
    List<String> regexps = parameterType.regexps;
    if (regexps.length == 1) {
      return "(${regexps[0]})";
    }

    final text = regexps.joining(delimiter: ')|(?:', prefix: '((?:', suffix: '))');
    return text;
  }

  String _rewriteExpression(Node node) {
    final nodesInString = node.nodes
        .map((astNode) => _rewriteToRegex(astNode));
    final text = nodesInString.joining(prefix: '*', suffix: r'$');
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