import 'package:f_chord/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:f_chord/config/size_config.dart';
import 'dart:convert';
import 'package:f_chord/database/database.rb';

class ChordCard extends StatelessWidget {
  final String chord;
  const ChordCard(this.chord, {super.key});

  @override
  Widget build(BuildContext context) {
    // var color = Colors.amberAccent;
    return Container(
      width: SizeConfig.blockSizeHorizontal * 15,
      height: SizeConfig.blockSizeVertical * 5,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.black, width: 1),
        color: Colors.orange[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(chord, style: TextStyle(fontSize: 15)),
      ),
    );
  }
}

class ChordPage extends StatefulWidget {
  const ChordPage({super.key});
  @override
  State<ChordPage> createState() => _ChordPageState();
}

class _ChordPageState extends State<ChordPage> {
  List<List<String>> chordGrid = [[]];

  int transposeOffset = 0;
  double transpose = 0;
  bool edit = false;
  int? progressionId = null;
  String titile = '';
  final Map<String, List<String>> chordCategories = {
    'M7': [
      'CM7',
      'D♭M7',
      'DM7',
      'E♭M7',
      'EM7',
      'FM7',
      'G♭M7',
      'GM7',
      'A♭M7',
      'AM7',
      'B♭M7',
      'BM7'
    ],
    '7th': [
      'C7',
      'D♭7',
      'D7',
      'E♭7',
      'E7',
      'F7',
      'G♭7',
      'G7',
      'A♭7',
      'A7',
      'B♭7',
      'B7'
    ],
    'm7': [
      'Cm7',
      'D♭m7',
      'Dm7',
      'E♭m7',
      'Em7',
      'Fm7',
      'G♭m7',
      'Gm7',
      'A♭m7',
      'Am7',
      'B♭m7',
      'Bm7'
    ],
    'Other': [
      'Csus4',
      'D♭sus4',
      'Dsus4',
      'E♭sus4',
      'Esus4',
      'Fsus4',
      'G♭sus4',
      'Gsus4',
      'A♭sus4',
      'Asus4',
      'B♭sus4',
      'Bsus4',
      'Bdim',
      'Edim'
    ],
  };

  void _addRow() {
    setState(() {
      chordGrid.add([]);
    });
  }

  void _addChordToRow(int rowIndex, String chord) {
    setState(() {
      chordGrid[rowIndex].add(chord);
    });
  }

  String transposeChord(String chord, int offset) {
    final notes = [
      'D♭',
      'E♭',
      'G♭',
      'A♭',
      'B♭',
      'C',
      'D',
      'E',
      'F',
      'G',
      'A',
      'B',
    ];

    for (var note in notes) {
      if (chord.startsWith(note)) {
        final index = notes.indexOf(note);
        final rest = chord.substring(note.length);
        final newNote = notes[(index + offset + 12) % 12];
        return newNote + rest;
      }
    }
    return chord;
  }

  void _showChordPicker(int rowIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DefaultTabController(
          length: chordCategories.length,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.black,
                      tabs: chordCategories.keys
                          .map((category) => Tab(text: category))
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: chordCategories.values.map((chords) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: chords.length,
                          itemBuilder: (context, index) {
                            final chord = chords[index];
                            return ListTile(
                              title: Text(chord),
                              onTap: () {
                                Navigator.pop(context);
                                _addChordToRow(rowIndex, chord);
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _changeSlider(double e) => setState(() {
        transposeOffset = e.toInt();
      });

  Future<void> saveChordProgression(BuildContext context, String title,
      List<List<String>> chordGrid, int? progressionId) async {
    final db = await DatabaseHelper().db;

    if (progressionId != null) {
      await db.delete(
        'ChordRow',
        where: 'progressionId = ?',
        whereArgs: [progressionId],
      );

      for (var row in chordGrid) {
        await db.insert('ChordRow', {
          'progressionId': progressionId,
          'chords': jsonEncode(row),
        });
      }
    } else {
      final progressionId = await db.insert('ChordProgression', {
        'title': title,
        'createdAt': DateTime.now().toIso8601String(),
      });

      for (final row in chordGrid) {
        await db.insert('ChordRow', {
          'progressionId': progressionId,
          'chords': jsonEncode(row),
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('保存しました'),
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = goRouter.state;

    if (state.extra != null) {
      final extra = state.extra as Map<String, dynamic>;
      edit = true;
      chordGrid =
          List<List<String>>.from(extra['chordGrid'] as List<List<String>>);
      progressionId = extra['id'] as int;
      titile = extra['title'] as String;
    } else {
      chordGrid = [[]];
    }
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
            icon: const Icon(Icons.save_as_outlined),
            onPressed: () async {
              final controller = TextEditingController();
              controller.text = titile;
              await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text('コード進行のタイトル'),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await saveChordProgression(
                            context, controller.text, chordGrid, progressionId);
                        Navigator.pop(dialogContext);
                        goRouter.go('/');
                      },
                      child: Text('保存'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text('Chords',
              style: TextStyle(
                fontSize: SizeConfig.TitleSize,
                color: Colors.black,
              )),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: chordGrid.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  List<String> chords = entry.value;
                  return Row(
                    children: [
                      ...chords.map((chord) {
                        final transposed =
                            transposeChord(chord, transposeOffset);
                        return ChordCard(transposed);
                      }).toList(),
                      IconButton(
                        onPressed: () => _showChordPicker(rowIndex),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
              onPressed: _addRow,
              child: Text('行を追加'),
            ),
          ]),
          Divider(
            color: Colors.grey,
            thickness: 1,
            height: 20,
          ),
          Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text("トランスポーズ"),
              ),
            ),
            Slider(
              label: '${transposeOffset}',
              min: -7,
              max: 7,
              value: transposeOffset.toDouble(),
              activeColor: Colors.grey,
              inactiveColor: Colors.grey,
              divisions: 15,
              onChanged: _changeSlider,
            ),
          ]),
        ],
      ),
    );
  }
}
