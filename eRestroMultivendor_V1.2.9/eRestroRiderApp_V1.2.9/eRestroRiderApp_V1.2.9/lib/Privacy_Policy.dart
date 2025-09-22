import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'package:html/dom.dart' as dom;

import 'Home.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;

  const PrivacyPolicy({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? privacy;
  String url = "";
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    super.initState();
    getSetting();
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            key: _scaffoldKey,
            backgroundColor: white,
            appBar: getAppBar(widget.title!, context),
            body: getProgress(),
          )
        : privacy != ""
            ? Scaffold(
                key: _scaffoldKey,
                backgroundColor: white,
                appBar: getAppBar(widget.title!, context),
                body: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                        height: deviceHeight,
                        padding: const EdgeInsets.only(top: 25.0, bottom: 10.0, right: 13.0, left: 13.0),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
                            color: white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, -9),
                                blurRadius: 10,
                                spreadRadius: 0,
                                color: shadowColor,
                              )
                            ]),
                        child: SingleChildScrollView(
                            child: Html(
                          data: privacy,
                          onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) async {
                            if (!await launchUrlString(url!, mode: LaunchMode.externalApplication)) {
                              throw 'Could not launch $url';
                            }
                          },
                        )))))
            : Scaffold(
                key: _scaffoldKey,
                appBar: getAppBar(widget.title!, context),
                backgroundColor: white,
                body: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: deviceHeight,
                      padding: const EdgeInsets.only(top: 10.0),
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
                          color: white,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -9),
                              blurRadius: 10,
                              spreadRadius: 0,
                              color: shadowColor,
                            )
                          ]),
                      child: _isNetworkAvail ? Container() : noInternet(context),
                    )));
  }

  Future<void> getSetting() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        String? type;
        if (widget.title == getTranslated(context, 'PRIVACY')) {
          type = PRIVACY_POLLICY;
        } else if (widget.title == getTranslated(context, 'TERM')) {
          type = TERM_COND;
        }

        var parameter = {TYPE: type};
        apiBaseHelper.postAPICall(getSettingApi, parameter, context).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            privacy = getdata["data"].toString();
          } else {
            setSnackbar(msg!);
          }
          setState(() {
            _isLoading = false;
          });
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isLoading = false;
        _isNetworkAvail = false;
      });
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
}
