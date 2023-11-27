import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'cucumber_expression_exception.dart';

final class NumberParser {
  final NumberFormat numberFormat;

  NumberParser(Locale locale)
    : numberFormat = NumberFormat.decimalPattern(locale.toLanguageTag());

  double parseDouble(String source) => parse(source).toDouble();

  num parse(String s) {
    try {
      return numberFormat.parse(s);
    } catch (e) {
      throw CucumberExpressionException("Failed to parse number", e as Exception);
    }
  }
}
