import 'parameter_type.dart';

class GeneratedExpression {

  final String expressionTemplate;
  final List<ParameterType> parameterTypes;

  GeneratedExpression(this.expressionTemplate, this.parameterTypes);

  String get source {
    throw UnimplementedError();
    /*
    List<String> parameterTypeNames = ArrayList<>();
    for (ParameterType parameterType in parameterTypes) {
      String name = parameterType.name;
      parameterTypeNames.add(name);
    }
    return String.format(expressionTemplate, parameterTypeNames.toArray());*/
  }
}