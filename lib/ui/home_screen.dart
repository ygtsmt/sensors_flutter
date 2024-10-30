import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_flutter/ui/camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PermissionStatus? permissionStatus;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // ignore: prefer_const_constructors
        title: Text('Using sensors with Flutter'),
      ),
      body: Center(
        child: FilledButton(
            onPressed: () async {
              permissionStatus = await Permission.camera.request();
              if (permissionStatus?.isGranted == true) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              }
            },
            child: const Text('Take a photo')),
      ),
    );
  }
}
