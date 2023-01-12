import 'package:downloader_app/core/commons.dart';
import 'package:downloader_app/features/dio%20download/download_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class DioDownloadPage extends StatefulWidget {
  const DioDownloadPage({super.key});

  @override
  State<DioDownloadPage> createState() => _DioDownloadPageState();
}

class _DioDownloadPageState extends State<DioDownloadPage> {
  askPermission() async {
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
      if (formkey.currentState!.validate()) {
        showDialog(
          context: context,
          builder: (context) => DownloadDialog(url: urlController.text),
        );
      }
    }
  }

  late TextEditingController urlController;

  final GlobalKey<FormState> formkey = GlobalKey();
  @override
  void initState() {
    urlController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio Download'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await askPermission();
        },
        child: const Icon(Icons.download),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
