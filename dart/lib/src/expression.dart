import 'argument.dart';

abstract class Expression {
  List<Argument> match(String text, List<Type> typeHints);

  Pattern get regexp;

  String get source;
}
