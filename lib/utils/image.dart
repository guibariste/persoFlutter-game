import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:typed_data';

class FullScreenImageWidget extends StatelessWidget {
  final Uint8List? image;

  FullScreenImageWidget({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: PhotoView(
          imageProvider: MemoryImage(image!),
        ),
      ),
    );
  }
}

class CircleImageWidget extends StatelessWidget {
  final Uint8List? image;
  final double radius;

  CircleImageWidget({required this.image, this.radius = 40});

  void _showFullScreenImage(BuildContext context) {
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageWidget(image: image),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(context);
      },
      child: ClipOval(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: image != null
              ? Image.memory(
                  image!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.person,
                  size: radius * 2,
                  color: Colors.grey,
                ),
        ),
      ),
    );
  }
}
