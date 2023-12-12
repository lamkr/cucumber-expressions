import 'package:dart/src/build_in_parameter_transformer.dart';
import 'package:dart/src/core/locale.dart';
import 'package:dart/src/core/type_ex.dart';
import 'package:dart/src/parameter_by_type_transformer.dart';
import 'package:dart/src/parameter_type.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:dart/src/transformer.dart';
import 'package:test/test.dart';

void main() {
  final defaultTransformer = BuiltInParameterTransformer(
      englishLocale);

  test('should_convert_null_to_null', () {
    expect(defaultTransformer.transform<Object>(null), isNull);
  });

  test('should_convert_to_string', () {
    expect(defaultTransformer.transform<String>("Barbara Liskov"), "Barbara Liskov");
  });

}
