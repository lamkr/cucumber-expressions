import 'package:dart/src/core/locale.dart';
import 'package:dart/src/generated_expression.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:test/test.dart';

void main() {
  final parameterTypeRegistry = ParameterTypeRegistry(Locale.english);

  test('documents_expression_generation', () {
    final generator = CucumberExpressionGenerator(parameterTypeRegistry);
    String undefinedStepText = "I have 2 cucumbers and 1.5 tomato";
    GeneratedExpression generatedExpression = generator.generateExpressions(undefinedStepText).get(0);
    expect("I have {int} cucumbers and {double} tomato", generatedExpression.source);
    expect(double, generatedExpression.parameterTypes[1].type);
  });

  // TODO to be completed...
}
