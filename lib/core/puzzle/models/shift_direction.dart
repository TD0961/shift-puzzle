enum ShiftDirection {
  left,
  right,
  up,
  down;

  bool get isHorizontal => this == ShiftDirection.left || this == ShiftDirection.right;
  bool get isVertical => this == ShiftDirection.up || this == ShiftDirection.down;

  int get deltaRow {
    switch (this) {
      case ShiftDirection.up:
        return -1;
      case ShiftDirection.down:
        return 1;
      case ShiftDirection.left:
      case ShiftDirection.right:
        return 0;
    }
  }

  int get deltaCol {
    switch (this) {
      case ShiftDirection.left:
        return -1;
      case ShiftDirection.right:
        return 1;
      case ShiftDirection.up:
      case ShiftDirection.down:
        return 0;
    }
  }

  ShiftDirection get opposite {
    switch (this) {
      case ShiftDirection.left:
        return ShiftDirection.right;
      case ShiftDirection.right:
        return ShiftDirection.left;
      case ShiftDirection.up:
        return ShiftDirection.down;
      case ShiftDirection.down:
        return ShiftDirection.up;
    }
  }
}
