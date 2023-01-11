import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadingService {
  static const downloadingPortName = 'downloading';

  static Future<void> createDownloadTask(String url) async {
    final storagePermission = await _permissionGranted();

    if (!storagePermission) {
      await Permission.storage.request();
    } else {
      final path = await _getPath();

      final taskId = await FlutterDownloader.enqueue(
          url: url,
          savedDir: path.toString(),
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

  static Future<bool> _permissionGranted() async {
    return await Permission.storage.isGranted;
  }

  static Future<String?> _getPath() async {
    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      log('${externalDir?.path}');
      return externalDir?.path;
    }

    return (await getApplicationDocumentsDirectory()).absolute.path;
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
