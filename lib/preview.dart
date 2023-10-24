// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_oss_aliyun/flutter_oss_aliyun.dart';
import 'util.dart';
import 'message.dart';

final myFormat = DateFormat.yMd().add_Hms();

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
    final truePath = 'folder-aiman/$fileName';
    await Client().putObject(
      fileBytes,
      truePath,
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

    final String fileUrl = await Client().getSignedUrl(truePath);
    _insertImage(fileName, fileUrl, 'imran-debug');

    // final dynamic fileMetadata = await Client().getObjectMeta(truePath);
    // print('SEE HERE: \n\n${fileUrl.substring(0, fileUrl.indexOf('?'))}\n\n');
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
                      showMessage(
                          context, 'File uploaded into OSS and PostgreSQL.');
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
