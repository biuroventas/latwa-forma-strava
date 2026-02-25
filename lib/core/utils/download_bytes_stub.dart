/// Na platformach innych niż web nie używamy pobierania przez blob.
Future<void> downloadBytesAsFile(
  List<int> bytes,
  String fileName, {
  String mimeType = 'application/pdf',
}) async {
  throw UnsupportedError('downloadBytesAsFile is only supported on web');
}
