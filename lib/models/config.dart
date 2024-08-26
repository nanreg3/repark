import 'package:cloud_firestore/cloud_firestore.dart';

class Config {
  dynamic valorDia = 0;
  dynamic valorHora = 0;
  dynamic valorHoraAdd = 0;
  dynamic valorMeiaHora = 0;
  dynamic qtdDiasAviso = 0;
  String msg = '';
  String nomeLoja = '';
  String rodape = '';

  Config({
    this.valorDia,
    this.valorHora,
    this.valorHoraAdd,
    this.valorMeiaHora,
    this.qtdDiasAviso,
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
      valorDia: data?['valorDia'],
      valorHora: data?['valorHora'],
      valorHoraAdd: data?['valorHoraAdd'],
      valorMeiaHora: data?['valorMeiaHora'],
      qtdDiasAviso: data?['qtdDiasAviso'],
      msg: data?['msg'],
      nomeLoja: data?['nomeLoja'],
      rodape: data?['rodape'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (valorDia != null) "valorDia": valorDia,
      if (valorHora != null) "valorHora": valorHora,
      if (valorHoraAdd != null) "valorHoraAdd": valorHoraAdd,
      if (valorMeiaHora != null) "valorMeiaHora": valorMeiaHora,
      if (qtdDiasAviso != null) "qtdDiasAviso": qtdDiasAviso,
      if (msg.isNotEmpty) "msg": msg,
      if (nomeLoja.isNotEmpty) "nomeLoja": nomeLoja,
      if (rodape.isNotEmpty) "nomeLoja": rodape,
    };
  }
}
