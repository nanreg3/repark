import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  String category = '';
  // dados principais
  String id = '';
  String nome = '';
  bool ativo = true;
  int avisos = 0;
  String celular = '';
  String email = '';
  // mensalidade atual
  String vencimento = '';
  dynamic valor = 0;
  // veiculo
  String veiculo = '';
  String modelo = '';
  String cor = '';
  String placa = '';

  String obs = '';

  Cliente.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.id;
    ativo = snapshot.get('ativo');
    nome = snapshot.get('nome');
    celular = snapshot.get('celular');
    email = snapshot.get('email');
    avisos = snapshot.get('avisos');
    vencimento = snapshot.get('vencimento');
    valor = snapshot.get('valor');
    veiculo = snapshot.get('veiculo');
    modelo = snapshot.get('modelo');
    cor = snapshot.get('cor');
    placa = snapshot.get('placa');
    obs = snapshot.get('obs');
  }
}
