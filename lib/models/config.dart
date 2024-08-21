import 'package:cloud_firestore/cloud_firestore.dart';

class Config {
  dynamic valorHora = 0;
  dynamic valorHoraAdd = 0;
  dynamic valorMeiaHora = 0;
  String msg = '';
  String nomeLoja = '';
  String rodape = '';

  Config({
    this.valorHora,
    this.valorHoraAdd,
    this.valorMeiaHora,
    required this.msg,
    required this.nomeLoja,
    required this.rodape,
  });

  factory Config.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Config(
      valorHora: data?['valorHora'],
      valorHoraAdd: data?['valorHoraAdd'],
      valorMeiaHora: data?['valorMeiaHora'],
      msg: data?['msg'],
      nomeLoja: data?['nomeLoja'],
      rodape: data?['rodape'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (valorHora != null) "valorHora": valorHora,
      if (valorHoraAdd != null) "valorHoraAdd": valorHoraAdd,
      if (valorMeiaHora != null) "valorMeiaHora": valorMeiaHora,
      if (msg.isNotEmpty) "msg": msg,
      if (nomeLoja.isNotEmpty) "nomeLoja": nomeLoja,
      if (rodape.isNotEmpty) "nomeLoja": rodape,
    };
  }
}
