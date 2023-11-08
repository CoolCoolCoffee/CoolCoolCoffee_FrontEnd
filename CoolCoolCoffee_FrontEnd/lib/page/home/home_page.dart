import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'caffeine_left.dart';
import 'drink_list.dart';
import 'clock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              '홈 화면',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        iconTheme: IconThemeData(color: Colors.white),
    ),
    body: Column(
      children: [
        SizedBox(height: 30),
        ClockWidget(),
        SizedBox(height: 50),
        CaffeineLeftWidget(),
        SizedBox(height: 50),
        DrinkListWidget()
      ],
    )
    );
  }
}
