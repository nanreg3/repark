import 'package:flutter/material.dart';
import 'package:repark/services/date_service.dart';
import 'package:repark/models/cliente.dart';
import 'package:repark/pages/cadastro_cliente_page.dart';

class ClienteItemList extends StatelessWidget {
  const ClienteItemList({super.key, required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          ListTile(
            title: Text(cliente.nome),
            subtitle: Text(cliente.modelo),
            leading: Icon(
              cliente.ativo ? Icons.person : Icons.person_off,
              size: 25,
            ),
            trailing: !mensalidadeEmDia(cliente.vencimento) && cliente.ativo
                ? const Icon(
                    Icons.money_off,
                    color: Colors.red,
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CadastroClientePage(cliente: cliente),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
