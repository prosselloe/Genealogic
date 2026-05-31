import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genealogic_balear/models/photo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class _CroppedImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect cropRect;

  _CroppedImagePainter(this.image, this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final src = cropRect;
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _CroppedImagePainter oldDelegate) {
    return image != oldDelegate.image || cropRect != oldDelegate.cropRect;
  }
}

class CroppedImageWidget extends StatefulWidget {
  final Photo photo;
  final BoxFit fit;

  const CroppedImageWidget({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
  });

  @override
  State<CroppedImageWidget> createState() => _CroppedImageWidgetState();
}

class _CroppedImageWidgetState extends State<CroppedImageWidget> {
  late Future<Widget> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadAndProcessImage();
  }

  @override
  void didUpdateWidget(covariant CroppedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photo != oldWidget.photo || widget.fit != oldWidget.fit) {
      _imageFuture = _loadAndProcessImage();
    }
  }

  Future<Uint8List?> _getImageData() async {
    final photoToLoad = widget.photo;

    if (photoToLoad.url.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(photoToLoad.url));
        if (response.statusCode == 200) return response.bodyBytes;
      } catch (e) {
        if (kDebugMode) print('Error de xarxa, provant fallback local: $e');
      }
    }
    try {
      final assetPath = 'assets/images/${photoToLoad.title}.${photoToLoad.format}';
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) print('Error en carregar asset local: $e');
      return null;
    }
  }

  Future<Widget> _loadAndProcessImage() async {
    final imageBytes = await _getImageData();

    if (imageBytes == null) {
      return Image.asset('assets/images/logo.png', fit: widget.fit);
    }

    if (widget.photo.isPersonal) {
      final position = widget.photo.position;
      if (position.isNotEmpty && position.length == 4) {
        try {
          final codec = await ui.instantiateImageCodec(imageBytes);
          final frame = await codec.getNextFrame();
          final fullImage = frame.image;

          final cropRect = Rect.fromLTRB(
            position[0],
            position[1],
            position[2],
            position[3],
          );

          if (cropRect.left < 0 ||
              cropRect.top < 0 ||
              cropRect.right > fullImage.width ||
              cropRect.bottom > fullImage.height ||
              cropRect.width <= 0 ||
              cropRect.height <= 0) {
            return Image.memory(imageBytes, fit: widget.fit);
          }

          return FittedBox(
            fit: widget.fit,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: cropRect.width,
              height: cropRect.height,
              child: CustomPaint(
                painter: _CroppedImagePainter(fullImage, cropRect),
              ),
            ),
          );
        } catch (e) {
          if (kDebugMode) print('Error processing image for cropping: $e');
          return Image.memory(imageBytes, fit: widget.fit);
        }
      }
    }

    return Image.memory(imageBytes, fit: widget.fit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Image.asset('assets/images/logo.png', fit: widget.fit);
        }
        return snapshot.data!;
      },
    );
  }
}
