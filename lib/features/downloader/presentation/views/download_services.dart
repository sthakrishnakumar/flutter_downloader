import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:downloader_app/core/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadingService {
  BuildContext? context;
  static const downloadingPortName = 'downloading';

  static Future<void> createDownloadTask(String url) async {
    final isGranted = await Permission.storage.isGranted;
    final deniedPermanently =
        await Permission.storage.request().isPermanentlyDenied;

    if (!isGranted) {
      if (deniedPermanently) {
        snackbar(title: 'Permission Denied Permanently');
        showDialog<String>(
          context: globalContext,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Allow app to access your storage?'),
            content: const Text(
                'You need to allow storage access from the app setting.'),
            actions: <Widget>[
              // if user deny again, we do nothing
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Don\'t allow'),
              ),

              // if user is agree, you can redirect him to the app parameters :)
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Allow'),
              ),
            ],
          ),
        );
        return;
      } else {
        snackbar(title: 'Permission Denied');
      }
    } else {
      final path = await _getPath();

      final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: path,
          showNotification: true,
          // show download progress in status bar (for Android)
          openFileFromNotification: true,
          // click on notification to open downloaded file (for Android)
          saveInPublicStorage: true);

      await Future.delayed(const Duration(seconds: 1));

      if (taskId != null) {
        await FlutterDownloader.open(taskId: taskId);
      }
    }
  }

  // static Future<bool> _permissionGranted() async {
  //   return await Permission.storage.isGranted;
  // }

  // static Future<bool> isPermanentltyDenied() async {
  //   return await Permission.storage.request().isPermanentlyDenied;
  // }

  static Future<String> _getPath() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      log(externalDir!.path.toString());
      return externalDir.path;
    }

    return (await getExternalStorageDirectory())!.path;
  }

  static downloadingCallBack(id, status, progress) {
    final sendPort = IsolateNameServer.lookupPortByName(downloadingPortName);

    if (sendPort != null) {
      sendPort.send([id, status, progress]);
    }
    //  else {
    //   Fimber.e('SendPort is null. Cannot find isolate $downloadingPortName');
    // }
  }
}
