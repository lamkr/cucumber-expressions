import 'combinatorial_generated_expression_factory.dart';
import 'generated_expression.dart';
import 'parameter_type.dart';
import 'parameter_type_matcher.dart';
import 'parameter_type_registry.dart';

class CucumberExpressionGenerator {
  final ParameterTypeRegistry parameterTypeRegistry;

  CucumberExpressionGenerator(this.parameterTypeRegistry);

  List<GeneratedExpression> generateExpressions(String text) {
    final parameterTypeCombinations = <List<ParameterType>>[];
    final parameterTypeMatchers = _createParameterTypeMatchers(text);
    final expressionTemplate = StringBuffer();
    int pos = 0;
    while (true) {
      final matchingParameterTypeMatchers = <ParameterTypeMatcher>[];
      for (ParameterTypeMatcher parameterTypeMatcher in parameterTypeMatchers) {
        if (parameterTypeMatcher.advanceToAndFind(pos)) {
          matchingParameterTypeMatchers.add(parameterTypeMatcher);
        }
      }

      if (matchingParameterTypeMatchers.isNotEmpty) {
        matchingParameterTypeMatchers.sort();

        // Find all the best parameter type matchers, they are all candidates.
        ParameterTypeMatcher bestParameterTypeMatcher =
            matchingParameterTypeMatchers[0];
        final bestParameterTypeMatchers = <ParameterTypeMatcher>[];
        for (ParameterTypeMatcher m in matchingParameterTypeMatchers) {
          if (m.compareTo(bestParameterTypeMatcher) == 0) {
            bestParameterTypeMatchers.add(m);
          }
        }

        // Build a list of parameter types without duplicates. The reason there
        // might be duplicates is that some parameter types have more than one regexp,
        // which means multiple ParameterTypeMatcher objects will have a reference to the
        // same ParameterType.
        // We're sorting the list so preferential parameter types are listed first.
        // Users are most likely to want these, so they should be listed at the top.
        Set<ParameterType> matchers = <ParameterType>{};
        for (ParameterTypeMatcher parameterTypeMatcher
            in bestParameterTypeMatchers) {
          final parameterType = parameterTypeMatcher.parameterType;
          matchers.add(parameterType);
        }
        final parameterTypes = matchers.toList(growable: false);

        parameterTypeCombinations.add(<ParameterType>[...parameterTypes]);

        expressionTemplate
          ..write(_escape(text.substring(pos, bestParameterTypeMatcher.start)))
          ..write("{%s}");
        pos = bestParameterTypeMatcher.start +
            bestParameterTypeMatcher.value.length;
      } else {
        break;
      }

      if (pos >= text.length) {
        break;
      }
    }
    expressionTemplate.write(_escape(text.substring(pos)));
    return CombinatorialGeneratedExpressionFactory(
            expressionTemplate.toString(), parameterTypeCombinations)
        .generateExpressions();
  }

  String _escape(String string) => string
      .replaceAll('(', r'\(')
      .replaceAll('{', r'\{{')
      .replaceAll('}', '}}')
      .replaceAll('/', r'\/');

  List<ParameterTypeMatcher> _createParameterTypeMatchers(String text) {
    Iterable<ParameterType> parameterTypes =
        parameterTypeRegistry.parameterTypes;
    final parameterTypeMatchers = <ParameterTypeMatcher>[];
    for (ParameterType parameterType in parameterTypes) {
      if (parameterType.useForSnippets) {
        parameterTypeMatchers
            .addAll(_createParameterTypeMatchersStatic(parameterType, text));
      }
    }
    return parameterTypeMatchers;
  }

  static List<ParameterTypeMatcher> _createParameterTypeMatchersStatic(
      ParameterType parameterType, String text) {
    final result = <ParameterTypeMatcher>[];
    List<String> captureGroupRegexps = parameterType.regexps;
    for (String captureGroupRegexp in captureGroupRegexps) {
      RegExp regexp = RegExp('($captureGroupRegexp)');
      result.add(ParameterTypeMatcher(parameterType, regexp, text));
    }
    return result;
  }
}
