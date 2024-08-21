import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:repark/models/avulso.dart';
import 'package:repark/models/config.dart';
import 'package:repark/models/ticket.dart';
import 'package:repark/services/valor_avulso_service.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key, required this.ticket, required this.avulso});

  final Ticket ticket;
  final Avulso avulso;

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  ReceiptController? controller;
  String? address;
  Config? config;

  @override
  void initState() {
    super.initState();
    getConfig().then((value) {
      setState(() {
        config = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressão de Ticket'),
        actions: [
          IconButton(
            onPressed: () async {
              final selected =
                  await FlutterBluetoothPrinter.selectDevice(context);
              if (selected != null) {
                setState(() {
                  address = selected.address;
                });
              }
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Receipt(
              backgroundColor: Colors.grey.shade200,
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.fitHeight,
                      height: 170,
                    ),
                    Center(
                      child: Text(config?.nomeLoja ?? ''),
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 25,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'Recibo de Estacionamento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(thickness: 2),
                    Table(
                      columnWidths: const {
                        1: IntrinsicColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text('Data'),
                            Text(r''
                                '${DateTime.now().toString().substring(8, 10)}/${DateTime.now().toString().substring(5, 7)}/${DateTime.now().toString().substring(2, 4)}'),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Veículo'),
                            Text(r'' + widget.avulso.placa),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Entrada'),
                            Text(r'' + widget.ticket.entrada),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Saída'),
                            Text(r'' + widget.ticket.saida),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text('Permanência'),
                            Text(r'' + widget.ticket.permanencia),
                          ],
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Text(
                      'Valor hora: R\$${config?.valorHora.toStringAsFixed(2).toString().replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      'Valor hora adicional: R\$${config?.valorHoraAdd.toStringAsFixed(2).toString().replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 15.5,
                      ),
                    ),
                    if (config?.valorMeiaHora != 0)
                      Text(
                        'Valor meia hora: R\$${config?.valorMeiaHora.toStringAsFixed(2).toString().replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 15.5,
                        ),
                      ),
                    const Divider(thickness: 2),
                    FittedBox(
                      fit: BoxFit.cover,
                      child: Row(
                        children: [
                          const Text(
                            'TOTAL R\$:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            r'' + widget.ticket.valor,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        config?.rodape ?? '',
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                );
              },
              onInitialized: (controller) {
                setState(() {
                  this.controller = controller;
                });
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final selectedAddress = address ??
                            (await FlutterBluetoothPrinter.selectDevice(
                                    context))
                                ?.address;

                        if (selectedAddress != null) {
                          PrintingProgressDialog.print(
                            // ignore: use_build_context_synchronously
                            context,
                            device: selectedAddress,
                            controller: controller!,
                            avulso: widget.avulso,
                            ticket: widget.ticket,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text(
                        'Imprimir',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrintingProgressDialog extends StatefulWidget {
  final String device;
  final ReceiptController controller;
  final Avulso avulso;
  final Ticket ticket;
  const PrintingProgressDialog({
    super.key,
    required this.device,
    required this.controller,
    required this.avulso,
    required this.ticket,
  });

  @override
  State<PrintingProgressDialog> createState() => _PrintingProgressDialogState();
  static void print(
    BuildContext context, {
    required String device,
    required ReceiptController controller,
    required Avulso avulso,
    required Ticket ticket,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrintingProgressDialog(
        controller: controller,
        device: device,
        avulso: avulso,
        ticket: ticket,
      ),
    );
  }
}

class _PrintingProgressDialogState extends State<PrintingProgressDialog> {
  double? progress;
  @override
  void initState() {
    super.initState();
    widget.controller.print(
      address: widget.device,
      addFeeds: 5,
      keepConnected: true,
      onProgress: (total, sent) {
        if (mounted) {
          setState(() {
            progress = sent / total;
          });
        }
      },
    );
  }

  void atualizarAvulso() {
    final avulso = {
      "entrada": widget.avulso.entrada,
      "saida": widget.ticket.saida,
      "valor": widget.ticket.valor,
      "veiculo": widget.avulso.veiculo,
      "modelo": widget.avulso.modelo,
      "cor": widget.avulso.cor,
      "placa": widget.avulso.placa,
      "obs": widget.avulso.obs,
    };
    final firestore =
        FirebaseFirestore.instance.collection('estacionamentos/djalma/avulsos');
    try {
      firestore.doc(widget.avulso.id).update(avulso);
      const snackBar = SnackBar(
        duration: Durations.medium3,
        content: Text("Dados alterados com sucesso!"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } catch (error) {
      const SnackBar(content: Text("Erro ao gravar dados!"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Imprimindo Recibo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 4),
            Text('Processando: ${((progress ?? 0) * 100).round()}%'),
            if (((progress ?? 0) * 100).round() == 100) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FlutterBluetoothPrinter.disconnect(widget.device);
                  atualizarAvulso();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Text('ok'),
              )
            ],
          ],
        ),
      ),
    );
  }
}
