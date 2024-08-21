//2024-12-31 -> "31/12/2024"
String formatDateToStringShow(DateTime date) {
  final String formattedDate =
      "${date.toString().substring(8, 10)}/${date.toString().substring(5, 7)}/${date.toString().substring(0, 4)}";
  return formattedDate;
}

//"20241231" -> "31/12/2024"
String formatStringOriginStore(String string) {
  final String formattedDate =
      "${string.substring(6, 8)}/${string.substring(4, 6)}/${string.substring(0, 4)}";
  return formattedDate;
}

//2024-12-31 -> "20241231"
String formatDateToStore(DateTime date) {
  final String formattedDate =
      "${date.toString().substring(8, 10)}${date.toString().substring(5, 7)}${date.toString().substring(0, 4)}";
  return formattedDate;
}

//2024-12-31 23:59:59 -> "20241231235959"
String formatDateTimeToStore(DateTime date) {
  final String formattedDate =
      "${date.toString().substring(8, 10)}${date.toString().substring(5, 7)}${date.toString().substring(0, 4)}${date.toString().substring(11, 13)}${date.toString().substring(14, 16)}${date.toString().substring(17, 19)}";
  return formattedDate;
}

//"31/12/2024" -> "20241231"
String formatStringToStore(String string) {
  final String formattedDate =
      "${string.toString().substring(6, 10)}${string.toString().substring(3, 5)}${string.toString().substring(0, 2)}";
  return formattedDate;
}

// retorna a date somado o mes com o valor informado
DateTime dateNowAddOneMonth() {
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  if (day == 31) {
    day = 30;
  }
  if (month == 1 && day > 28) {
    day = 28;
  }
  final DateTime date = DateTime(year, month + 1, day);
  return date;
}

// retorna a date somado 1 mes no formato YYYYMMDD
String dateAddMonth(String vencimentoOld) {
  int ano = int.parse(vencimentoOld.substring(0, 4));
  int mes = int.parse(vencimentoOld.substring(4, 6));
  int dia = int.parse(vencimentoOld.substring(6, 8));

  if (dia == 31) {
    dia = 30;
  }
  if (mes == 1 && dia > 28) {
    dia = 28;
  }

  final DateTime date = DateTime(ano, mes + 1, dia);

  return date.toString().replaceAll('-', '').substring(0, 8);
}

// "YYYYMMDD" -> YYYYMMDDHHMMSSS
DateTime dateStringToDateTime(String value) {
  int ano = int.parse(value.substring(0, 4));
  int mes = int.parse(value.substring(4, 6));
  int dia = int.parse(value.substring(6, 8));
  return DateTime(ano, mes, dia);
}

//"20241231235959" -> "23:59"
String formatStringEntrada(String string) {
  final String formattedDate =
      "${string.substring(8, 10)}:${string.substring(10, 12)}";
  return formattedDate;
}

//retorna true caso tiver em dia a mensalidade ou na data de pagamento
bool mensalidadeEmDia(String vencimento) {
  final DateTime validade = DateTime(
    int.parse(vencimento.substring(0, 4)),
    int.parse(vencimento.substring(4, 6)),
    int.parse(vencimento.substring(6, 8)),
  );
  final int duracao = validade.difference(DateTime.now()).inDays;
  if (duracao >= 0) {
    return true;
  }
  return false;
}

//retorna a duracao entres as duas datas em horas.
String duracao(String date) {
  final DateTime d = DateTime(
    int.parse(date.substring(0, 4)),
    int.parse(date.substring(4, 6)),
    int.parse(date.substring(6, 8)),
    int.parse(date.substring(8, 10)),
    int.parse(date.substring(10, 12)),
  );
  final Duration duracao = DateTime.now().difference(d);

  final List<String> duracaoDiviida = duracao.toString().split(':');

  return '${duracaoDiviida[0].toString().padLeft(2, '0')}:${duracaoDiviida[1].toString().padLeft(2, '0')}';
}

//retorna os dias para o vencimento.
int diasParaVencimento(String vencimento) {
  final DateTime validade = DateTime(
      int.parse(vencimento.substring(0, 4)),
      int.parse(vencimento.substring(4, 6)),
      int.parse(vencimento.substring(6, 8)));
  final DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  return validade.difference(now).inDays;
}
