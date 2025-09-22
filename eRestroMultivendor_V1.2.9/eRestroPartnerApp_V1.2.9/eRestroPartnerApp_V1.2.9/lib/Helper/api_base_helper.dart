import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Helper/color.dart';
import 'package:project/Helper/string.dart';
import 'package:project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'constant.dart';
import 'session.dart';

class ApiBaseHelper {
  Future<dynamic> postAPICall(Uri url, Map parameter, BuildContext? context) async {
    var responseJson;

    try {
      final response = await post(url, body: parameter.isNotEmpty ? parameter : null, headers: await ApiUtils.getHeaders())
          .timeout(const Duration(seconds: timeOut));

      debugPrint("Parameter = $parameter, \nAPI = $url,\nresponse : ${response.body.toString()}");
      if (response.statusCode == 503) {
        appMaintenanceDialog();
      }
      var data = Map.from(jsonDecode(response.body));

      if (data[statusCode].toString() == "102") {
        debugPrint("-----code-----");
        reLogin(context!);
      } else {
        responseJson = _response(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    } catch (e) {
      print("error:$e");
    }

    return responseJson;
  }

  void appMaintenanceDialog() async {
    await dialogAnimate(
      navigatorKey.currentContext!,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (value, dynamic) async {},
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    setSvgPath(
                      "Maintenance",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      getTranslated(context, 'APP_MAINTENANCE')!,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 503:
        return appMaintenanceDialog();
      case 500:
      default:
        throw FetchDataException('Error occurred while Communication with Server with StatusCode: ${response.statusCode}');
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
  FetchDataException([message]) : super(message, "Error During Communication: ");
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
