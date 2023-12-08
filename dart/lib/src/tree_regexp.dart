import 'package:dart/src/core/stack.dart';
import 'package:dart/src/group_builder.dart';

import 'group.dart';

/// [TreeRegexp] represents matches as a tree of [Group]
/// reflecting the nested structure of capture groups in the original
/// regexp.
class TreeRegexp {
  final RegExp regexp;
  final GroupBuilder groupBuilder;

  TreeRegexp(this.regexp) : groupBuilder = _createGroupBuilder(regexp);

  TreeRegexp.fromString(String regexp) : this(RegExp(regexp));

  static GroupBuilder _createGroupBuilder(RegExp regexp) {
    final source = regexp.pattern.codeUnits;
    final stack = Stack<GroupBuilder>()..push(GroupBuilder(0));
    var escaping = false, charClass = false;

    for (var index = 0; index < source.length; index++) {
      final char = source.elementAt(index);
      if (char == '['.codeUnits.first && !escaping) {
        charClass = true;
      } else if (char == ']'.codeUnits.first && !escaping) {
        charClass = false;
      } else if (char == '('.codeUnits.first && !escaping && !charClass) {
        final nonCapturing = _isNonCapturingGroup(source, index);
        final groupBuilder = GroupBuilder(index);
        if (nonCapturing) {
          groupBuilder.setNonCapturing();
        }
        stack.push(groupBuilder);
      } else if (char == ')'.codeUnits.first && !escaping && !charClass) {
        final gb = stack.pop();
        if (gb.isCapturing) {
          gb.source = source.getRange(gb.startIndex + 1, index).toString();
          stack.peek().add(gb);
        } else {
          gb.moveChildrenTo(stack.peek());
        }
        gb.endIndex = index;
      }
      escaping = char == '\\'.codeUnits.first && !escaping;
    }
    return stack.pop();
  }

  static bool _isNonCapturingGroup(List<int> source, int index) {
    // Regex is valid. Bounds check not required.
    if (source.elementAt(index + 1) != '?'.codeUnits.first) {
      // (X)
      return false;
    }
    if (source.elementAt(index + 2) != '<'.codeUnits.first) {
      // (?:X)
      // (?idmsuxU-idmsuxU)
      // (?idmsux-idmsux:X)
      // (?=X)
      // (?!X)
      // (?>X)
      return true;
    }
    // (?<=X) or (?<!X) else (?<name>X)
    return source.elementAt(index + 3) == '='.codeUnits.first ||
        source.elementAt(index + 3) == '!'.codeUnits.first;
  }

  Group match(String input) {
    final match = regexp.firstMatch(input);
    if (match == null) {
      return Group.invalid;
    }
    final groupIndices = <int>[for(int i=0; i < match.groupCount; i++) i].iterator;
    return groupBuilder.build(match, groupIndices);
  }
}
