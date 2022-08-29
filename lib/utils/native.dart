import 'dart:io';

import 'package:path_provider/path_provider.dart';

//this function assumes that necessary permissions required for accessing file storage have been approved by user;
Future<String?> downloadFile (bytes, filename) async {
  try {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = "${dir.path}/$filename";
    File file = await File(filePath).create();
    await file.writeAsBytes(bytes);
    print("saved file to $file");
    return file.path;
  }
  catch (e) {
    print(e);
  }

  return null;
}