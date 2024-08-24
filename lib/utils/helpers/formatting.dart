class Formatter {
  // Formata a data no formato dd/MM/yyyy
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formata uma string de data e hora no formato dd/MM/yyyy HH:mm:ss
  static String formatDateTime(String dateTimeString) {
    // Remove o sufixo ".png" da string, se existir
    dateTimeString = dateTimeString.replaceAll('.png', '');

    DateTime? dateTime = DateTime.tryParse(dateTimeString);
    if (dateTime != null) {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } else {
      return '';
    }
  }
}
