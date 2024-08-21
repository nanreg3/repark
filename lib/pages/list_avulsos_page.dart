import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/avulso.dart';
import 'package:repark/pages/cadastro_avulso_page.dart';
import 'package:repark/widgets/avulso_item_list.dart';

class AvulsoPage extends StatefulWidget {
  const AvulsoPage({super.key});

  @override
  State<AvulsoPage> createState() => _AvulsoPageState();
}

class _AvulsoPageState extends State<AvulsoPage> {
  List<Avulso> avulsos = [];
  List<Avulso> displayedAvulsos = [];
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
                displayedAvulsos = avulsos
                    .where((Avulso a) =>
                        a.modelo.toLowerCase().contains(value.toLowerCase()) ||
                        a.placa.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Pesquisar:',
              hintText: '',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('estacionamentos/djalma/avulsos')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data!.docs as List<DocumentSnapshot<Object?>>;

                    avulsos = [];

                    if (docs.isNotEmpty) {
                      for (var doc in docs) {
                        if (doc['saida'] == '') {
                          avulsos.add(Avulso.fromDocument(doc));
                        }
                      }
                    }

                    avulsos.sort(
                      (a, b) => a.entrada.compareTo(b.entrada),
                    );
                    displayedAvulsos.sort(
                      (a, b) => a.entrada.compareTo(b.entrada),
                    );

                    return ListView.builder(
                      itemCount: filterController.text == ''
                          ? avulsos.length
                          : displayedAvulsos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return AvulsoItemList(
                            avulso: filterController.text == ''
                                ? avulsos[index]
                                : displayedAvulsos[index]);
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
            MaterialPageRoute(builder: (_) => const CadastroAvulsoPage()),
          );
        },
        tooltip: 'Adicionar',
        backgroundColor: Colors.green,
        heroTag: 'btnAvulsos',
        child: const Icon(
          Icons.add_circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
