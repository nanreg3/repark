import 'package:flutter/material.dart';
import 'package:repark/tiles/drawer_tile.dart';

class CustomDrawer extends StatelessWidget {
  final PageController pageController;

  const CustomDrawer(this.pageController, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildDrawerBack() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 255, 255),
                Color.fromARGB(255, 8, 165, 185)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );

    return Drawer(
      child: Stack(
        children: [
          buildDrawerBack(),
          ListView(
            padding: const EdgeInsets.only(left: 32.0, top: 18.0),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.fromLTRB(0.0, 16.0, 16.0, 8.0),
                height: 170.0,
                child: const Stack(
                  children: [
                    Positioned(
                        child: Text(
                      "Repark",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
                  ],
                ),
              ),
              const Divider(),
              DrawerTile(Icons.car_crash, "Avisos", pageController, 0),
              DrawerTile(Icons.timer, "Avulsos", pageController, 1),
              DrawerTile(
                  Icons.people_alt_rounded, "Clientes", pageController, 2),
              DrawerTile(Icons.settings, "Configurações", pageController, 3),
            ],
          )
        ],
      ),
    );
  }
}
