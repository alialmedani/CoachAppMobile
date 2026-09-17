import 'package:flutter/widgets.dart';

/// Which corners a [ChamferBorder] / [ChamferClipper] cuts.
enum ChamferCorner { topLeft, topRight, bottomRight, bottomLeft }

/// The Apex "equipment-tag" chamfer — the default signature cut (top-left +
/// bottom-right), matching the concept's competition-bib silhouette.
const Set<ChamferCorner> kApexTagCorners = {
  ChamferCorner.topLeft,
  ChamferCorner.bottomRight,
};

/// Public access to the Apex chamfer silhouette as a [Path] — for painters that
/// need to fill/stroke/clip the exact same shape a [ChamferBorder] /
/// [ChamferClipper] would produce (e.g. the athlete credential backdrop).
Path apexChamferPath(
  Rect rect, {
  double cut = 20,
  Set<ChamferCorner> corners = kApexTagCorners,
}) => _chamferPath(rect, cut, corners);

Path _chamferPath(Rect r, double cut, Set<ChamferCorner> corners) {
  // Clamp so the cut never exceeds half the shorter side.
  final c = cut.clamp(0.0, (r.shortestSide / 2));
  final tl = corners.contains(ChamferCorner.topLeft);
  final tr = corners.contains(ChamferCorner.topRight);
  final br = corners.contains(ChamferCorner.bottomRight);
  final bl = corners.contains(ChamferCorner.bottomLeft);
  final p = Path();

  // Start on the top edge, just past the (optional) top-left cut.
  p.moveTo(r.left + (tl ? c : 0), r.top);
  // → top-right
  if (tr) {
    p.lineTo(r.right - c, r.top);
    p.lineTo(r.right, r.top + c);
  } else {
    p.lineTo(r.right, r.top);
  }
  // → bottom-right
  if (br) {
    p.lineTo(r.right, r.bottom - c);
    p.lineTo(r.right - c, r.bottom);
  } else {
    p.lineTo(r.right, r.bottom);
  }
  // → bottom-left
  if (bl) {
    p.lineTo(r.left + c, r.bottom);
    p.lineTo(r.left, r.bottom - c);
  } else {
    p.lineTo(r.left, r.bottom);
  }
  // → back to start along the left edge
  if (tl) {
    p.lineTo(r.left, r.top + c);
  } else {
    p.lineTo(r.left, r.top);
  }
  p.close();
  return p;
}

/// A rounded-rectangle-shaped border with one or more corners cut on the
/// diagonal — the Apex signature surface silhouette. Use as a Card/Material/
/// button `shape` or via `ShapeDecoration`.
///
/// RTL: the cut geometry is fixed; callers that want a mirrored silhouette in
/// RTL should pass the horizontally-swapped [corners].
class ChamferBorder extends OutlinedBorder {
  final double cut;
  final Set<ChamferCorner> corners;

  const ChamferBorder({
    this.cut = 16,
    this.corners = kApexTagCorners,
    super.side = BorderSide.none,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _chamferPath(rect.deflate(side.width), cut, corners);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _chamferPath(rect, cut, corners);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final paint = side.toPaint();
    // Stroke centered on the inset outline so the whole border stays inside.
    canvas.drawPath(_chamferPath(rect.deflate(side.width / 2), cut, corners), paint);
  }

  @override
  ChamferBorder copyWith({BorderSide? side, double? cut, Set<ChamferCorner>? corners}) =>
      ChamferBorder(
        cut: cut ?? this.cut,
        corners: corners ?? this.corners,
        side: side ?? this.side,
      );

  @override
  ShapeBorder scale(double t) =>
      ChamferBorder(cut: cut * t, corners: corners, side: side.scale(t));
}

/// Clips a child (image / hero) to the Apex chamfer silhouette.
class ChamferClipper extends CustomClipper<Path> {
  final double cut;
  final Set<ChamferCorner> corners;

  const ChamferClipper({this.cut = 20, this.corners = kApexTagCorners});

  @override
  Path getClip(Size size) =>
      _chamferPath(Offset.zero & size, cut, corners);

  @override
  bool shouldReclip(covariant ChamferClipper old) =>
      old.cut != cut || old.corners != corners;
}
