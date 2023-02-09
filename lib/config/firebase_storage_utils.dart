import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageServices {
  final storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> uploadFile(
      String reference, Uint8List file, String contentType) async {
    String fileUrl = '';
    try {
      Reference ref = storage.ref().child(reference);
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(file, metadata);
      fileUrl = await ref.getDownloadURL();
    } catch (e) {
      return {"message": e.toString()};
    }
    return {
      "message": "success",
      "object": fileUrl,
    };
  }

  Future<Map<String, dynamic>> uploadFiles(List<String> references,
      List<Uint8List> files, String contentType) async {
    List<String> fileUrl = [];
    try {
      for (var i = 0; i < references.length; i++) {
        Reference ref = storage.ref().child(references[i]);
        final metadata = SettableMetadata(contentType: contentType);
        await ref.putData(files[i], metadata);
        fileUrl.add(await ref.getDownloadURL());
      }
    } catch (e) {
      return {"message": e.toString()};
    }
    return {
      "message": "success",
      "object": fileUrl,
    };
  }
}
