import 'package:flutter/material.dart';
import 'package:genealogic_balear/models/photo.dart';
import 'package:genealogic_balear/widgets/cropped_image_widget.dart';

class FullScreenImageViewer extends StatelessWidget {
  final Photo photo;

  const FullScreenImageViewer({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: CroppedImageWidget(
            photo: photo,
            fit: BoxFit.contain, // Use contain for fullscreen view
          ),
        ),
      ),
    );
  }
}
