import 'package:flutter/material.dart';
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
      appBar: AppBar(title: Text(title)),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    var h = 300.0;
    var w = 300.0;

    var pad = 20.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.all(pad),
              child: HexagonWidget.pointy(
                width: w,
                // height: h,
                elevation: 4,
                color: Colors.blueGrey,
                child: Image.asset('assets/planet.jpg'),
              ),
            ),
            Container(
              child: HexagonWidget.pointy(
                // width: w,
                height: h,
                color: Colors.orangeAccent,
                elevation: 0,
                child: Container(
                  width: 1500,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              color: Colors.green,
              child: HexagonWidget.flat(
                width: w,
                // height: h,
                color: Colors.red,
                inBounds: false,
                elevation: 8,
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              color: Colors.blue,
              margin: EdgeInsets.all(pad),
              child: HexagonWidget.flat(
                width: w,
                // height: h,
                elevation: 4, inBounds: false,
                child: Image.asset('assets/planet.jpg'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
