import 'package:flutter/material.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/models/avulso.dart';
import 'package:repark/pages/cadastro_avulso_page.dart';

class AvulsoItemList extends StatelessWidget {
  const AvulsoItemList({super.key, required this.avulso});

  final Avulso avulso;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          ListTile(
            title: Text('${avulso.modelo}  ${avulso.placa}'),
            subtitle: Text('Entrada: ${formatStringEntrada(avulso.entrada)}'),
            leading: Icon(
              avulso.veiculo == 'Carro'
                  ? Icons.directions_car
                  : avulso.veiculo == 'Moto'
                      ? Icons.motorcycle_sharp
                      : Icons.pedal_bike,
              size: 25,
            ),
            trailing: const Icon(Icons.print, color: Colors.black),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CadastroAvulsoPage(avulso: avulso),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
