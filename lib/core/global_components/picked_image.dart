import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Renders an image picked with image_picker on every platform.
///
/// Reads the bytes instead of using `Image.file`, because `dart:io` files are
/// not available on web.
class PickedImage extends StatefulWidget {
  final XFile file;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const PickedImage({
    super.key,
    required this.file,
    this.width,
    this.height,
    this.fit,
  });

  @override
  State<PickedImage> createState() => _PickedImageState();
}

class _PickedImageState extends State<PickedImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant PickedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _bytes = widget.file.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Icon(Icons.broken_image_outlined),
          );
        }
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
