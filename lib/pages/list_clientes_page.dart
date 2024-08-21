import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/cliente.dart';
import 'package:repark/pages/cadastro_cliente_page.dart';
import 'package:repark/widgets/cliente_item_list.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  List<Cliente> clientes = [];
  List<Cliente> displayedClientes = [];
  final filterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: filterController,
            onChanged: (value) {
              setState(() {
                displayedClientes = clientes
                    .where((Cliente c) =>
                        c.nome.toLowerCase().contains(value.toLowerCase()) ||
                        c.modelo.toLowerCase().contains(value.toLowerCase()) ||
                        c.placa.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Pesquisar',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('estacionamentos/djalma/clientes')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data!.docs as List<DocumentSnapshot<Object?>>;

                    clientes = [];

                    if (docs.isNotEmpty) {
                      for (var doc in docs) {
                        clientes.add(Cliente.fromDocument(doc));
                      }
                    }

                    clientes.sort((a, b) => a.nome.compareTo(b.nome));
                    displayedClientes.sort((a, b) => a.nome.compareTo(b.nome));

                    return ListView.builder(
                      itemCount: filterController.text == ''
                          ? clientes.length
                          : displayedClientes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            title: ClienteItemList(
                                cliente: filterController.text == ''
                                    ? clientes[index]
                                    : displayedClientes[index]));
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroClientePage()),
          );
        },
        tooltip: 'Adicionar',
        backgroundColor: Colors.green,
        heroTag: 'btnClientes',
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
      ),
    );
  }
}
