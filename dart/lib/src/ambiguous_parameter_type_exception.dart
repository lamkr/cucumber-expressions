import 'cucumber_expression_exception.dart';
import 'generated_expression.dart';
import 'parameter_type.dart';

class AmbiguousParameterTypeException extends CucumberExpressionException {
  final RegExp regexp;
  final String parameterTypeRegexp;
  final Set<ParameterType> parameterTypes;
  final List<GeneratedExpression> generatedExpressions;

  AmbiguousParameterTypeException(
    this.parameterTypeRegexp,
    this.regexp,
    this.parameterTypes,
    this.generatedExpressions) :
  super(
    "Your Regular Expression /${regexp.pattern.toString()}/\n"
    "matches multiple parameter types with regexp /$parameterTypeRegexp/:\n"
    "   ${_parameterTypeNames(parameterTypes)}\n"
    "\n"
    "I couldn't decide which one to use. You have two options:\n"
    "\n"
    "1) Use a Cucumber Expression instead of a Regular Expression. Try one of these:\n"
    "   ${_expressions(generatedExpressions)}\n"
    "\n" +
    "2) Make one of the parameter types preferential and continue to use a Regular Expression.\n"
    "\n"
  );

  static String _parameterTypeNames(Set<ParameterType> parameterTypes) {
    return _join(parameterTypes.map<String>((parameterType) => '{${parameterType.name}}').toList(growable: false),);
  }

  static String _expressions(List<GeneratedExpression> generatedExpressions) {
    return _join(generatedExpressions.map<String>((genExpression) => genExpression.source).toList(growable: false),);
  }

  static String _join(List<String> strings) => strings.join('\n   ');
}
