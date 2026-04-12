import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileManager {
  Future<String> open_file() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'java', 'lya']
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      return await file.readAsString();
    }
    return '';
  }
}