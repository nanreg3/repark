import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repark/models/avulso.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/widgets/avulso_item_list.dart';

class AvulsoImpressoPage extends StatefulWidget {
  const AvulsoImpressoPage({super.key});

  @override
  State<AvulsoImpressoPage> createState() => _AvulsoImpressoPageState();
}

class _AvulsoImpressoPageState extends State<AvulsoImpressoPage> {
  List<Avulso> avulsos = [];
  List<Avulso> displayedAvulsos = [];
  final filterController = TextEditingController();
  late TextEditingController vencimento = TextEditingController();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        vencimento.text = formatDateToStringShow(picked);
        displayedAvulsos = avulsos
            .where((Avulso a) => a.entrada.contains(
                picked.toString().replaceAll('-', '').substring(0, 8)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextField(
                  controller: filterController,
                  onChanged: (value) {
                    setState(() {
                      displayedAvulsos = avulsos
                          .where((Avulso a) =>
                              a.modelo
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              a.placa
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar: ',
                    hintText: '',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: vencimento,
                  readOnly: true,
                  onTap: () {
                    selectDate(context);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Data:',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                ),
              ),
            ],
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
                        if (doc['saida'] != '') {
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
                      itemCount:
                          filterController.text == '' && vencimento.text == ''
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
    );
  }
}
