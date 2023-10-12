// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

//basic library
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

//nak tambah api dalam ni

//for client connection library
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_oss.dart';
import 'auth_postgresql.dart';

//camera function library
import 'package:camera/camera.dart';

//pages
import 'preview.dart';
import 'error.dart';

//misc
import 'util.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    await databaseConnection.open();
    Client.init(
        //MALAYSIA
        // ossEndpoint: "oss-ap-southeast-3.aliyuncs.com",
        // bucketName: "flutterbucket-test1-imran",

        //SINGAPORE
        ossEndpoint: "oss-ap-southeast-1.aliyuncs.com",
        bucketName: "flutterbucket-test2-imran",
        authGetter: authGetter);
    final cameras = await availableCameras();
    final camera = cameras.first;

    runApp(MyApp(camera: camera));
  } catch (e) {
    // print('Password is: \n$password');
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'AIIP P5', camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? fileBytes;
  String? fileName;
  late CameraController _cameraController;
  late Future<void> _initControllerFuture;

  @override
  void initState() {
    super.initState();

    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);

    _initControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future takeImage() async {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is a camera',
            ),
            SizedBox(
              height: 600,
              child: FutureBuilder<void>(
                future: _initControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_cameraController);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            spaceVertical(15),
            FloatingActionButton(
              onPressed: () async {
                takeImage();
              },
              child: const Icon(Icons.camera_alt),
            )
          ],
        ),
      ),
    );
  }
}
