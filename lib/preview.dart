// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, avoid_print

//basic library
import 'package:aiip_p5_main/util.dart';
import 'package:intl/intl.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final List<String> allFilePath;
  final List<Uint8List> allFileBytes;
  final List<String> allFileName;
  // final AudioPlayer audioPlayer = AudioPlayer();

  const DisplayPictureScreen({
    super.key,
    required this.allFilePath,
    required this.allFileBytes,
    required this.allFileName,
  });

  Future<bool> uploadFiles() async {
    try {
      int i = 0;
      while (i < allFileName.length) {
        print(i);
        print(allFileName[i]);
        print(allFileBytes[i]);
        print(allFilePath[i]);
        final truePath = 'API-model-test/${allFileName[i]}';
        GallerySaver.saveImage(allFilePath[i]);
        await Client().putObject(
          allFileBytes[i],
          truePath,
          option: PutRequestOption(
            override: false,
            aclModel: AclMode.publicWrite,
            storageType: StorageType.ia,
            headers: {"cache-control": "no-cache"},
          ),
        );
        final String fileUrl = await Client().getSignedUrl(truePath);
        _insertImage(allFileName[i], fileUrl.substring(0, fileUrl.indexOf('?')),
            'imran-debug');
        i++;
      }
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  // Future uploadFile() async {
  //   final truePath = 'SINI/$fileName';
  //   await Client().putObject(
  //     fileBytes,
  //     truePath,
  //     option: PutRequestOption(
  //       override: false,
  //       aclModel: AclMode.publicRead,
  //       storageType: StorageType.ia,
  //       headers: {"cache-control": "no-cache"},
  //     ),
  //   );
  //   final String fileUrl = await Client().getSignedUrl(truePath);
  //   _insertImage(fileName, fileUrl, 'imran-debug');
  // }

  void _showConfirmationDialog(BuildContext context) {
    Timer? timer;

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
                        onPressed: () async {
                          timer =
                              Timer.periodic(Duration(seconds: 1), (Timer t) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Lottie.asset(
                                          //     'assets/success.json'),
                                          CircularProgressIndicator(),

                                          Text('File is uploading'),
                                        ],
                                      )),
                                );
                              },
                            );
                            timer!.cancel();
                          });
                          int mySeconds = 1;

                          allFileName.length >= 10
                              ? mySeconds = 3
                              : mySeconds = 1;
                          // upload gambarnyaaaa
                          Future.delayed(Duration(seconds: mySeconds),
                              () async {
                            try {
                              await uploadFiles().then((value) => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      AssetsAudioPlayer.newPlayer().open(
                                        Audio("assets/success.mp3"),
                                        autoStart: true,
                                      );
                                      return AlertDialog(
                                        content: SizedBox(
                                            width: double.infinity,
                                            child: value
                                                ? Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Lottie.asset(
                                                          'assets/success.json'), // Replace with the path to your Lottie animation JSON file
                                                      Text(
                                                          'File uploaded into OSS and PostgreSQL.'),

                                                      SizedBox(height: 20),
                                                      TextButton(
                                                        onPressed: () async {
                                                          // Close the modal and the preview screen
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Lottie.asset(
                                                      //     'assets/success.json'),

                                                      Text(
                                                          'File failed to be uploaded.'),

                                                      SizedBox(height: 20),
                                                      TextButton(
                                                        onPressed: () async {
                                                          // Close the modal and the preview screen
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                  )),
                                      );
                                    },
                                  ));
                            } catch (e) {
                              print(e);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Lottie.asset(
                                            //     'assets/success.json'),

                                            Text(
                                                'File failed to be uploaded: $e'),

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
                                        )),
                                  );
                                },
                              );
                            }
                          });
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
    final scrollCtrl1 = ScrollController();

    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child: SizedBox(
                // width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: scrollCtrl1,
                    itemCount: allFileName.length,
                    itemBuilder: (context, index) {
                      return Row(
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
                                  File(allFilePath[index]),
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // 80% of screen width
                                  height: MediaQuery.of(context).size.height *
                                      0.5, // 60% of screen height
                                  fit: BoxFit.cover,
                                )),

                            // child: SizedBox(
                            //   width: MediaQuery.of(context).size.width - 200,
                            //   height: MediaQuery.of(context).size.height - 200,
                            //   child: ListView.builder(
                            //       scrollDirection: Axis.horizontal,
                            //       // controller: scrollCtrl1,
                            //       itemCount: allFileName.length,
                            //       itemBuilder: (context, index) {
                            //         return SizedBox(
                            //           child: ClipRRect(
                            //             borderRadius: BorderRadius.circular(10.0),
                            //             child: Image.file(
                            //               File(allFilePath[index]),
                            //               width: MediaQuery.of(context).size.width *
                            //                   0.8, // 80% of screen width
                            //               height: MediaQuery.of(context).size.height *
                            //                   0.6, // 60% of screen height
                            //               fit: BoxFit.cover,
                            //             ),
                            //           ),
                            //         );
                            //       }),
                            // ),
                          ),
                          spaceHorizontal(20)
                        ],
                      );
                    }),
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

  String _domainName() {
    return 'http://47.250.10.195:3030';
    // return 'http://localhost:8080';
  }

  _insertImage(String imageName, String imagePath, String createdBy) async {
    final url = Uri.parse('${_domainName()}/insert/insert_image');
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image_name": imageName,
          "image_path": imagePath,
          "created_by": createdBy
        }));
  }
}
