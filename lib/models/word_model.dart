class WordModel {
  final String word;
  final String partOfSpeech;
  final String shortDef;
  final bool offensive;

  const WordModel({
    required this.word,
    required this.partOfSpeech,
    required this.shortDef,
    required this.offensive,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      word: json['meta']['id'] as String,
      partOfSpeech: json['fl'] as String,
      shortDef: json['shortdef'][0] as String,
      offensive: json['meta']['offensive'] as bool,
    );
  }
}
