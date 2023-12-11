import 'package:dart/src/core/null_safety_object.dart';

abstract class Located implements NullSafetyObject{
  int get start;
  int get end;
}

