import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {

  const WordCard({required this.word, required this.partOfSpeech, required this.shortDef, required this.offensive, super.key});

  final String word;
  final String partOfSpeech;
  final String shortDef;
  final bool offensive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Text(word),
            trailing: Text(partOfSpeech),
            subtitle: Text(shortDef),
          ),
        ],
      ),
    );
  }
}