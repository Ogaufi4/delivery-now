class LocationDetailsModel {
  String? name;
  String? id;
  List<String>? types;
  String? formattedAddress;
  List<AddressComponents>? addressComponents;
  Location? location;
  Viewport? viewport;
  String? googleMapsUri;
  int? utcOffsetMinutes;
  String? adrFormatAddress;
  String? iconMaskBaseUri;
  String? iconBackgroundColor;
  DisplayName? displayName;
  DisplayName? primaryTypeDisplayName;
  String? primaryType;
  String? shortFormattedAddress;
  List<Photos>? photos;
  bool? pureServiceAreaBusiness;
  GoogleMapsLinks? googleMapsLinks;
  TimeZone? timeZone;

  LocationDetailsModel({
    this.name,
    this.id,
    this.types,
    this.formattedAddress,
    this.addressComponents,
    this.location,
    this.viewport,
    this.googleMapsUri,
    this.utcOffsetMinutes,
    this.adrFormatAddress,
    this.iconMaskBaseUri,
    this.iconBackgroundColor,
    this.displayName,
    this.primaryTypeDisplayName,
    this.primaryType,
    this.shortFormattedAddress,
    this.photos,
    this.pureServiceAreaBusiness,
    this.googleMapsLinks,
    this.timeZone,
  });

  LocationDetailsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    types =
        (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    formattedAddress = json['formattedAddress'];
    addressComponents = (json['addressComponents'] as List<dynamic>?)
            ?.map((v) => AddressComponents.fromJson(v))
            .toList() ??
        [];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    viewport =
        json['viewport'] != null ? Viewport.fromJson(json['viewport']) : null;
    googleMapsUri = json['googleMapsUri'];
    utcOffsetMinutes = json['utcOffsetMinutes'];
    adrFormatAddress = json['adrFormatAddress'];
    iconMaskBaseUri = json['iconMaskBaseUri'];
    iconBackgroundColor = json['iconBackgroundColor'];
    displayName = json['displayName'] != null
        ? DisplayName.fromJson(json['displayName'])
        : null;
    primaryTypeDisplayName = json['primaryTypeDisplayName'] != null
        ? DisplayName.fromJson(json['primaryTypeDisplayName'])
        : null;
    primaryType = json['primaryType'];
    shortFormattedAddress = json['shortFormattedAddress'];
    photos = (json['photos'] as List<dynamic>?)
            ?.map((v) => Photos.fromJson(v))
            .toList() ??
        [];
    pureServiceAreaBusiness = json['pureServiceAreaBusiness'];
    googleMapsLinks = json['googleMapsLinks'] != null
        ? GoogleMapsLinks.fromJson(json['googleMapsLinks'])
        : null;
    timeZone =
        json['timeZone'] != null ? TimeZone.fromJson(json['timeZone']) : null;
  }
}

class AddressComponents {
  String? longText;
  String? shortText;
  List<String>? types;
  String? languageCode;

  AddressComponents(
      {this.longText, this.shortText, this.types, this.languageCode});

  AddressComponents.fromJson(Map<String, dynamic> json) {
    longText = json['longText'];
    shortText = json['shortText'];
    types =
        (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];
    languageCode = json['languageCode'];
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
  }
}

class Viewport {
  Location? low;
  Location? high;

  Viewport({this.low, this.high});

  Viewport.fromJson(Map<String, dynamic> json) {
    low = json['low'] != null ? Location.fromJson(json['low']) : null;
    high = json['high'] != null ? Location.fromJson(json['high']) : null;
  }
}

class DisplayName {
  String? text;
  String? languageCode;

  DisplayName({this.text, this.languageCode});

  DisplayName.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    languageCode = json['languageCode'];
  }
}

class Photos {
  String? name;
  int? widthPx;
  int? heightPx;
  List<AuthorAttributions>? authorAttributions;
  String? flagContentUri;
  String? googleMapsUri;

  Photos({
    this.name,
    this.widthPx,
    this.heightPx,
    this.authorAttributions,
    this.flagContentUri,
    this.googleMapsUri,
  });

  Photos.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    widthPx = json['widthPx'];
    heightPx = json['heightPx'];
    authorAttributions = (json['authorAttributions'] as List<dynamic>?)
            ?.map((v) => AuthorAttributions.fromJson(v))
            .toList() ??
        [];
    flagContentUri = json['flagContentUri'];
    googleMapsUri = json['googleMapsUri'];
  }
}

class AuthorAttributions {
  String? displayName;
  String? uri;
  String? photoUri;

  AuthorAttributions({this.displayName, this.uri, this.photoUri});

  AuthorAttributions.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    uri = json['uri'];
    photoUri = json['photoUri'];
  }
}

class GoogleMapsLinks {
  String? directionsUri;
  String? placeUri;
  String? photosUri;

  GoogleMapsLinks({this.directionsUri, this.placeUri, this.photosUri});

  GoogleMapsLinks.fromJson(Map<String, dynamic> json) {
    directionsUri = json['directionsUri'];
    placeUri = json['placeUri'];
    photosUri = json['photosUri'];
  }
}

class TimeZone {
  String? id;

  TimeZone({this.id});

  TimeZone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }
}
