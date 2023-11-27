import 'package:intl/locale.dart';

import 'number_parser.dart';
import 'parameter_by_type_transformer.dart';

class BuiltInParameterTransformer implements ParameterByTypeTransformer {

  final NumberParser numberParser;

  BuiltInParameterTransformer(Locale locale)
    : numberParser = NumberParser(locale);

  @override
  Object transform(String fromValue, Type toValueType) {
    // TODO: implement transform
    throw UnimplementedError();
  }
}
