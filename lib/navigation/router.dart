import 'package:f_chord/feature/chord_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:f_chord/feature/chord_trans.dart';
import 'package:f_chord/feature/chord_list.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ChordListPage(),
    ),
    GoRoute(
      path: '/chord',
      builder: (context, state) => ChordPage(),
    ),
  ],
);
