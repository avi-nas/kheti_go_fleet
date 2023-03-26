import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhetiGo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),

      home: const MyHomeScreen(title: 'KhetiGo - Fleet Management'),
    );
  }
}


class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child:  Image.asset("assets/backgroundImage.png",
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),

            Container(
              alignment: Alignment.center,
              child: const Text('Work in progress...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
             ),
            ],
          ),
        ),
      );
    }
}
