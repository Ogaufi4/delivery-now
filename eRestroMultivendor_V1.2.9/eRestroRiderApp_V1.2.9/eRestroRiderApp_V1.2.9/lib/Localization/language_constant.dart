import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

const String LAGUAGE_CODE = 'languageCode';

// Global Language Variable
String? languageFlag;

//languages code
const String ENGLISH = 'en';
const String HINDI = 'hi';
const String URDU = 'ur';

Locale? loc;
int lang = 0;
Future<Locale> setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(LAGUAGE_CODE) ?? "en";
  languageFlag = languageCode;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case HINDI:
      return const Locale(HINDI, "IN");
    case URDU:
      return const Locale(URDU, "IN"); //if you uder india urdu language then pass IN, and if use pakistan urdu then pass PK
    default:
      return const Locale(ENGLISH, 'US');
  }
}

void changeLanguage(BuildContext context, String language) async {
  languageFlag = language;
  Locale loc = await setLocale(language);
  MyApp.setLocale(context, loc);
}
