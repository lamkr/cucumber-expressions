import 'ast/node.dart';
import 'cucumber_expression_exception.dart';

class UndefinedParameterTypeException extends CucumberExpressionException {
  final String undefinedParameterTypeName;

  UndefinedParameterTypeException._(
      super._message, this.undefinedParameterTypeName);

  static CucumberExpressionException createUndefinedParameterType(
          Node node, String expression, String undefinedParameterTypeName) =>
      UndefinedParameterTypeException._(
        CucumberExpressionException.message(
            node.start,
            expression,
            CucumberExpressionException.pointAt(node),
            "Undefined parameter type '$undefinedParameterTypeName'",
            "Please register a ParameterType for '$undefinedParameterTypeName'"),
        undefinedParameterTypeName,
      );
}
