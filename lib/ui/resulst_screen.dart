import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sensors_flutter/ui/camera_screen.dart';

class ResultScreen extends StatelessWidget {
  final String file;
  const ResultScreen({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
        ),
      ),
      body: Expanded(child: Image.file(File(file))),
    );
  }
}
