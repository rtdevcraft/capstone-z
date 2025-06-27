import 'dart:convert';
import 'package:universal_html/html.dart' as html;

void triggerWebDownload(String csvData, String fileName) {
  // 1. Encode the string data to a Uint8List
  final bytes = utf8.encode(csvData);
  
  // 2. Create a Blob from the bytes
  final blob = html.Blob([bytes]);
  
  // 3. Create an object URL from the Blob
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // 4. Create an anchor element (<a>)
  html.AnchorElement(href: url)
    ..setAttribute("download", fileName) // Set the desired file name
    ..click(); // 5. Programmatically click the anchor to trigger the download
  
  // 6. Revoke the object URL to free up memory
  html.Url.revokeObjectUrl(url);
}