import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

/// Lets every scrollable respond to mouse drag, trackpad and stylus as well as
/// touch.
///
/// Flutter's default only allows touch (and trackpad) drags, so on desktop web a
/// horizontal list such as the "Kelas" tabs cannot be scrolled with a mouse.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
