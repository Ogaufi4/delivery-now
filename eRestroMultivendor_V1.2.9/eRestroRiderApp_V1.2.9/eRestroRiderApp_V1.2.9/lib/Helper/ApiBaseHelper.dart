import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:project/Helper/String.dart';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/MaintainanceScreen.dart';

import '../Login.dart';
import 'Constant.dart';
import 'Session.dart';

class ApiBaseHelper {
  Future<dynamic> postAPICall(Uri url, Map param, BuildContext context) async {
    var responseJson;
    try {
      final response = await post(url,
              body: param.isNotEmpty ? param : null,
              headers: await ApiUtils.getHeaders())
          .timeout(const Duration(seconds: timeOut));
      print("param****$param****$url");
      print("respon****${response.statusCode}--${response.body}");
      if (response.statusCode == 503) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MaintainanceScreen(),
            ));
      }
      var data = Map.from(jsonDecode(response.body));

      if (data[statusCode].toString() == "102") {
        debugPrint("-----code-----");
        clearUserSession();
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }

      responseJson = _response(response, context);

      print("responjson****$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }

    return responseJson;
  }

  Future<dynamic> postMultipartAPICall(Uri url, Map<String, String?> fields,
      File? file, String? fileField, BuildContext context) async {
    var responseJson;
    try {
      var request = MultipartRequest('POST', url);
      request.headers.addAll(await ApiUtils.getHeaders());
      fields.forEach((key, value) {
        if (value != null) request.fields[key] = value;
      });
      if (file != null && fileField != null) {
        request.files.add(await MultipartFile.fromPath(fileField, file.path));
      }
      var streamedResponse =
          await request.send().timeout(const Duration(seconds: timeOut));
      var response = await Response.fromStream(streamedResponse);
      print("multipart param****$fields****$url");
      print("multipart file****${file?.path}");
      print("respon****${response.statusCode}--${response.body}");
      if (response.statusCode == 503) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MaintainanceScreen(),
            ));
      }
      var data = Map.from(jsonDecode(response.body));
      if (data[statusCode].toString() == "102") {
        debugPrint("-----code-----");
        clearUserSession();
        Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
      responseJson = _response(response, context);
      print("responjson****$responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }
    return responseJson;
  }

  dynamic _response(Response response, BuildContext context) {
    print("response.statusCode:${response.statusCode}");
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        var data = Map.from(jsonDecode(response.body));
        if (data[statusCode].toString() == "102") {
          clearUserSession();
          Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        }
        break;
      case 503:
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => MaintainanceScreen(),
            ));
        break;
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}

class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
