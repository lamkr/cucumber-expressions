import 'group.dart';

class GroupBuilder {
  final _groupBuilders = <GroupBuilder>[];
  final int startIndex;
  int endIndex = -1;
  String source = '';
  bool _capturing = true;

  GroupBuilder(this.startIndex);

  bool get isCapturing => _capturing;

  void setNonCapturing() => _capturing = false;

  List<GroupBuilder> get children => _groupBuilders;

  void add(GroupBuilder groupBuilder) => children.add(groupBuilder);

  void moveChildrenTo(GroupBuilder groupBuilder) {
    for (GroupBuilder child in _groupBuilders) {
      groupBuilder.add(child);
    }
  }

  Group build(RegExpMatch match, Iterator<int> groupIndices) {
    if(groupIndices.moveNext() ) {
      int groupIndex = groupIndices.current;
      final children = <Group>[];
      for (GroupBuilder childGroupBuilder in _groupBuilders) {
        children.add(childGroupBuilder.build(match, groupIndices));
      }
      final value = match.group(groupIndex) ?? '';
      return Group(value, match.start, match.end, children);
    }
    return Group.invalid;
}
