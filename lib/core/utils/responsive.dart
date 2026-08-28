import 'package:flutter/widgets.dart';

/// Xác định breakpoint dựa trên width hiện tại.
/// Dùng chung cho tất cả màn hình (MainLayout, Home, Community, Wallet...).
class Responsive {
  /// Width hiện tại của vùng chứa (từ LayoutBuilder).
  final double width;

  const Responsive(this.width);

  /// Màn hình tablet (>= 800px): chuyển sang NavigationRail, bỏ bottom bar.
  bool get isTablet => width >= 800;

  /// Màn hình rộng (>= 700px): grid 2 cột.
  bool get isWide => width >= 700;

  /// Màn hình rất rộng (>= 1100px): grid 3 cột.
  bool get isVeryWide => width >= 1100;

  /// Số cột hợp lý cho grid layout.
  int get gridColumns {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }
}
