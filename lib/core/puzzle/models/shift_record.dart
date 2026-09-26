import 'shift_direction.dart';

/// Pure Dart representation of an individual row or column shift.
class ShiftRecord {
  final bool isRow;
  final int index;
  final ShiftDirection direction;

  const ShiftRecord({
    required this.isRow,
    required this.index,
    required this.direction,
  });

  @override
  String toString() =>
      isRow ? 'Row $index ${direction.name}' : 'Col $index ${direction.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftRecord &&
          runtimeType == other.runtimeType &&
          isRow == other.isRow &&
          index == other.index &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(isRow, index, direction);
}
