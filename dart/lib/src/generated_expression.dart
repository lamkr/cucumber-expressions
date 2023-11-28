import 'package:collection/collection.dart';

import 'core/collections.dart';
import 'parameter_type.dart';

class GeneratedExpression {
  static const dartKeywords = [
    'Function',
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'base',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'final',
    'finally',
    'for',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'sealed',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'when',
    'while',
    'with',
    'yield',
  ];

  final String _expressionTemplate;
  final List<ParameterType> parameterTypes;

  GeneratedExpression(this._expressionTemplate, this.parameterTypes);

  static bool isDartKeyword(String keyword) =>
      dartKeywords.binarySearch(keyword) >= 0;

  String get source {
    int index = -1;
    final source = _expressionTemplate.replaceAllMapped(r'%s', (match) => parameterTypes[++index].name);
    return source;
  }

  String getParameterName(String typeName, Map<String, int> usageByTypeName) {
    final count = (usageByTypeName[typeName] ?? 0) + 1;
    usageByTypeName[typeName] = count;
    return count == 1 && !isDartKeyword(typeName)
        ? typeName
        : '$typeName$count';
  }

  List<String> getParameterNames() => parameterTypes
      .map((parameterType) => getParameterName(parameterType.name, emptyMap))
      .toList(growable: false);
}
