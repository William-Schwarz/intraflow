import 'dart:io';
import 'dart:typed_data';

class InfoFilesModel {
  String name;
  int size;
  String extension;
  Uint8List bytes;
  File? file;
  InfoFilesModel({
    required this.name,
    required this.size,
    required this.extension,
    required this.bytes,
    this.file,
  });
}
