// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:lottie/lottie.dart';

import '../../services/auth_oss.dart';
import '../../services/auth_postgresql.dart';
import 'error.dart';
import 'preview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
    await databaseConnection.open();
    Client.init(
        ossEndpoint: "oss-ap-southeast-1.aliyuncs.com",
        bucketName: "flutterbucket-test2-imran",
        authGetter: authGetter);
    final cameras = await availableCameras();
    final camera = cameras.first;

    runApp(MyCamera(camera: camera));
  } catch (e) {
    // print('Password is: \n$password');
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class MyCamera extends StatelessWidget {
  final CameraDescription camera;

  const MyCamera({super.key, required this.camera});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CameraBOi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Camera(title: 'AIIP P5', camera: camera),
    );
  }
}

class Camera extends StatefulWidget {
  const Camera({super.key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  Uint8List? fileBytes;
  String? fileName;
  late CameraController _cameraController;
  late Future<void> _initControllerFuture;
  bool isFlashOn = false;
  double zoomLevel = 1.0;
  bool isSwitchingCamera = false;

  void toggleSwitchingCamera() {
    setState(() {
      isSwitchingCamera = !isSwitchingCamera;
    });
  }

  @override
  void initState() {
    super.initState();

    _cameraController =
        CameraController(widget.camera, ResolutionPreset.veryHigh);

    _initControllerFuture = _cameraController.initialize();
  }

  void toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      _cameraController
          .setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  void switchCamera() async {
    final cameras = await availableCameras();
    final newCamera = cameras.firstWhere((camera) =>
        camera.lensDirection != _cameraController.description.lensDirection);

    toggleSwitchingCamera(); // Show Lottie animation

    await Future.delayed(
        const Duration(seconds: 1)); // Adjust the duration as needed

    await _cameraController.dispose();
    _cameraController = CameraController(newCamera, ResolutionPreset.veryHigh);
    _initControllerFuture = _cameraController.initialize();
    toggleSwitchingCamera(); // Hide Lottie animation
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void zoomIn() {
    setState(() {
      zoomLevel += 0.1;
      if (zoomLevel > 2.0) {
        zoomLevel = 2.0;
      }
      _cameraController.setZoomLevel(zoomLevel);
    });
  }

  void zoomOut() {
    setState(() {
      zoomLevel -= 0.1;
      if (zoomLevel < 1.0) {
        zoomLevel = 1.0;
      }
      _cameraController.setZoomLevel(zoomLevel);
    });
  }

  Future<void> takeImage() async {
    try {
      await _initControllerFuture;
      final image = await _cameraController.takePicture();
      final path = image.path;

      setState(() {
        fileBytes = File(path).readAsBytesSync();
        fileName = image.name;
      });

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
            fileBytes: fileBytes!,
            fileName: fileName!,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FutureBuilder<void>(
            future: _initControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final cameraAspectRatio = _cameraController.value.aspectRatio;
                return AspectRatio(
                  aspectRatio: cameraAspectRatio,
                  child: CameraPreview(_cameraController),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (isSwitchingCamera)
            Center(
              child: Lottie.asset(
                  'assets/switch.json'), // Replace with the path to your Lottie animation
            ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: toggleFlash,
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: switchCamera,
                  icon: const Icon(
                    Icons.switch_camera,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: takeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.camera_alt, size: 50),
                ),
                IconButton(
                  onPressed: zoomIn,
                  icon: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: zoomOut,
                  icon: const Icon(
                    Icons.zoom_out,
                    color: Colors.white,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
