// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:aiip_p5_main/services/preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:aiip_p5_main/pages/preview.dart';
import 'package:camera/camera.dart';
import 'package:lottie/lottie.dart';

import 'package:aiip_p5_main/util.dart';
import 'package:aiip_p5_main/model/van_user.dart';

class Camera extends StatefulWidget {
  const Camera(
      {super.key,
      required this.title,
      required this.camera,
      required this.user});

  final String title;
  final CameraDescription camera;
  final VanUser user;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final myFormat = DateFormat.Hms();
  late VanUser user;
  // final String? vanUserId = UserPreferences.getUserId();

  Uint8List? fileBytes;
  List<Uint8List> allFileBytes = [];
  String? fileName;
  List<String> allFileName = [];
  String? filePath;
  List<String> allFilePath = [];

  int imageCount = 0;

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
    user = widget.user;

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

      setState(() {
        String noSemiColon =
            myFormat.format(DateTime.now()).replaceAll(RegExp(r'[:]'), '-');
        fileName = '$noSemiColon.jpg';
        filePath = image.path;
        fileBytes = File(filePath!).readAsBytesSync();

        allFileBytes.add(fileBytes!);
        allFileName.add(fileName!);
        allFilePath.add(filePath!);

        imageCount++;
        ImageCountPreferences.setImageCount(imageCount);
        imageCount = ImageCountPreferences.getImageCount()!;
      });

      if (!mounted) return;
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
          imageCount == 0
              ? SizedBox()
              : Positioned(
                  bottom: 100.0,
                  right: 10,
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.red)))),
                      onPressed: () {
                        _goToPreview();
                      },
                      child: Column(
                        children: [
                          spaceVertical(10),
                          Text('${user.firstName} ${user.lastName}'),
                          spaceVertical(10),
                          Text(imageCount.toString()),
                          spaceVertical(10),
                          Image.file(
                            File(filePath!),
                            fit: BoxFit.cover,
                          ),
                          // spaceVertical(5),
                          // Text(fileName!),
                          // Text(filePath!),
                          // Text(
                          //     '${fileBytes.toString().substring(0, 200)} ...\n\n... ${fileBytes.toString().substring(fileBytes!.toString().length - 200)}'),
                          spaceVertical(10),
                        ],
                      ),
                    ),
                  )),
          Positioned(
            bottom: 30.0,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _goToPreview() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
          allFilePath: allFilePath,
          allFileBytes: allFileBytes,
          allFileName: allFileName,
          user: user,
        ),
      ),
    );
    setState(() {
      allFileBytes.clear();
      allFileName.clear();
      allFilePath.clear();
      imageCount = 0;
      ImageCountPreferences.setImageCount(imageCount);
    });
  }

  String _domainName() {
    return 'http://47.250.10.195:3030';
    // return 'http://localhost:8080';
  }

  _getVanUser(String van_user_id) async {
    final url = Uri.parse('${_domainName()}/get_one_van_user');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"van_user_id": van_user_id}));

    return response.body;
  }
}
