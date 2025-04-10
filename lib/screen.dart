import 'package:flutter/material.dart';
import 'package:f_chord/navigation/router.dart';

bool canPopValue = true;

class Screen extends StatefulWidget {
  const Screen({super.key, required this.title});

  final String title;

  @override
  State<Screen> createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  int _current_index = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPopValue,
        onPopInvoked: (bool didpop) {
          onSelect(0);
        },
        child: Scaffold(
          body: MaterialApp.router(
            routerConfig: goRouter,
          ),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (index) {
              onSelect(index);
            },
            indicatorColor: Colors.yellow[800],
            selectedIndex: _current_index,
            destinations: <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
            ],
          ),
        ));
  }

  void onSelect(int index) {
    print(_current_index);
    switch (index) {
      case 0:
        if (_current_index == 0) {
          goRouter.go('/');
        } else {
          goRouter.go('/');
        }
        break;
      case 1:
        goRouter.go('/');
        break;
    }
    setState(() {
      _current_index = index;
    });
  }
}
