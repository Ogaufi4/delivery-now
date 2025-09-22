import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../Authentication/login.dart';
import '../home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );

    super.initState();
    getSetting();
    startTime();
  }

  Future<void> getSetting() async {
    Map parameter = {};

    apiBaseHelper.postAPICall(getSettingsApi, parameter, context).then(
      (getdata) async {
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          var data = getdata['data']['system_settings'][0];
          Is_APP_IN_MAINTANCE = data['is_partner_app_maintenance_mode_on'];
          AUTHENTICATION_METHOD = (getdata['authentication_mode'] ?? 0).toString();
          TAXGLOBAL = data['tax'];
          setState(
            () {},
          );
        } else {
          setsnackbar(
            msg!,
            context,
          );
        }
      },
      onError: (error) {
        setsnackbar(
          error.toString(),
          context,
        );
      },
    );
  }

//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundDark,
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        height: height / 9.0,
        color: backgroundDark,
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                getTranslated(context, "Made By")!,
                style: const TextStyle(
                  color: grey1,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: height / 60.0),
              SvgPicture.asset(
                setSvgPath("made_by"),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: backgroundDark,
        alignment: Alignment.center,
        child: Center(
          child: SvgPicture.asset(
            setSvgPath("app_logo"),
          ),
        ),
      ),
    );
  }

  startTime() async {
    var duration = const Duration(seconds: 3);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(isLogin);

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }

  @override
  void dispose() async {
    super.dispose();
    bool isFirstTime = await getPrefrenceBool(isLogin);
    if (isFirstTime) {
      // go to home
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
        ),
      );
    } else {
      // go to login
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
        ),
      );
    }
  }
}
