import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/cliente.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/services/valor_avulso_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AvisoPage extends StatefulWidget {
  const AvisoPage({super.key});

  @override
  State<AvisoPage> createState() => _AvisoPageState();
}

class _AvisoPageState extends State<AvisoPage> {
  List<Cliente> atrasados = [];
  List<Cliente> deHoje = [];
  List<Cliente> proximos = [];

  bool isLoading = true;
  bool isInit = true;
  late final String? msg;
  final firestore =
      FirebaseFirestore.instance.collection('estacionamentos/djalma/clientes');

  @override
  void initState() {
    super.initState();
    getClientes();
    getConfig().then((value) {
      msg = value?.msg;
    });
  }

  getClientes() {
    atrasados = [];
    deHoje = [];
    proximos = [];
    firestore.get().then((querySnapshot) {
      setState(() {
        List<DocumentSnapshot> docs =
            querySnapshot.docs as List<DocumentSnapshot<Object?>>;

        if (docs.isNotEmpty) {
          for (var doc in docs) {
            int dias = diasParaVencimento(doc['vencimento']);
            if (doc['ativo']) {
              if (dias < 0) {
                atrasados.add(Cliente.fromDocument(doc));
              } else if (dias == 0) {
                deHoje.add(Cliente.fromDocument(doc));
              } else if (dias > 0 && dias <= 5) {
                proximos.add(Cliente.fromDocument(doc));
              }
            }
          }
        }
        isLoading = false;
      });
    });
  }

  notificar(String phoneNumber, Cliente cliente) async {
    isLoading = true;

    String url = 'https://wa.me/+55$phoneNumber?text=${Uri.parse(msg!)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      isLoading = false;
    }
    atualizarCadastro(cliente, 2);
  }

  void atualizarCadastro(Cliente cliente, int acao) {
    final Map<String, dynamic> c;
    if (acao == 1) {
      c = {
        "vencimento": dateAddMonth(cliente.vencimento),
        "avisos": 0,
      };
    } else {
      c = {"avisos": cliente.avisos += 1};
    }

    try {
      firestore.doc(cliente.id).update(c);
      const snackBar = SnackBar(
        content: Text("Dados alterados com sucesso!"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
    getClientes();
  }

  avisarSemCelular() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cliente sem celular cadastrado.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Icon(Icons.phone_android, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                if (proximos.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color.fromARGB(43, 65, 167, 250),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Próximos (${proximos.length}):'),
                        ),
                      ),
                    ],
                  ),
                proximos.isEmpty
                    ? const Column(
                        children: [
                          SizedBox(height: 30),
                          Center(
                            child: Text('Nenhum nos próximos 5 dias...'),
                          ),
                          SizedBox(height: 30),
                        ],
                      )
                    : Expanded(
                        child: Container(
                          color: const Color.fromARGB(43, 65, 167, 250),
                          padding: const EdgeInsets.only(left: 5),
                          child: ListView.builder(
                            itemCount: proximos.length,
                            itemBuilder: (context, index) {
                              Cliente cliente = proximos[index];
                              return ListTile(
                                title: Text(
                                  cliente.nome,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cliente.modelo),
                                    const SizedBox(width: 15),
                                    Text(
                                      '${diasParaVencimento(cliente.vencimento).toString()} dias para o venc...',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 104, 98, 98),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.message,
                                        color: Color.fromARGB(255, 10, 189, 16),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        cliente.avisos.toString(),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ]),
                                textColor: const Color.fromARGB(255, 0, 0, 0),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  icon:
                                                      const Icon(Icons.close)),
                                            ],
                                          ),
                                          Text(
                                            cliente.nome,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(cliente.modelo),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  atualizarCadastro(cliente, 1);
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Pagou'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.attach_money,
                                                        color: Colors.amber),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  cliente.celular != ''
                                                      ? notificar(
                                                          cliente.celular,
                                                          cliente)
                                                      : avisarSemCelular();
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Notificar'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.message,
                                                        color: Color.fromARGB(
                                                            255, 10, 189, 16)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                if (deHoje.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            color: const Color.fromARGB(255, 223, 255, 220),
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Hoje (${deHoje.length}):')),
                      ),
                    ],
                  ),
                deHoje.isEmpty
                    ? const Column(
                        children: [
                          SizedBox(height: 30),
                          Center(
                            child: Text('Nenhum para hoje...'),
                          ),
                          SizedBox(height: 30),
                        ],
                      )
                    : Expanded(
                        child: Container(
                          color: const Color.fromARGB(255, 223, 255, 220),
                          padding: const EdgeInsets.only(left: 5),
                          child: ListView.builder(
                            itemCount: deHoje.length,
                            itemBuilder: (context, index) {
                              Cliente cliente = deHoje[index];
                              return ListTile(
                                title: Text(
                                  cliente.nome,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(cliente.modelo),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.message,
                                        color: Color.fromARGB(255, 10, 189, 16),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        cliente.avisos.toString(),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ]),
                                textColor: Colors.black,
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  icon:
                                                      const Icon(Icons.close)),
                                            ],
                                          ),
                                          Text(
                                            cliente.nome,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(cliente.modelo),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  atualizarCadastro(cliente, 1);
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Pagou'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.attach_money,
                                                        color: Colors.amber),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  cliente.celular != ''
                                                      ? notificar(
                                                          cliente.celular,
                                                          cliente)
                                                      : avisarSemCelular();
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Notificar'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.message,
                                                        color: Color.fromARGB(
                                                            255, 10, 189, 16)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                if (atrasados.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            color: const Color.fromARGB(255, 255, 220, 220),
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Atrasados (${atrasados.length}):')),
                      ),
                    ],
                  ),
                atrasados.isEmpty
                    ? const Column(
                        children: [
                          SizedBox(height: 30),
                          Center(
                            child: Text('Nenhum atrasado...'),
                          ),
                          SizedBox(height: 30),
                        ],
                      )
                    : Expanded(
                        child: Container(
                          color: const Color.fromARGB(255, 255, 220, 220),
                          padding: const EdgeInsets.only(left: 5),
                          child: ListView.builder(
                            itemCount: atrasados.length,
                            itemBuilder: (context, index) {
                              Cliente cliente = atrasados[index];
                              return ListTile(
                                title: Text(
                                  cliente.nome,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cliente.modelo,
                                      style: const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      '${diasParaVencimento(cliente.vencimento).toString().replaceAll('-', '')} dias de atraso',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 104, 98, 98),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.message,
                                        color: Color.fromARGB(255, 10, 189, 16),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        cliente.avisos.toString(),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ]),
                                textColor: const Color.fromARGB(255, 0, 0, 0),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) => Dialog(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  icon:
                                                      const Icon(Icons.close)),
                                            ],
                                          ),
                                          Text(
                                            cliente.nome,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                          Text(cliente.modelo),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  atualizarCadastro(cliente, 1);
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Pagou'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.attach_money,
                                                        color: Colors.amber),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  cliente.celular != ''
                                                      ? notificar(
                                                          cliente.celular,
                                                          cliente)
                                                      : avisarSemCelular();
                                                },
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text('Notificar'),
                                                    SizedBox(width: 6),
                                                    Icon(Icons.message,
                                                        color: Color.fromARGB(
                                                            255, 10, 189, 16)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}
