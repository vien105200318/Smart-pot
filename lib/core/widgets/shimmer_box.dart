import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius radius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = const BorderRadius.all(Radius.circular(12)),
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = baseColor ??
        (isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB));
    final highlight =
        highlightColor ?? (isDark ? const Color(0xFF30363D) : const Color(0xFFF3F4F6));
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
      ),
    );
  }
}
