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
      home: MyHomePage(title: 'Flutter Hexagon Example'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Flat',
              ),
              Tab(
                text: 'Pointy',
              ),
              Tab(text: 'More'),
            ],
          ),
          title: Text(title),
        ),
        body: TabBarView(
          children: [
            _buildFlatExample(size),
            _buildPointyExample(size),
            _buildMore(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatExample(Size size) {
    var w = size.width > 200.0 ? 200.0 : size.width / 2;
    var h = 200.0;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.flat(
              width: w,
              child: AspectRatio(
                aspectRatio: HexagonType.FLAT.ratio,
                child: Image.asset(
                  'assets/bee.jpg',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.flat(
              height: h,
              color: Colors.orangeAccent,
              child: Text('height: $h'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.flat(
              width: w,
              color: Colors.limeAccent,
              elevation: 0,
              child: Text('width: $w\nelevation: 0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointyExample(Size size) {
    var w = size.width > 200.0 ? 200.0 : size.width / 2.0;
    var h = 200.0;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.pointy(
              width: w,
              child: AspectRatio(
                aspectRatio: HexagonType.POINTY.ratio,
                child: Image.asset(
                  'assets/tram.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.pointy(
              width: w,
              color: Colors.lightBlue,
              child: Text('width: $w'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.pointy(
              height: h,
              color: Colors.green,
              child: Text('height: $h'),
            ),
          ),
          Container(
            color: Colors.red.withAlpha(100),
            padding: EdgeInsets.all(8.0),
            child: HexagonWidget.pointy(
              height: h,
              color: Colors.lightGreen,
              inBounds: false,
              child: Text(
                'height: $h\ninBounds: false',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMore() {
    return Center(child: Text('More examples will come with grids'));
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
                child: Image.asset('assets/tram.jpg'),
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
                child: Image.asset('assets/bee.jpg'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
