// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, avoid_print

//basic library
import 'package:intl/intl.dart';

import 'dart:typed_data';
import 'dart:io';

// import 'package:aiip_p5_main/auth_postgresql.dart';
import 'package:flutter/material.dart';

//for client connection library
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'package:lottie/lottie.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

//misc
// import 'util.dart';

final myFormat = DateFormat.yMd().add_Hms();

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Uint8List fileBytes;
  final String fileName;
  // final AudioPlayer audioPlayer = AudioPlayer();

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.fileBytes,
    required this.fileName,
  });

  Future uploadFile() async {
    final truePath = 'folder-akmal/$fileName';
    await Client().putObject(
      fileBytes,
      truePath,
      option: PutRequestOption(
        // bucketName: 'images-admintest/another-dir/flutterbucket-test1-imran',u
        onSendProgress: (count, total) {
          print("send: count = $count, and total = $total");
        },
        onReceiveProgress: (count, total) {
          print("receive: count = $count, and total = $total");
        },
        override: false,
        aclModel: AclMode.publicRead,
        storageType: StorageType.ia,
        headers: {"cache-control": "no-cache"},
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 0,
          backgroundColor: Colors.transparent, // Transparent background
          child: Container(
            width: 750,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              // Dialog background color
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Lottie.asset(
                      'assets/Upload.json',
                      width: 100,
                      height: 100,
                    )),
                Text(
                  'Confirm Upload ?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.only(
                                  bottomStart: Radius.circular(6))),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey[600], // Text color
                        ),
                        icon: Icon(Icons.cancel),
                        label: Text('Cancel'),
                      ),
                    ),
                    // SizedBox(width: 16), // Add some spacing between buttons
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AssetsAudioPlayer.newPlayer().open(
                            Audio("assets/success.mp3"),
                            autoStart: true,
                          );

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Lottie.asset(
                                          'assets/success.json'), // Replace with the path to your Lottie animation JSON file
                                      Text(
                                          'File uploaded into OSS and PostgreSQL.'),

                                      SizedBox(height: 20),
                                      TextButton(
                                        onPressed: () async {
                                          // Close the modal and the preview screen
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          // upload gambarnyaaaa
                          uploadFile();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.only(
                                  bottomEnd: Radius.circular(6))),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(
                              255, 10, 178, 16), // Text color
                        ),
                        icon: Icon(Icons.check_circle),
                        label: Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  File(imagePath),
                  width: MediaQuery.of(context).size.width *
                      0.8, // 80% of screen width
                  height: MediaQuery.of(context).size.height *
                      0.6, // 60% of screen height
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey[600], // Text color
                  ),
                  icon: Icon(Icons.cancel), // Icon for "Cancel"
                  label: Text('Retake'),
                ),
                SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        const Color.fromARGB(255, 10, 178, 16), // Text color
                  ),
                  icon: Icon(Icons.check), // Icon for "Confirm"
                  label: Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
