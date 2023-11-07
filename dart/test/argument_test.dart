import 'package:dart/cucumber_expressions.dart';
import 'package:test/test.dart';

void main() {
  test('exposes_parameter_type', () {
    final treeRegexp = TreeRegexp.fromString(r'three (.*) mice');
    final parameterTypeRegistry = ParameterTypeRegistry(Locale.ENGLISH);
    List<Argument<dynamic>> arguments = Argument.build(
      treeRegexp.match("three blind mice"),
      singletonList(parameterTypeRegistry.lookupByTypeName('string'),),);
    Argument<dynamic> argument = arguments[0];
    expect('string', argument.parameterType.name);
  });
}
