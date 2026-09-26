enum PieceType {
  cyanCircle('circle', 'Cyan Circle'),
  amberDiamond('diamond', 'Amber Diamond'),
  roseSquare('square', 'Rose Square'),
  emeraldHexagon('hexagon', 'Emerald Hexagon'),
  violetTriangle('triangle', 'Violet Triangle');

  final String shape;
  final String label;

  const PieceType(this.shape, this.label);
}
