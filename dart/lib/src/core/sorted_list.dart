import 'dart:collection';

typedef GetInvalidElement<T> = T Function();

// TODO must be tested
class SortedList<T> extends ListBase<T> {
  final GetInvalidElement<T> _getInvalidElement;

  int _length = 0;

  SortedList(this._getInvalidElement);

  @override
  int get length => _length;

  @override
  set length(int newLength) {
    if (newLength < _length) {
      super.removeRange((_length - newLength), _length);
    } else if (newLength > _length) {
      int count = newLength - _length;
      while (count > 0) {
        super.add(_getInvalidElement());
        count--;
      }
      super.sort();
    }
    _length = newLength;
  }

  @override
  T operator [](int index) => super.elementAt(index);

  @override
  void operator []=(int index, T value) =>
      throw Exception('Sorted list does not support indexed insertion.');

  @override
  void add(T element) {
    super.add(element);
    super.sort();
  }
}
