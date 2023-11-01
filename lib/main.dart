// // ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, avoid_print

// //basic library
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:flutter/material.dart';

// //nak tambah api dalam ni

// //for client connection library
// import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:lottie/lottie.dart';

// //camera function library
// import 'package:camera/camera.dart';

// //pages

// import 'screen/camera/error.dart';
// import 'screen/camera/preview.dart';
// import 'services/auth_oss.dart';
// import 'services/auth_postgresql.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key, required this.camera});

//   final CameraDescription camera;

//   Future main() async {
//     WidgetsFlutterBinding.ensureInitialized();

//     try {
//       await dotenv.load();
//       await databaseConnection.open();
//       Client.init(
//           //MALAYSIA
//           // ossEndpoint: "oss-ap-southeast-3.aliyuncs.com",
//           // bucketName: "flutterbucket-test1-imran",

//           //SINGAPORE
//           ossEndpoint: "oss-ap-southeast-1.aliyuncs.com",
//           bucketName: "flutterbucket-test2-imran",
//           authGetter: authGetter);
//       final cameras = await availableCameras();
//       final camera = cameras.first;

//       runApp(MyApp(camera: camera));
//     } catch (e) {
//       // print('Password is: \n$password');
//       runApp(ErrorApp(errorMessage: e.toString()));
//     }
//   }

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'CameraBOi',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: Camera(camera: camera),
//     );
//   }
// }

// class Camera extends StatefulWidget {
//   const Camera({super.key, required this.camera});

//   final CameraDescription camera;

//   @override
//   State<Camera> createState() => _CameraState();
// }

// class _CameraState extends State<Camera> {
//   Uint8List? fileBytes;
//   String? fileName;
//   late CameraController _cameraController;
//   late Future<void> _initControllerFuture;
//   bool isFlashOn = false;
//   double zoomLevel = 1.0;
//   bool isSwitchingCamera = false;

//   void toggleSwitchingCamera() {
//     setState(() {
//       isSwitchingCamera = !isSwitchingCamera;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     _cameraController =
//         CameraController(widget.camera, ResolutionPreset.veryHigh);

//     _initControllerFuture = _cameraController.initialize();
//   }

//   void toggleFlash() {
//     setState(() {
//       isFlashOn = !isFlashOn;
//       _cameraController
//           .setFlashMode(isFlashOn ? FlashMode.torch : FlashMode.off);
//     });
//   }

//   void switchCamera() async {
//     final cameras = await availableCameras();
//     final newCamera = cameras.firstWhere((camera) =>
//         camera.lensDirection != _cameraController.description.lensDirection);

//     toggleSwitchingCamera(); // Show Lottie animation

//     await Future.delayed(Duration(seconds: 1)); // Adjust the duration as needed

//     await _cameraController.dispose();
//     _cameraController = CameraController(newCamera, ResolutionPreset.veryHigh);
//     _initControllerFuture = _cameraController.initialize();
//     toggleSwitchingCamera(); // Hide Lottie animation
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }

//   void zoomIn() {
//     setState(() {
//       zoomLevel += 0.1;
//       if (zoomLevel > 2.0) {
//         zoomLevel = 2.0;
//       }
//       _cameraController.setZoomLevel(zoomLevel);
//     });
//   }

//   void zoomOut() {
//     setState(() {
//       zoomLevel -= 0.1;
//       if (zoomLevel < 1.0) {
//         zoomLevel = 1.0;
//       }
//       _cameraController.setZoomLevel(zoomLevel);
//     });
//   }

//   Future<void> takeImage() async {
//     try {
//       await _initControllerFuture;
//       final image = await _cameraController.takePicture();
//       final path = image.path;

//       setState(() {
//         fileBytes = File(path).readAsBytesSync();
//         fileName = image.name;
//       });

//       if (!mounted) return;

//       await Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => DisplayPictureScreen(
//             imagePath: image.path,
//             fileBytes: fileBytes!,
//             fileName: fileName!,
//           ),
//         ),
//       );
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           FutureBuilder<void>(
//             future: _initControllerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 final cameraAspectRatio = _cameraController.value.aspectRatio;
//                 return AspectRatio(
//                   aspectRatio: cameraAspectRatio,
//                   child: CameraPreview(_cameraController),
//                 );
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//           ),
//           if (isSwitchingCamera)
//             Center(
//               child: Lottie.asset(
//                   'assets/switch.json'), // Replace with the path to your Lottie animation
//             ),
//           Positioned(
//             bottom: 20.0,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 IconButton(
//                   onPressed: toggleFlash,
//                   icon: Icon(
//                     isFlashOn ? Icons.flash_on : Icons.flash_off,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: switchCamera,
//                   icon: Icon(
//                     Icons.switch_camera,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: takeImage,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.all(16),
//                     shape: CircleBorder(),
//                   ),
//                   child: Icon(Icons.camera_alt, size: 50),
//                 ),
//                 IconButton(
//                   onPressed: zoomIn,
//                   icon: Icon(
//                     Icons.zoom_in,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: zoomOut,
//                   icon: Icon(
//                     Icons.zoom_out,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// main.dart

import 'package:flutter/material.dart';

import 'screen/login_screen.dart';
// Import the camera page file you have

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Navigate to the login page first
      home: const LoginView(),
    );
  }
}
