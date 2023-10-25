import 'dart:convert';

import 'package:betterlex/models/word_model.dart';
import 'package:betterlex/widgets/word_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:word_generator/word_generator.dart';

/*
Flutter Local Notifications initialization:
*/

/*void flutterLocalNotificationInit() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
}

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  await Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  );
}*/

final wordGenerator = WordGenerator();

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

Future<List<WordModel>> fetchWords(String randomNoun) async {
  List<WordModel> definitionsList = [];
  String apiKey = 'a4c7870c-de04-4b51-adab-4a2620d45e95';
  String requestUrl =
      'https://www.dictionaryapi.com/api/v3/references/thesaurus/json/$randomNoun?key=$apiKey';
  var response = await http.get(Uri.parse(requestUrl));
  var decodedJson = jsonDecode(response.body);
  if (response.statusCode == 200) {
    try {
      for (var definition in decodedJson) {
        definitionsList
            .add(WordModel.fromJson(definition as Map<String, dynamic>));
      }
    } catch (_) {
      randomNoun = decodedJson;
      return fetchWords(randomNoun);
    }
    return definitionsList;
  } else {
    throw Exception('Failed to load Word from API.');
  }
}

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
  late Future<List<WordModel>> futureWords;
  late Future<String> futureBody;
  late String randomNoun;

  @override
  void initState() {
    super.initState();

    randomNoun = wordGenerator.randomNoun();
    // randomNoun = 'in-joke';

    futureBody = fetchBody(randomNoun);
    futureWord = fetchWord(randomNoun);
    futureWords = fetchWords(randomNoun);
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
            RefreshIndicator(
              onRefresh: _pullRefresh,
              child: FutureBuilder(
                future: futureWords,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _wordCardListView(snapshot);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
            // bodyText(),
          ],
        ),
      ),
    );
  }

  Widget _wordCardListView(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: snapshot.data?.length,
        itemBuilder: (context, index) {
          return buildWordCard(snapshot.data[index]);
        },
      );
    } else {
      return const Center(
        child: Text('Loading word'),
      );
    }
  }

  WordCard buildWordCard(WordModel snapshot) {
    return WordCard(
        word: snapshot.word,
        partOfSpeech: snapshot.partOfSpeech,
        shortDef: snapshot.shortDef,
        offensive: snapshot.offensive);
  }

  FutureBuilder<String> bodyText() {
    return FutureBuilder(
      future: futureBody,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<void> _pullRefresh() async {
    randomNoun = wordGenerator.randomNoun();
    String freshBody = await fetchBody(randomNoun);
    WordModel freshWord = await fetchWord(randomNoun);
    List<WordModel> freshWords = await fetchWords(randomNoun);
    setState(() {
      futureBody = Future.value(freshBody);
      futureWord = Future.value(freshWord);
      futureWords = Future.value(freshWords);
    });
  }
}
