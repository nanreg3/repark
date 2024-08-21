import 'package:cloud_firestore/cloud_firestore.dart';

class Avulso {
  String category = '';
  String id = '';
  //ticket
  String entrada = '';
  String saida = '';
  dynamic valor = 0.00;
  // veiculo
  String veiculo = '';
  String modelo = '';
  String cor = '';
  String placa = '';

  String obs = '';

  Avulso.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.id;
    entrada = snapshot.get('entrada');
    saida = snapshot.get('saida');
    valor = snapshot.get('valor');
    veiculo = snapshot.get('veiculo');
    veiculo = snapshot.get('veiculo');
    modelo = snapshot.get('modelo');
    cor = snapshot.get('cor');
    placa = snapshot.get('placa');
    obs = snapshot.get('obs');
  }
}
