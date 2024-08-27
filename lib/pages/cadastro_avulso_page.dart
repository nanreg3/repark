import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/ticket.dart';
import 'package:repark/pages/ticket_page.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/models/avulso.dart';
import 'package:repark/services/valor_avulso_service.dart';

class CadastroAvulsoPage extends StatefulWidget {
  const CadastroAvulsoPage({super.key, this.avulso});

  final Avulso? avulso;

  @override
  State<CadastroAvulsoPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroAvulsoPage> {
  late TextEditingController veiculo = TextEditingController();
  late TextEditingController placa = TextEditingController();
  late TextEditingController modelo = TextEditingController();
  late TextEditingController cor = TextEditingController();
  late TextEditingController obs = TextEditingController();
  final String entrada = DateTime.now()
      .toString()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .replaceAll(' ', '')
      .substring(0, 14);
  String? id;
  List<String> tiposVeiculo = ['Carro', 'Moto', 'Bicicleta'];

  void salvarAvulso() {
    final avulso = {
      "entrada": widget.avulso != null ? widget.avulso?.entrada : entrada,
      "saida": "",
      "valor": 0,
      "veiculo": veiculo.text,
      "modelo": modelo.text.toUpperCase(),
      "cor": cor.text.toUpperCase(),
      "placa": placa.text.toUpperCase(),
      "obs": obs.text,
      "impresso": false,
    };
    final firestore =
        FirebaseFirestore.instance.collection('estacionamentos/djalma/avulsos');
    try {
      if (id != null) {
        firestore.doc(id).update(avulso);
        const snackBar = SnackBar(
          content: Text("Dados alterados com sucesso!"),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        firestore.add(avulso);
        const snackBar = SnackBar(
          content: Text("Dados gravados com sucesso!"),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      Navigator.pop(context);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
  }

  void removerAvulso() {
    final firestore =
        FirebaseFirestore.instance.collection('estacionamentos/djalma/avulsos');
    try {
      firestore.doc(id).delete();
      const SnackBar(content: Text("Dados removidos com sucesso!"));
      Navigator.pop(context);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
  }

  final Ticket ticket = Ticket();

  @override
  void initState() {
    super.initState();
    if (widget.avulso != null) {
      id = widget.avulso!.id;
      veiculo.text = widget.avulso!.veiculo;
      placa.text = widget.avulso!.placa;
      modelo.text = widget.avulso!.modelo;
      cor.text = widget.avulso!.cor;
      obs.text = widget.avulso!.obs;

      ticket.saida =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      ticket.entrada = formatStringEntrada(widget.avulso!.entrada);
      ticket.permanencia = duracao(widget.avulso!.entrada);
      // valorAvulso(widget.avulso!.entrada).then((value) => {
      //       if (value != null)
      //         setState(() {
      //           ticket.valor = value;
      //         })
      //     });
      getConfig().then((value) {
        setState(() {
          ticket.valor = value!.valorDia
              .toStringAsFixed(2)
              .toString()
              .replaceAll('.', ',');
        });
      });
    }
    if (veiculo.text == "") {
      veiculo.text = "Carro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Cadastro de Avulso"),
      ),
      body: SingleChildScrollView(
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
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: veiculo.text,
                            decoration: const InputDecoration(
                              labelText: "Tipo:",
                              border: OutlineInputBorder(),
                            ),
                            items: tiposVeiculo.map((String opcao) {
                              return DropdownMenuItem(
                                value: opcao,
                                child: Text(opcao),
                              );
                            }).toList(),
                            onChanged: (String? opcaoSelecionada) {
                              setState(() {
                                veiculo.text = opcaoSelecionada.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: modelo,
                        decoration: const InputDecoration(
                          labelText: "Modelo:",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: placa,
                        decoration: const InputDecoration(
                          labelText: "Placa:",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: cor,
                        decoration: const InputDecoration(
                          labelText: "Cor:",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: obs,
                        decoration: const InputDecoration(
                          labelText: "Obs.:",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.avulso != null) const SizedBox(height: 35),
                if (widget.avulso != null)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Entrada: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            ticket.entrada,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Permanência: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            ticket.permanencia,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Valor ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            'R\$: ${widget.avulso!.saida == '' ? ticket.valor : widget.avulso!.valor}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        if (widget.avulso != null)
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close)),
                          ],
                        ),
                        Text(
                          widget.avulso!.modelo,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(widget.avulso!.placa),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.avulso!.id == '')
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  removerAvulso();
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Remover'),
                                    SizedBox(width: 6),
                                    Icon(Icons.person_remove,
                                        color: Colors.red),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 20),
                            if (widget.avulso!.id == '')
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Voltar'),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_back,
                                        color:
                                            Color.fromARGB(255, 10, 189, 16)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 25),
            ),
            child: const Icon(
              Icons.person_remove,
              color: Colors.white,
            ),
          ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            salvarAvulso();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 25),
          ),
          child: Icon(
            widget.avulso == null ? Icons.add_circle : Icons.check,
            color: Colors.white,
          ),
        ),
        if (widget.avulso != null) const SizedBox(width: 10),
        if (widget.avulso != null)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TicketPage(
                          ticket: ticket,
                          avulso: widget.avulso!,
                        )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 25),
            ),
            child: const Icon(Icons.print, color: Colors.white),
          ),
        const SizedBox(width: 2),
      ],
    );
  }
}
