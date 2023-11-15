
import 'package:coolcoolcoffee_front/page/menu/menu_list_view.dart';
import 'package:coolcoolcoffee_front/page/menu/star_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'brand_list_view.dart';
import 'camera_button.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _brand = '메가커피';
  _changeBrandCallback(String brand) => setState((){
    _brand = brand;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
              Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
            _brand,
          style: TextStyle(
            color: Colors.black
          ),
        ),
        actions: [
          FractionallySizedBox(
            heightFactor: 0.7,
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (
                    context) =>StarPage()));
              },
              icon: Image.asset(
                "assets/star_unfilled_with_outer.png",
                fit: BoxFit.fill,
              ),
            ),
          )
        ],
      ),
      body:Column(
        children: [
          Container(height: 20,),
          Expanded(child: BrandListView(brandCallback: _changeBrandCallback,)),
          Expanded(
            flex: 9,
            child: MenuListView(brandName: _brand,)
          )
        ],
      ),
      floatingActionButton: CameraButton(),
    );
  }
}
