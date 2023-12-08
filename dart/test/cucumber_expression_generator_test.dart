import 'package:dart/src/argument.dart';
import 'package:dart/src/core/locale.dart';
import 'package:dart/src/cucumber_expression.dart';
import 'package:dart/src/cucumber_expression_generator.dart';
import 'package:dart/src/generated_expression.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:test/test.dart';

final parameterTypeRegistry = ParameterTypeRegistry(englishLocale);
final generator = CucumberExpressionGenerator(parameterTypeRegistry);

void main()
{
  test('documents_expression_generation', () {
    final generator = CucumberExpressionGenerator(parameterTypeRegistry);
    String undefinedStepText = "I have 2 cucumbers and 1.5 tomato";
    final generatedExpressions = generator.generateExpressions(undefinedStepText);
    GeneratedExpression generatedExpression = generatedExpressions[0];
    expect("I have {int} cucumbers and {double} tomato", generatedExpression.source);
    expect(double, generatedExpression.parameterTypes[1].type);
  });

  test('generates_expression_for_no_args', () {
    assertExpression("hello", <String>[], "hello");
  });

  // TODO to be completed...
}

void assertExpression(String expectedExpression, List<String> expectedArgumentNames, String text) {
  final generatedExpressions = generator.generateExpressions(text);
  final generatedExpression = generatedExpressions[0];
  expect(expectedExpression, generatedExpression.source);
  expect(expectedArgumentNames, generatedExpression.getParameterNames());

  // Check that the generated expression matches the text
  final cucumberExpression = CucumberExpression(generatedExpression.source,
      parameterTypeRegistry);
  List<Argument> match = cucumberExpression.match(text);
  if (match.isEmpty) {
    fail("Expected text '$text' to match generated expression '${generatedExpression.source}'");
  }
  expect(expectedArgumentNames.length, match.length);
}

