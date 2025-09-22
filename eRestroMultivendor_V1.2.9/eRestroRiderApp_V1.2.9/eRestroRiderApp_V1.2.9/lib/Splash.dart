import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/Home.dart';

import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getSetting();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundDark,
        body: Stack(fit: StackFit.expand, children: [
          Center(child: SvgPicture.asset(setSvgPath("app_logo"))),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                getTranslated(context, 'MADE_BY_LBL')!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold),
              ),
              Padding(padding: const EdgeInsets.only(top: 10.0), child: SvgPicture.asset(setSvgPath("made_by")))
            ]),
          )
        ]));
  }

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(isLogin);

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const Login(),
          ));
    }
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter = {TYPE: SYSTEM_SETTINGS};
      apiBaseHelper.postAPICall(getSettingApi, parameter, context).then((getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
          Is_RIDER_OTP_SETTING_ON = data[IsRIDER_OTP_SETTING_ON];
          AUTHENTICATION_METHOD = (getdata['authentication_mode'] ?? 0).toString();

          CUR_CURRENCY = getdata["currency"] ?? "";
        } else {
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setSnackbar(error.toString());
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    } on FormatException catch (e) {
      setSnackbar(e.message);
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
