import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:downloader_app/features/downloader/presentation/views/download_services.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _receivePort = ReceivePort();

  late TextEditingController urlController;
  final GlobalKey<FormState> formkey = GlobalKey();

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController();
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, DownloadingService.downloadingPortName);
    FlutterDownloader.registerCallback(DownloadingService.downloadingCallBack);
    _receivePort.listen((message) {
      Fimber.d('Got message from port: $message');
    });
  }

  @override
  void dispose() {
    _receivePort.close();
    super.dispose();
  }

  void downloadFile(String url) async {
    try {
      await DownloadingService.createDownloadTask(url);
    } catch (e) {
      log("error");
    }
  }

  String url =
      'https://www.shutterstock.com/shutterstock/videos/1063563805/preview/stock-footage-snow-and-sleet-falling-on-a-window-at-christmas-time-with-rain-drops-cold-wet-weather-on-window.webm';
  String pdfUrl = 'https://www.africau.edu/images/default/sample.pdf';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hello'),
      ),
      body: Center(
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Note:\nYoutube Videos Cannot be Downloaded',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(hintText: 'Enter Url'),
                  validator: (value) {
                    return value!.isEmpty
                        ? "Please Enter Url to Download"
                        : null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      log('pre download');
                      downloadFile(urlController.text);
                      log('download');
                    }
                  },
                  child: const Text('Download'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
