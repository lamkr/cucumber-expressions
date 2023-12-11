import 'package:dart/src/core/null_safety_object.dart';

import 'node.dart';

class Result implements NullSafetyObject {
  final int consumed;
  final List<Node> ast;

  static const invalid = _InvalidResult();

  const Result(this.consumed, this.ast);

  @override
  bool get isValid => true;

  @override
  bool get isInvalid => !isValid;
}

class _InvalidResult extends Result {
  const _InvalidResult(): super(0, const <Node>[]);

  @override
  bool get isValid => false;
}
