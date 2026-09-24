import 'package:flutter/material.dart';

import 'pages/border_page.dart';
import 'pages/coordinates_page.dart';
import 'pages/grid_page.dart';
import 'pages/offset_grid_page.dart';
import 'pages/widgets_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hexagon examples',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = <(String, Widget)>[
    ('Grid', GridPage()),
    ('Offset', OffsetGridPage()),
    ('Widgets', WidgetsPage()),
    ('Border', BorderPage()),
    ('Coordinates', CoordinatesPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('hexagon'),
          bottom: TabBar(
            tabs: [for (final (label, _) in _pages) Tab(text: label)],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [for (final (_, page) in _pages) page],
        ),
      ),
    );
  }
}
