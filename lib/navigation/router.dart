import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:f_chord/feature/chord_trans.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ChordPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => ChordPage(),
    ),
  ],
);
