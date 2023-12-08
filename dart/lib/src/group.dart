import 'package:dart/src/core/null_safety_object.dart';

class Group implements NullSafetyObject {
  final List<Group> children;
  final String value;
  final int start;
  final int end;

  static const invalid = _InvalidGroup();

  const Group(this.value, this.start, this.end, this.children);

  List<String> get values {
    List<Group> groups = children.isEmpty ? <Group>[this]
        : children;
    return groups.map((group) => group.value).toList();
  }

  @override
  bool get isInvalid => !isValid;

  @override
  bool get isValid => true;
}

class _InvalidGroup extends Group {
  const _InvalidGroup() : super('', -1, -1, const <Group>[]);

  @override
  bool get isValid => false;
}
