abstract class NullSafetyObject extends Object
{
  /// Returns if this instance is valid or not.
  bool get isValid;

  /// Returns if this instance is invalid or not.
  bool get isInvalid => !isValid;
}