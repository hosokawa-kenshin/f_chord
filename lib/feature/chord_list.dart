import 'package:f_chord/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:f_chord/database/database.rb';
import 'dart:convert';
import 'package:f_chord/config/size_config.dart';

class ChordListPage extends StatefulWidget {
  @override
  _ChordListPageState createState() => _ChordListPageState();
}

class _ChordListPageState extends State<ChordListPage> {
  List<Map<String, dynamic>> progressions = [];

  @override
  void initState() {
    super.initState();
    _loadProgressions();
  }

  Future<void> _loadProgressions() async {
    final db = await DatabaseHelper().db;
    final result =
        await db.query('ChordProgression', orderBy: 'createdAt DESC');
    setState(() {
      progressions = result;
    });
  }

  void _openProgression(int id, String title) async {
    final db = await DatabaseHelper().db;
    final rows = await db.query(
      'ChordRow',
      where: 'progressionId = ?',
      whereArgs: [id],
    );

    final chordGrid = rows.map((row) {
      return List<String>.from(jsonDecode(row['chords'] as String));
    }).toList();

    goRouter.go('/chord',
        extra: {'id': id, 'title': title, 'chordGrid': chordGrid});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
              onPressed: () => {goRouter.go('/chord')},
              icon: const Icon(Icons.add)),
        ],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text('Chords List',
              style: TextStyle(
                fontSize: SizeConfig.TitleSize,
                color: Colors.black,
              )),
        ),
      ),
      body: ListView.builder(
        itemCount: progressions.length,
        itemBuilder: (context, index) {
          final item = progressions[index];
          return ListTile(
            title: Text(item['title']),
            subtitle: Text(item['createdAt']),
            onTap: () => _openProgression(item['id'], item['title']),
          );
        },
      ),
    );
  }
}
