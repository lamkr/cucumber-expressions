class GroupBuilder {
  final int startIndex;
  int endIndex = -1;
  String source = '';
  bool capturing = true;

  set nonCapturing(bool value) => capturing = !value;
  final children = <GroupBuilder>[];

  GroupBuilder(this.startIndex);

  void add(GroupBuilder groupBuilder) => children.add(groupBuilder);

  void moveChildrenTo(GroupBuilder groupBuilder) {
    for (GroupBuilder child in children) {
      groupBuilder.add(child);
    }
  }
}
