import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Adapts the phone-shaped UI to the browser window on web.
///
/// The app is laid out for a 360x690 phone via flutter_screenutil, so on a wide
/// window it would otherwise scale up enormously. Width tiers:
///
/// * mobile  (< 600):   the app fills the window, like the native app.
/// * tablet  (600-1023): a centered 560px column.
/// * desktop (>= 1024): a centered 640px column.
///
/// Wider tiers also scale text and spacing a little (never more than ~1.2x), so
/// the UI is comfortable to read on a monitor without becoming huge. On every
/// other platform this widget does nothing.
class WebFrame extends StatelessWidget {
  static const double _mobileMax = 600;
  static const double _tabletMax = 1024;
  static const Size _designSize = Size(360, 690);

  final Widget child;

  const WebFrame({super.key, required this.child});

  static _Tier _tierFor(double windowWidth) {
    if (windowWidth < _mobileMax) {
      return _Tier(
        width: windowWidth,
        scaleWidth: math.min(windowWidth, 480),
        framed: false,
      );
    }
    if (windowWidth < _tabletMax) {
      return const _Tier(width: 560, scaleWidth: 400, framed: true);
    }
    return const _Tier(width: 640, scaleWidth: 420, framed: true);
  }

  /// Makes flutter_screenutil scale against the active tier instead of the full
  /// browser window. Call it right after ScreenUtilInit has configured itself
  /// (i.e. from its builder); it re-runs whenever the window is resized.
  static void capScreenUtil(BuildContext context) {
    if (!kIsWeb) return;
    final raw = MediaQueryData.fromView(View.of(context));
    final tier = _tierFor(raw.size.width);
    if (tier.scaleWidth >= raw.size.width) return;
    ScreenUtil.configure(
      data: raw.copyWith(
        size: Size(
          tier.scaleWidth,
          math.min(raw.size.height,
              tier.scaleWidth * _designSize.height / _designSize.width),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final mq = MediaQuery.of(context);
    final tier = _tierFor(mq.size.width);
    if (!tier.framed) return child;

    return ColoredBox(
      color: const Color(0xFFE9ECEF),
      child: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SizedBox(
            width: tier.width,
            child: MediaQuery(
              data: mq.copyWith(size: Size(tier.width, mq.size.height)),
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tier {
  /// Width the app is laid out in.
  final double width;

  /// Width flutter_screenutil scales against (design width is 360).
  final double scaleWidth;

  /// Whether the app sits in a centered frame with the page behind it.
  final bool framed;

  const _Tier({
    required this.width,
    required this.scaleWidth,
    required this.framed,
  });
}
