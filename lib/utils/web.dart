import 'dart:convert';
import 'dart:html';

//this function assumes that necessary permissions required for accessing file storage have been approved by user;
Future<String?> downloadFile (bytes, filename) async {
  try {
    final base64 = base64Encode(bytes);
    // Create the link with the file
    final anchor = AnchorElement(href: 'data:application/octet-stream;base64,$base64')
      ..target = 'blank';

    anchor.download = filename;

    document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // there's no concept of file path when it comes to web
    return "";
  }
  catch (e) {
    print(e);
  }

  return null;
}