library collections;

const emptyMap = <String, int>{};

extension IterableExtension<E> on Iterable<E> {
  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this iterable,
  /// converts each one to a [String] by calling [Object.toString],
  /// and then concatenates the strings, with the
  /// [delimiter] string interleaved between the elements.
  ///
  /// Example:
  /// ```dart
  /// final planetsByMass = <double, String>{0.06: 'Mercury', 0.81: 'Venus',
  ///   0.11: 'Mars'};
  /// final joinedNames = planetsByMass.values.join('-'); // Mercury-Venus-Mars
  /// ```
  String joining(
      {String delimiter = '', String prefix = '', String suffix = ''}) {
    Iterator<E> iterator = this.iterator;
    if (!iterator.moveNext()) {
      return "";
    }
    var first = iterator.current.toString();
    if (!iterator.moveNext()) {
      return '$prefix$first$suffix';
    }
    var buffer = StringBuffer(first);
    // TODO(51681): Drop null check when de-supporting pre-2.12 code.
    if (delimiter.isEmpty) {
      do {
        buffer.write(iterator.current.toString());
      } while (iterator.moveNext());
    } else {
      do {
        buffer
          ..write(delimiter)
          ..write(iterator.current.toString());
      } while (iterator.moveNext());
    }
    return buffer.toString();
  }
}
