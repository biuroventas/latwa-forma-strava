// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data' show Uint8List;

/// Na webie: zapisuje [bytes] do pliku [fileName] przez pobranie (blob URL + klik w link).
Future<void> downloadBytesAsFile(
  List<int> bytes,
  String fileName, {
  String mimeType = 'application/pdf',
}) async {
  final list = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = html.Blob([list], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Odroczenie revoke – daj przeglądarce czas na rozpoczęcie pobierania (Safari/Chrome)
  Future.delayed(const Duration(milliseconds: 500), () {
    html.Url.revokeObjectUrl(url);
  });
}
