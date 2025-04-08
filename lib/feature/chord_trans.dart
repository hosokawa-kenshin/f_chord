import 'package:flutter/material.dart';
import 'package:f_chord/config/size_config.dart';

class ChordPage extends StatefulWidget {
  const ChordPage({super.key});
  @override
  State<ChordPage> createState() => _ChordPageState();
}

class _ChordPageState extends State<ChordPage> {
  List<List<Widget>> widgetGrid = [];

  void _addRow() {
    setState(() {
      widgetGrid.add([ElevatedButton.icon(
        onPressed: _addWidgetToLastRow,
        icon: Icon(Icons.add_box),
        label: Text('横に追加'),
      ),]);
      _addWidgetToLastRow();
    });
  }

  void _addWidgetToLastRow() {
    if (widgetGrid.isEmpty) {
      _addRow();
    }

    setState(() {
      final rowIndex = widgetGrid.length - 1;
      final widgetIndex = widgetGrid[rowIndex].length + 1;
      widgetGrid[rowIndex].add(_buildDashboardCard(rowIndex, widgetIndex));
    });
  }

  Widget _buildDashboardCard(int row, int index) {
    return Container(
      width: 120,
      height: 100,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue[100 * ((index % 8) + 1)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text('R$row-W$index'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 1,
          title: Align(
            alignment: Alignment.bottomLeft,
            child: Text('Chords',
                style: TextStyle(
                  fontSize: SizeConfig.TitleSize,
                  color: Colors.black,
                )),
          ),
        ),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: Icon(Icons.add),
                label: Text('縦に追加'),
              ),
              ElevatedButton.icon(
                onPressed: _addWidgetToLastRow,
                icon: Icon(Icons.add_box),
                label: Text('横に追加'),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              children: widgetGrid.map((rowWidgets) {
                return Row(
                  children: rowWidgets,
                  mainAxisAlignment: MainAxisAlignment.start,
                );
              }).toList(),
            ),
          ),
        ]));
  }
}
