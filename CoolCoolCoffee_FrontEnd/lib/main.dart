import 'package:coolcoolcoffee_front/camera/camera_page.dart';
import 'package:coolcoolcoffee_front/menu/menu_page.dart';
import 'package:coolcoolcoffee_front/menu/camera_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CoolCoolCoffee());
}

class CoolCoolCoffee extends StatelessWidget {
  const CoolCoolCoffee({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //theme: ThemeData(primarySwatch: ),
      home: MenuPage(),
    );
  }
}
