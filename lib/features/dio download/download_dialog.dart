import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class DownloadDialog extends StatefulWidget {
  DownloadDialog({super.key, required this.url});

  String url;

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  Dio dio = Dio();
  double progress = 0.0;
  @override
  void initState() {
    log('download called');
    startDownloading();
    super.initState();
  }

  void startDownloading() async {
    String path = await getFilePath();

    await dio.download(
      widget.url,
      path,
      onReceiveProgress: (received, total) {
        setState(() {
          progress = received / total;
        });
      },
      deleteOnError: true,
    ).then((value) => Navigator.pop(context));
  }

  Future<String> getFilePath() async {
    final directory = await getExternalStorageDirectory();
    log(directory!.path);
    return '${directory.path}/hello.jpg';
  }

  @override
  Widget build(BuildContext context) {
    String downloadProgress = (progress * 100).toInt().toString();
    return AlertDialog(
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Downloading: $downloadProgress%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
