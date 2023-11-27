import 'package:dart/src/core/locale.dart';
import 'package:dart/src/cucumber_expression_generator.dart';
import 'package:dart/src/generated_expression.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:test/test.dart';

void main() {
  final parameterTypeRegistry = ParameterTypeRegistry(englishLocale);

  test('documents_expression_generation', () {
    final generator = CucumberExpressionGenerator(parameterTypeRegistry);
    String undefinedStepText = "I have 2 cucumbers and 1.5 tomato";
    final generatedExpressions = generator.generateExpressions(undefinedStepText);
    GeneratedExpression generatedExpression = generatedExpressions[0];
    expect("I have {int} cucumbers and {double} tomato", generatedExpression.source);
    expect(double, generatedExpression.parameterTypes[1].type);
  });

  // TODO to be completed...
}
