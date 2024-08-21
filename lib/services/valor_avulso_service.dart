import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:repark/models/config.dart';

final firestore =
    FirebaseFirestore.instance.collection('estacionamentos/djalma/configs');

//retorna o valor total a pagar
Future<String?> valorAvulso(String entrada) async {
  final ref = firestore.doc('config').withConverter(
      fromFirestore: Config.fromFirestore,
      toFirestore: (Config config, _) => config.toFirestore());

  final docSnap = await ref.get();

  if (docSnap.exists) {
    final config = docSnap.data();

    final DateTime e = DateTime(
      int.parse(entrada.substring(0, 4)),
      int.parse(entrada.substring(4, 6)),
      int.parse(entrada.substring(6, 8)),
      int.parse(entrada.substring(8, 10)),
      int.parse(entrada.substring(10, 12)),
    );
    final Duration duracao = DateTime.now().difference(e);
    final List<String> duracaoDiviida = duracao.toString().split(':');
    int horas = int.parse(duracaoDiviida[0]);
    int minutos = int.parse(duracaoDiviida[1]);
    double valorAPagar = 0;
    final dynamic valorHora = config?.valorHora;
    final dynamic valorHoraAdd = config?.valorHoraAdd;
    final dynamic valorMeiaHora = config?.valorMeiaHora;

    if (horas == 0 && minutos <= 30 && valorMeiaHora > 0) {
      valorAPagar = valorMeiaHora;
    } else if (horas == 0) {
      valorAPagar = valorHora;
    } else if (horas == 1 && minutos == 0) {
      valorAPagar = valorHora;
    } else if (horas == 1) {
      valorAPagar = valorHora + valorHoraAdd;
    } else {
      double horasAdd = horas - 1;
      double valorAdd = valorHoraAdd * horasAdd;
      valorAPagar = valorHora;
      valorAPagar += valorAdd;
    }
    return valorAPagar.toStringAsFixed(2).replaceAll('.', ',');
  }
  return null;
}

//retorna as configurações gravadas no banco
Future<Config?> getConfig() async {
  final ref = firestore.doc('config').withConverter(
      fromFirestore: Config.fromFirestore,
      toFirestore: (Config config, _) => config.toFirestore());

  final docSnap = await ref.get();

  if (docSnap.exists) {
    return docSnap.data()!;
  }
  return null;
}
