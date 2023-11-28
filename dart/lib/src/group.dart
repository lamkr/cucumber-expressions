class Group {
  final List<Group> children;
  final String value;
  final int start;
  final int end;

  Group(this.value, this.start, this.end, this.children);

  List<String> get values {
    List<Group> groups = children.isEmpty ? <Group>[this]
        : children;
    return groups.map((group) => group.value).toList();
  }
}
