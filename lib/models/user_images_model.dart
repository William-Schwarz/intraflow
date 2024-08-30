import 'package:firebase_storage/firebase_storage.dart';

class UserImagesModel {
  String url;
  String name;
  String size;
  Reference ref;

  UserImagesModel({
    required this.url,
    required this.name,
    required this.size,
    required this.ref,
  });

  factory UserImagesModel.fromStorageReference(Reference ref) {
    return UserImagesModel(
      url: '',
      name: ref.name,
      size: '',
      ref: ref,
    );
  }
}
