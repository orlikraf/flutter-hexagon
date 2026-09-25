import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

import 'grids_page.dart';
import 'map_page.dart';
import 'widgets_page.dart';

void main() => runApp(const HexagonExampleApp());

/// Gallery of the hexagon package.
class HexagonExampleApp extends StatelessWidget {
  const HexagonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) => ThemeData(
          colorSchemeSeed: Colors.amber,
          brightness: brightness,
          extensions: const [HexagonThemeData(cornerRadius: 4)],
        );
    return MaterialApp(
      title: 'Hexagon',
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;

  static const _titles = ['Widgets', 'Grids', 'Game map'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hexagon · ${_titles[_page]}')),
      body: IndexedStack(
        index: _page,
        children: const [WidgetsPage(), GridsPage(), MapPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (page) => setState(() => _page = page),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.hexagon_outlined), label: 'Widgets'),
          NavigationDestination(icon: Icon(Icons.grid_on), label: 'Grids'),
          NavigationDestination(
              icon: Icon(Icons.map_outlined), label: 'Game map'),
        ],
      ),
    );
  }
}
