import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path/path.dart' as path;

abstract class DownloadService {
  Future<Map<String, dynamic>> download({required String url});
}

class WebDownloadService implements DownloadService {
  @override
  Future<Map<String, dynamic>> download({required String url}) async {
    try {
      html.window.open(url, "_blank");
      return {"message": "success"};
    } on Exception catch (e) {
      return {"message": e.toString()};
    }
  }
}

class MobileDownloadService implements DownloadService {
  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }

  @override
  Future<Map<String, dynamic>> download({required String url}) async {
    try {
      bool hasPermission = await _requestWritePermission();
      if (!hasPermission) return {"message": "No Permission"};
      final storage = FirebaseStorage.instance;
      final ref = storage.refFromURL(url);
      List<String> refName = ref.name.split(".");
      String fileName =
          "${refName[0]} ${DateTime.now().toString().split(".")[0].replaceAll(":", "-")}.${refName[1]}";
      String downloadPath = (await DownloadsPath.downloadsDirectory())?.path ??
          "/storage/emulated/0/Download";

      final filePath = path.join(downloadPath, fileName);
      final file = File(filePath);
      await ref.writeToFile(file);
      return {"message": "success", "object": filePath};
    } on Exception catch (e) {
      return {"message": e.toString()};
    }
  }
}
