import 'package:flutter/material.dart';
import 'package:hexagon/hexagon_type.dart';
import 'package:hexagon/hexagon_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                print('tapped earth');
              },
              child: HexagonWidget(
                height: 200,
                // width: 20,
                child: Image.asset('assets/planet.jpg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HexagonWidget(
                width: 150,
                elevation: 4,
                type: HexagonType.POINTY,
                child: Center(child: Text('GON')),
              ),
            ),
            // HexagonWidget(
            //   child: Image.asset('assets/planet.jpg'),
            // ),
          ],
        ),
      ),
    );
  }
}
