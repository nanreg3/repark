import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/config.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late TextEditingController valorDia = TextEditingController();
  late TextEditingController valorHora = TextEditingController();
  late TextEditingController valorHoraAdd = TextEditingController();
  late TextEditingController valorMeiaHora = TextEditingController();
  late TextEditingController qtdDiasAviso = TextEditingController();
  late TextEditingController msg = TextEditingController();
  late TextEditingController nomeLoja = TextEditingController();
  late TextEditingController rodape = TextEditingController();

  final firestore =
      FirebaseFirestore.instance.collection('estacionamentos/djalma/configs');

  void salvarConfig() {
    final config = {
      "valorDia": valorDia.text != ''
          ? double.tryParse(valorDia.text.replaceAll(',', '.'))
          : 0,
      "valorHora": valorHora.text != ''
          ? double.tryParse(valorHora.text.replaceAll(',', '.'))
          : 0,
      "valorHoraAdd": valorHoraAdd.text != ''
          ? double.tryParse(valorHoraAdd.text.replaceAll(',', '.'))
          : 0,
      "valorMeiaHora": valorMeiaHora.text != ''
          ? double.tryParse(valorMeiaHora.text.replaceAll(',', '.'))
          : 0,
      "qtdDiasAviso":
          qtdDiasAviso.text != '' ? double.tryParse(qtdDiasAviso.text) : 0,
      "msg": msg.text,
      "nomeLoja": nomeLoja.text,
      "rodape": rodape.text,
    };

    try {
      firestore.doc('config').set(config);
      const snackBar = SnackBar(
        duration: Durations.medium3,
        content: Text("Dados salvos com sucesso!"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
  }

  @override
  void initState() {
    super.initState();
    getConfig();
  }

  bool isLoading = true;

  Future<void> getConfig() async {
    final ref = firestore.doc('config').withConverter(
        fromFirestore: Config.fromFirestore,
        toFirestore: (Config config, _) => config.toFirestore());

    final docSnap = await ref.get();
    final config = docSnap.data();
    if (config!.valorDia != null) {
      valorDia.text = config.valorDia.toStringAsFixed(2).replaceAll('.', ',');
    }
    if (config.valorHora != null) {
      valorHora.text = config.valorHora.toStringAsFixed(2).replaceAll('.', ',');
    }
    if (config.valorHoraAdd != null) {
      valorHoraAdd.text =
          config.valorHoraAdd.toStringAsFixed(2).replaceAll('.', ',');
    }
    if (config.valorMeiaHora != null) {
      valorMeiaHora.text =
          config.valorMeiaHora.toStringAsFixed(2).replaceAll('.', ',');
    }
    // if (config.qtdDiasAviso != null) {
    //   qtdDiasAviso.text = config.qtdDiasAviso;
    // }
    msg.text = config.msg;
    nomeLoja.text = config.nomeLoja;
    rodape.text = config.rodape;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: valorDia,
                              decoration: const InputDecoration(
                                labelText: "Valor da diária:",
                                border: OutlineInputBorder(),
                                prefixText: 'R\$: ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      // const Text(
                      //   'Obs.: Deixe o valor 0 (zero) caso não queira calcular dia.',
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextField(
                      //         controller: valorHora,
                      //         decoration: const InputDecoration(
                      //           labelText: "Valor da Hora:",
                      //           border: OutlineInputBorder(),
                      //           prefixText: 'R\$: ',
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextField(
                      //         controller: valorHoraAdd,
                      //         decoration: const InputDecoration(
                      //           labelText: "Valor Hora adicional:",
                      //           border: OutlineInputBorder(),
                      //           prefixText: 'R\$: ',
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextField(
                      //         controller: valorMeiaHora,
                      //         decoration: const InputDecoration(
                      //           labelText: "Valor meia Hora:",
                      //           border: OutlineInputBorder(),
                      //           prefixText: 'R\$: ',
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const Text(
                      //   'Obs.: Deixe o valor 0 (zero) caso não queira calcular meia hora.',
                      //   style: TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nomeLoja,
                              decoration: const InputDecoration(
                                labelText: "Nome do estacionamento:",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Obs.: Esse nome será exibido no ticket avulso.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: rodape,
                              decoration: const InputDecoration(
                                labelText: "Mensagem do ticket:",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Obs.: Essa mensagem será exibida no final do ticket avulso.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: msg,
                              decoration: const InputDecoration(
                                labelText: "Mensagem Wpp:",
                                border: OutlineInputBorder(),
                              ),
                              minLines: 7,
                              maxLines: 50,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          salvarConfig();
        },
        tooltip: 'Salvar',
        backgroundColor: Colors.green,
        heroTag: 'btnConfig',
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
    );
  }
}
