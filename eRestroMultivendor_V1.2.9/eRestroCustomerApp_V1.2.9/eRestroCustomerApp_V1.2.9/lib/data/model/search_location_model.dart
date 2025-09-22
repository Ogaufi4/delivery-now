class SearchLocationModel {
  final bool error;
  final String message;
  final SearchLocationData data;

  SearchLocationModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory SearchLocationModel.fromJson(Map<String, dynamic> json) {
    return SearchLocationModel(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: SearchLocationData.fromJson(json['data'] ?? {}),
    );
  }
}

class SearchLocationData {
  final List<SuggestionItem> suggestions;

  SearchLocationData({required this.suggestions});

  factory SearchLocationData.fromJson(Map<String, dynamic> json) {
    List<SuggestionItem> suggestions = [];
    if (json['suggestions'] != null) {
      suggestions = List<SuggestionItem>.from(
        json['suggestions'].map((x) => SuggestionItem.fromJson(x)),
      );
    }
    return SearchLocationData(suggestions: suggestions);
  }
}

class SuggestionItem {
  final PlacePrediction placePrediction;

  SuggestionItem({required this.placePrediction});

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    return SuggestionItem(
      placePrediction: PlacePrediction.fromJson(json['placePrediction'] ?? {}),
    );
  }
}

class PlacePrediction {
  final String place;
  final String placeId;
  final TextItem text;
  final StructuredFormat structuredFormat;
  final List<String> types;

  PlacePrediction({
    required this.place,
    required this.placeId,
    required this.text,
    required this.structuredFormat,
    required this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      place: json['place'] ?? '',
      placeId: json['placeId'] ?? '',
      text: TextItem.fromJson(json['text'] ?? {}),
      structuredFormat:
          StructuredFormat.fromJson(json['structuredFormat'] ?? {}),
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class TextItem {
  final String text;
  final List<Match> matches;

  TextItem({required this.text, required this.matches});

  factory TextItem.fromJson(Map<String, dynamic> json) {
    List<Match> matches = [];
    if (json['matches'] != null) {
      matches = List<Match>.from(
        json['matches'].map((x) => Match.fromJson(x)),
      );
    }
    return TextItem(text: json['text'] ?? '', matches: matches);
  }
}

class Match {
  final int endOffset;

  Match({required this.endOffset});

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(endOffset: json['endOffset'] ?? 0);
  }
}

class StructuredFormat {
  final TextItem mainText;
  final TextItem secondaryText;

  StructuredFormat({required this.mainText, required this.secondaryText});

  factory StructuredFormat.fromJson(Map<String, dynamic> json) {
    return StructuredFormat(
      mainText: TextItem.fromJson(json['mainText'] ?? {}),
      secondaryText: TextItem.fromJson(json['secondaryText'] ?? {}),
    );
  }
}
