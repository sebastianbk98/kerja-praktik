import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

abstract class DownloadService {
  Future<String> download({required String url});
}

class WebDownloadService implements DownloadService {
  @override
  Future<String> download({required String url}) async {
    try {
      html.window.open(url, "_blank");
      return 'success';
    } on Exception catch (e) {
      return e.toString();
    }
  }
}

class MobileDownloadService implements DownloadService {
  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }

  @override
  Future<String> download({required String url}) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    try {
      if (statuses[Permission.storage]!.isGranted) {
        bool hasPermission = await _requestWritePermission();
        if (!hasPermission) return "No Permission";
        final storage = FirebaseStorage.instance;
        final ref = storage.refFromURL(url);

        final filePath = "/storage/emulated/0/Download/${ref.name}";
        final file = File(filePath);

        final downloadTask = ref.writeToFile(file);
        String flag = '';
        downloadTask.snapshotEvents.listen((taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
              break;
            case TaskState.paused:
              break;
            case TaskState.success:
              flag = "success";
              break;
            case TaskState.canceled:
              break;
            case TaskState.error:
              flag = TaskState.error.name;
              break;
          }
        });
        return flag;
      }
      return "No Permission";
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
