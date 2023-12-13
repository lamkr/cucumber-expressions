import 'package:dart/src/build_in_parameter_transformer.dart';
import 'package:dart/src/core/locale.dart';
import 'package:dart/src/cucumber_expression_exception.dart';
import 'package:test/test.dart';

enum Fruit {
  banana,
  apple,
  orange,
}

enum Color {
  red,
  green,
  blue,
}

void main() {
  final defaultTransformer = BuiltInParameterTransformer(englishLocale);

  test('should_convert_to_specific_enum', () {
    expect(
        defaultTransformer.transform('banana', Fruit, enumValues: Fruit.values),
        Fruit.banana);
  });

  test('should_convert_to_Enum_type', () {
    expect(
      defaultTransformer.transform(
        'banana',
        Enum,
        enumValues: Fruit.values,
      ),
      Fruit.banana,
    );
  });

  test('invalid_enum_value_causes_error', () {
    expect(
      () => defaultTransformer.transform(
        'strawberry',
        Fruit,
        enumValues: Fruit.values,
      ),
      throwsA(isA<CucumberExpressionException>()),
    );
  });

  test('invalid_enum_type_causes_error', () {
    expect(
      () => defaultTransformer.transform(
        'black',
        Fruit,
        enumValues: Color.values,
      ),
      throwsArgumentError,
    );
  });

  test('should_convert_to_string', () {
    expect(
        defaultTransformer.transform(
          'Barbara Liskov',
          String,
        ),
        'Barbara Liskov');
  });

  test('should_convert_to_object', () {
    expect(
        defaultTransformer.transform(
          'Barbara Liskov',
          Object,
        ),
        'Barbara Liskov');
  });

  test('should_convert_to_int', () {
    const value = 1234567;
    expect(
        defaultTransformer.transform(
          value.toString(),
          int,
        ),
        value);
  });

  test('should_convert_int_to_num', () {
    const value = 1234567;
    expect(
        defaultTransformer.transform(
          value.toString(),
          num,
        ),
        value);
  });

  test('should_convert_double', () {
    const value = 1234567.89;
    expect(
        defaultTransformer.transform(
          value.toString(),
          double,
        ),
        value);
  });

  test('should_convert_double_to_num', () {
    const value = 1234567.89;
    expect(
        defaultTransformer.transform(
          value.toString(),
          num,
        ),
        value);
  });

  test('should_convert_to_bool', () {
    const value = true;
    expect(
        defaultTransformer.transform(
          value.toString(),
          bool,
        ),
        value);
  });

  // With generics

  test('should_convert_to_specific_enum', () {
    expect(
        defaultTransformer.transformTo<Fruit>('banana',
            enumValues: Fruit.values),
        Fruit.banana);
  });

  test('should_convert_to_Enum_type', () {
    expect(
      defaultTransformer.transformTo<Enum>(
        'banana',
        enumValues: Fruit.values,
      ),
      Fruit.banana,
    );
  });

  test('invalid_enum_value_causes_error', () {
    expect(
      () => defaultTransformer.transformTo<Fruit>('strawberry',
          enumValues: Fruit.values),
      throwsA(isA<CucumberExpressionException>()),
    );
  });

  test('invalid_enum_type_causes_error', () {
    expect(
      () => defaultTransformer.transformTo<Fruit>('black',
          enumValues: Color.values),
      throwsArgumentError,
    );
  });

  test('should_convert_to_string', () {
    expect(defaultTransformer.transformTo<String>('Barbara Liskov'),
        'Barbara Liskov');
  });

  test('should_convert_to_object', () {
    expect(defaultTransformer.transformTo<Object>('Barbara Liskov'),
        'Barbara Liskov');
  });

  test('should_convert_to_int', () {
    const value = 1234567;
    expect(defaultTransformer.transformTo<int>(value.toString()), value);
  });

  test('should_convert_int_to_num', () {
    const value = 1234567;
    expect(defaultTransformer.transformTo<num>(value.toString()), value);
  });

  test('should_convert_double', () {
    const value = 1234567.89;
    expect(defaultTransformer.transformTo<double>(value.toString()), value);
  });

  test('should_convert_double_to_num', () {
    const value = 1234567.89;
    expect(defaultTransformer.transformTo<num>(value.toString()), value);
  });

  test('should_convert_to_bool', () {
    const value = true;
    expect(defaultTransformer.transformTo<bool>(value.toString()), value);
  });
}
