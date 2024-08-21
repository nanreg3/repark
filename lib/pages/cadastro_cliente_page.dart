import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/models/cliente.dart';

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<CadastroClientePage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroClientePage> {
  late TextEditingController nome = TextEditingController();
  late TextEditingController celular = TextEditingController();
  late TextEditingController email = TextEditingController();
  late TextEditingController veiculo = TextEditingController();
  late TextEditingController placa = TextEditingController();
  late TextEditingController modelo = TextEditingController();
  late TextEditingController cor = TextEditingController();
  late TextEditingController valor = TextEditingController();
  late TextEditingController avisos = TextEditingController();
  late TextEditingController obs = TextEditingController();
  late TextEditingController vencimento = TextEditingController();
  bool ativo = true;
  String? errorNome;
  String? errorValor;
  String? id;
  List<String> tiposVeiculo = ['Carro', 'Moto', 'Bicicleta'];

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.cliente != null
          ? dateStringToDateTime(widget.cliente!.vencimento)
          : dateNowAddOneMonth(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        vencimento.text = formatDateToStringShow(picked);
      });
    }
  }

  void salvarCliente() {
    if (nome.text.isEmpty) {
      setState(() {
        errorNome = 'Campo obrigatório';
      });
    } else if (valor.text.isEmpty || valor.text == '0') {
      setState(() {
        errorValor = 'Campo obrigatório';
      });
    } else {
      final cliente = {
        "nome": nome.text.toUpperCase(),
        "ativo": ativo,
        "avisos": avisos.text == "" ? 0 : int.parse(avisos.text),
        "celular": celular.text,
        "email": email.text,
        "vencimento": formatStringToStore(vencimento.text),
        "valor": double.parse(valor.text),
        "veiculo": veiculo.text,
        "modelo": modelo.text.toUpperCase(),
        "cor": cor.text.toUpperCase(),
        "placa": placa.text.toUpperCase(),
        "obs": obs.text,
      };
      final firestore = FirebaseFirestore.instance
          .collection('estacionamentos/djalma/clientes');
      try {
        if (id != null) {
          firestore.doc(id).update(cliente);
          const snackBar = SnackBar(
            duration: Durations.medium3,
            content: Text("Dados alterados com sucesso!"),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          firestore.add(cliente);
          const snackBar = SnackBar(
            duration: Durations.medium3,
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
  }

  void removerCliente() {
    final firestore = FirebaseFirestore.instance
        .collection('estacionamentos/djalma/clientes');
    try {
      firestore.doc(id).delete();
      const SnackBar(content: Text("Dados removidos com sucesso!"));
      Navigator.pop(context);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      id = widget.cliente!.id;
      nome.text = widget.cliente!.nome;
      ativo = widget.cliente!.ativo;
      celular.text = widget.cliente!.celular;
      email.text = widget.cliente!.email;
      veiculo.text = widget.cliente!.veiculo;
      placa.text = widget.cliente!.placa;
      modelo.text = widget.cliente!.modelo;
      cor.text = widget.cliente!.cor;
      vencimento.text = formatStringOriginStore(widget.cliente!.vencimento);
      valor.text = widget.cliente!.valor.toString();
      avisos.text = widget.cliente!.avisos.toString();
      obs.text = widget.cliente!.obs;
    } else {
      valor.text = "";
      vencimento.text = formatDateToStringShow(dateNowAddOneMonth());
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
        title: const Text("Cadastro de Cliente"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Dados principais:'),
                const SizedBox(height: 5),
                TextField(
                  controller: nome,
                  decoration: InputDecoration(
                    labelText: "Nome:",
                    border: const OutlineInputBorder(),
                    errorText: errorNome,
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: celular,
                        decoration: const InputDecoration(
                          labelText: "Celular:",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Checkbox(
                        value: ativo,
                        onChanged: (bool? value) {
                          setState(() {
                            ativo = value ?? false;
                          });
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text("Ativo"),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: "e-mail:",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                const Text('Veículo:'),
                const SizedBox(height: 5),
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
                const SizedBox(height: 10),
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
                const SizedBox(height: 15),
                const Text('Mensalidade atual:'),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: vencimento,
                        readOnly: true,
                        onTap: () {
                          selectDate(context);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Prox. Vencimento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: valor,
                        decoration: InputDecoration(
                          labelText: "Valor:",
                          border: const OutlineInputBorder(),
                          errorText: errorValor,
                          prefixText: 'R\$: ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        if (widget.cliente != null)
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
                          widget.cliente!.nome,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(widget.cliente!.modelo),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                removerCliente();
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Remover'),
                                  SizedBox(width: 6),
                                  Icon(Icons.person_remove, color: Colors.red),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
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
                                      color: Color.fromARGB(255, 10, 189, 16)),
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
            salvarCliente();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 25),
          ),
          child: Icon(
            widget.cliente == null ? Icons.person_add : Icons.check,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 2),
      ],
    );
  }
}
