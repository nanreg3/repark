import 'package:flutter/material.dart';
import 'package:repark/pages/avisos_page.dart';
import 'package:repark/pages/list_avulsos_impressos.dart';
import 'package:repark/pages/list_avulsos_page.dart';
import 'package:repark/pages/list_clientes_page.dart';
import 'package:repark/pages/config_page.dart';
import 'package:repark/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 224, 224),
            title: const Text("Avisos"),
            centerTitle: true,
          ),
          body: const AvisoPage(),
          drawer: CustomDrawer(pageController),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 224, 224),
            title: const Text("Avulsos"),
            centerTitle: true,
          ),
          body: const AvulsoPage(),
          drawer: CustomDrawer(pageController),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 224, 224),
            title: const Text("Histórico"),
            centerTitle: true,
          ),
          body: const AvulsoImpressoPage(),
          drawer: CustomDrawer(pageController),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 224, 224),
            title: const Text("Clientes"),
            centerTitle: true,
          ),
          body: const ClientesPage(),
          drawer: CustomDrawer(pageController),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 17, 224, 224),
            title: const Text("Configurações"),
            centerTitle: true,
          ),
          body: const ConfigPage(),
          drawer: CustomDrawer(pageController),
        ),
      ],
    );
  }
}
