import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intraflow/services/firebase/service_account_model.dart';
import 'package:intraflow/utils/helpers/field_validator.dart';

class FirebaseController {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> deleteFolder({
    required String folderPath,
  }) async {
    ListResult result = await _storage.ref(folderPath).listAll();
    for (var item in result.items) {
      await item.delete();
    }
    for (var prefix in result.prefixes) {
      await deleteFolder(folderPath: prefix.fullPath);
    }
  }

  String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Por favor, preencha o campo:';
    }

    final isValid = FieldValidator.validateText(
      value: description.trim(),
      maxLength: 50,
    );

    if (!isValid) {
      return 'Caracteres inválidos no campo:';
    }

    return null;
  }

  bool validateComment({
    required String comment,
  }) {
    if (comment.isEmpty) {
      return true;
    }
    return FieldValidator.validateText(
      value: comment.trim(),
      maxLength: 80,
    );
  }

  Future<ServiceAccountModel> loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/firebase/service_account.json');
    final Map<String, dynamic> data = jsonDecode(response);
    return ServiceAccountModel.fromJson(data);
  }
}
