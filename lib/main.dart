// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:aiip_p5_main/auth_oss.dart';
import 'package:aiip_p5_main/pages/login.dart';

import 'services/preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

import 'package:camera/camera.dart';
import 'package:aiip_p5_main/pages/error.dart';
// import 'package:aiip_p5_main/pages/camera.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await ImageCountPreferences.init();
  try {
    await dotenv.load();
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
      home: LoginPage(title: 'AIIP P5', camera: camera),
      // home: Login(title: 'AIIP P5', camera: camera),
    );
  }
}
