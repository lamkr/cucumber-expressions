import 'dart:collection';

import 'generated_expression.dart';
import 'parameter_type.dart';

class CombinatorialGeneratedExpressionFactory {
  // 256 generated expressions ought to be enough for anybody
  static const maxExpressions = 256;

  final String _expressionTemplate;
  final List<List<ParameterType>> _parameterTypeCombinations;

  CombinatorialGeneratedExpressionFactory(
      this._expressionTemplate, this._parameterTypeCombinations);

  List<GeneratedExpression> generateExpressions() {
    final generatedExpressions = <GeneratedExpression>[];
    // ArrayDeque in Dart: https://api.dart.dev/stable/2.14.0/dart-collection/ArrayDeque-class.html
    final permutation = ListQueue<ParameterType>(
        _parameterTypeCombinations.length
    );
    _generatePermutations(generatedExpressions, permutation);
    return generatedExpressions;
  }

  void _generatePermutations(
    List<GeneratedExpression> generatedExpressions,
    Queue<ParameterType> permutation
  )
  {
    if (generatedExpressions.length >= maxExpressions) {
      return;
    }

    if (permutation.length == _parameterTypeCombinations.length) {
      final permutationCopy = List<ParameterType>.from(permutation);
      generatedExpressions.add(
          GeneratedExpression(_expressionTemplate, permutationCopy));
      return;
    }

    final parameterTypes = _parameterTypeCombinations[permutation.length];
    for (ParameterType parameterType in parameterTypes) {
      // Avoid recursion if no elements can be added.
      if (generatedExpressions.length >= maxExpressions) {
        return;
      }
      permutation.addLast(parameterType);
      _generatePermutations(generatedExpressions, permutation);
      permutation.removeLast();
    }
  }

}