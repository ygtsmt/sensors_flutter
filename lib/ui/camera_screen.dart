import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_flutter/ui/resulst_screen.dart';
import 'package:sensors_flutter/ui/widgets/camera_count_down_widget.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final Future<void> _future;
  CameraController? _cameraController;
  bool isPhoneSteady = true;
  late Timer _steadinessTimer;
  int countdown = 5;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
    _checkPhoneSteadiness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _steadinessTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return FutureBuilder<List<CameraDescription>>(
          future: availableCameras(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _initCameraController(snapshot.data!);

              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: CameraPreview(
                          _cameraController!,
                          child: Center(
                            child: CameraCountDownWidget(
                              isPhoneSteady: isPhoneSteady,
                              countdown: countdown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    top: MediaQuery.of(context).size.height / 3 * 2,
                    child: Container(color: Colors.white.withOpacity(0.2)),
                  ),
                  Positioned.fill(
                    bottom: MediaQuery.of(context).size.height / 3 * 2,
                    child: Container(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FilledButton(
                      onPressed: () => takePicture(),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              );
            } else {
              return const LinearProgressIndicator();
            }
          },
        );
      },
    ));
  }

  void _checkPhoneSteadiness() {
    _steadinessTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (isPhoneSteady) {
        if (countdown == 0) {
          if (mounted) {
            setState(() {
              takePicture();
            });
          }
          timer.cancel();
        } else {
          if (mounted) {
            setState(() {
              countdown--;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            countdown = 5;
          });
        }
      }
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (event.x.abs() < 0.1 && event.y.abs() < 0.1) {
        if (mounted) {
          setState(() {
            isPhoneSteady = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isPhoneSteady = false;
          });
        }
      }
    });
  }

  Future<void> _requestCameraPermission() async {
    await Permission.camera.request();
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(
      FlashMode.off,
    );

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> takePicture() async {
    final pictureFile = await _cameraController!.takePicture();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultScreen(file: pictureFile.path)),
    );
    debugPrint('${pictureFile.path}dene');
  }
}
