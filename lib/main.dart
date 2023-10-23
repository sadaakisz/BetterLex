import 'dart:convert';

import 'package:betterlex/models/word_model.dart';
import 'package:betterlex/widgets/word_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:word_generator/word_generator.dart';

Future<WordModel> fetchWord(String randomNoun) async {
  String apiKey = 'a4c7870c-de04-4b51-adab-4a2620d45e95';
  String requestUrl =
      'https://www.dictionaryapi.com/api/v3/references/thesaurus/json/$randomNoun?key=$apiKey';
  var response = await http.get(Uri.parse(requestUrl));
  var decodedJson = jsonDecode(response.body)[0];
  if (response.statusCode == 200) {
    WordModel wordResult;
    try {
      wordResult = WordModel.fromJson(decodedJson as Map<String, dynamic>);
    } catch (_) {
      randomNoun = decodedJson;
      return fetchWord(randomNoun);
    }
    return wordResult;
  } else {
    throw Exception('Failed to load Word from API.');
  }
}

/*Future<List<WordModel>> fetchWords() async {
  List<WordModel> listOfWords = [];
  final response = await http.get(Uri.parse(
      'https://www.dictionaryapi.com/api/v3/references/thesaurus/json/umpire?key=a4c7870c-de04-4b51-adab-4a2620d45e95'));
  if (response.statusCode == 200) {
    var decodedJson = jsonDecode(response.body);
    for (var definition in decodedJson) {
      listOfWords.add(WordModel.fromJson(definition as Map<String, dynamic>));
    }
    return listOfWords;
  } else {
    throw Exception('Failed to load Word from API.');
  }
}*/

Future<String> fetchBody(String randomNoun) async {
  String apiKey = 'a4c7870c-de04-4b51-adab-4a2620d45e95';
  String requestUrl =
      'https://www.dictionaryapi.com/api/v3/references/thesaurus/json/$randomNoun?key=$apiKey';
  final response = await http.get(Uri.parse(requestUrl));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load Word from API.');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BetterLex'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<WordModel> futureWord;
  late Future<String> futureBody;
  late String randomNoun;

  @override
  void initState() {
    super.initState();
    final wordGenerator = WordGenerator();
    randomNoun = wordGenerator.randomNoun();
    // randomNoun = 'in-joke';

    futureBody = fetchBody(randomNoun);
    futureWord = fetchWord(randomNoun);
    // TODO: Make that when fetchWord double-takes, randomNoun gets updated
    // randomNoun =
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(randomNoun),
            FutureBuilder<WordModel>(
              future: futureWord,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return WordCard(
                      word: snapshot.data!.word,
                      partOfSpeech: snapshot.data!.partOfSpeech,
                      shortDef: snapshot.data!.shortDef,
                      offensive: snapshot.data!.offensive);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
            FutureBuilder(
              future: futureBody,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
