// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

//basic library
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

//for client connection library
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';

//misc
import 'util.dart';
import 'message.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Uint8List fileBytes;
  final String fileName;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    required this.fileBytes,
    required this.fileName,
  });

  Future uploadFile() async {
    await Client().putObject(
      fileBytes,
      fileName,
      option: PutRequestOption(
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

  @override
  Widget build(BuildContext context) {
    // print(imagePath.toString());
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 0.1,
              maxScale: 10,
              child: Image.file(File(imagePath))),
          spaceVertical(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    try {
                      uploadFile();
                      showMessage(context, 'File uploaded into OSS.');
                      Navigator.of(context).pop();
                    } catch (e) {
                      showMessage(context, e.toString());
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Continue and Upload')),
              spaceHorizontal(15),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
            ],
          )
        ],
      )),
    );
  }
}
