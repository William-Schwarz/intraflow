class FieldValidator {
  static bool validateText({
    required String value,
    int? maxLength,
  }) {
    if (maxLength != null && value.length > maxLength) {
      // Verifica se o comprimento é maior que o máximo permitido
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9À-ÿ\s\-(),;%!?°/]+$').hasMatch(value)) {
      // Verifica se a string contém apenas letras, números, espaços, caracteres acentuados e os caracteres '-', '(', ')', ',' e ';'
      return false;
    }
    return true;
  }

  static bool validateEmail({
    required String value,
  }) {
    // Use uma expressão regular para validar o formato do email
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  static bool validatePassword({
    required String value,
  }) {
    // Não permitir senha que contenha os caracteres especiais e nenhum caractere de acentuação
    return value.length >= 6 &&
        !value.contains('%') &&
        !value.contains(',') &&
        !value.contains(';') &&
        !value.contains('&') &&
        !value.contains('*') &&
        !value.contains('#') &&
        !value.contains('"') &&
        !value.contains('(') &&
        !value.contains(')') &&
        !value.contains('-') &&
        !RegExp(r'[À-ÿ]').hasMatch(value);
  }

  static bool validateName({
    required String value,
  }) {
    return RegExp(r'^\S+\s+\S+').hasMatch(value);
  }
}
