import 'package:dart/src/core/null_safety_object.dart';

class Group implements NullSafetyObject {
  final List<Group> children;
  final String value;
  final int start;
  final int end;

  static final invalid = _InvalidGroup();

  Group(this.value, this.start, this.end, List<Group> children)
    : children = List<Group>.unmodifiable(children);

  List<String> get values {
    if(children.isEmpty) {
      return <String>[value];
    }
    return children.map((group) => group.value).toList();
  }

  @override
  bool get isInvalid => !isValid;

  @override
  bool get isValid => true;
}

class _InvalidGroup extends Group {
  _InvalidGroup() : super('', -1, -1, const <Group>[]);

  @override
  bool get isValid => false;
}
