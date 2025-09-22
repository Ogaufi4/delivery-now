import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/Helper/keyboardOverlay.dart';
import 'package:project/RegistrationScreen.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'Privacy_Policy.dart';
import 'Send_Otp.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController(text: "1234567890");
  final passwordController = TextEditingController(text: "12345678");
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  bool _showPassword = false;
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      commMethod,
      comm,
      active,
      address,
      balance,
      token;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.8,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        setState(() {
          _isNetworkAvail = false;
        });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
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

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kToolbarHeight),
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
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget));
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

  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<void> getLoginUser() async {
    String fcmToken = await getFCMToken();
    var data = {
      MOBILE: mobile,
      PASSWORD: password,
      DEVICETYPE: Platform.isAndroid ? "android" : "ios",
      FCM_ID: fcmToken
    };
    try {
      apiBaseHelper.postAPICall(getUserLoginApi, data, context).then(
          (getdata) async {
        print("getdata*****$getdata");
        bool error = getdata["error"];
        String? msg = getdata["message"];
        token = getdata["token"];
        await buttonController!.reverse();
        if (!error) {
          setSnackbar(msg!);
          var i = getdata["data"];
          id = i[ID];
          username = i[USERNAME];
          email = i[EMAIL];
          mobile = i[MOBILE];
          balance = double.parse(i[BALANCE]).toStringAsFixed(2);
          String tempCom = i[COM_METHOD];
          commMethod = tempCom.replaceAll("_", " ");
          comm = i[COMMISSION];
          address = i[ADDRESS];
          active = i[ACTIVE];

          // Save profile image URL
          String? profileImageUrl = i[IMAGE];
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            await setPrefrence('profile_image', profileImageUrl);
          }

          CUR_USERID = id;
          CUR_USERNAME = username;
          CUR_BALANCE = balance!;

          saveUserDetail(id!, username!, email!, mobile!, address!, commMethod!,
              comm!, active!, balance!, token!);
          setPrefrenceBool(isLogin, true);
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const Home(),
              ));
        } else {
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setSnackbar(error.toString());
      });
    } on TimeoutException catch (_) {
      await buttonController!.reverse();
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }
  }

  signInTxt() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            getTranslated(context, 'SIGNIN_LBL')!,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
          ),
        ));
  }

  termAndPolicyTxt() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(
          bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(getTranslated(context, 'CONTINUE_AGREE_LBL')!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: white, fontWeight: FontWeight.normal)),
          const SizedBox(
            height: 3.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => PrivacyPolicy(
                                title: getTranslated(context, 'TERM'),
                              )));
                },
                child: Text(
                  getTranslated(context, 'TERMS_SERVICE_LBL')!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
            const SizedBox(
              width: 5.0,
            ),
            Text(getTranslated(context, 'AND_LBL')!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: white, fontWeight: FontWeight.normal)),
            const SizedBox(
              width: 5.0,
            ),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => PrivacyPolicy(
                                title: getTranslated(context, 'PRIVACY'),
                              )));
                },
                child: Text(
                  getTranslated(context, 'PRIVACY_POLICY_LBL')!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
          ]),
        ],
      ),
    );
  }

  setMobileNo() {
    return Container(
      width: deviceWidth! * 0.8,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(
        top: deviceHeight * 0.18,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style:
            const TextStyle(color: darkFontColor, fontWeight: FontWeight.bold),
        focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) => validateField(value, context),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.call_outlined,
            color: darkFontColor,
            size: 20,
          ),
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
          filled: true,
          fillColor: textFieldBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 45, maxHeight: 25),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: darkFontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: textFieldBackground),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Container(
        width: deviceWidth! * 0.8,
        padding: const EdgeInsets.only(top: 25.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !_showPassword,
          focusNode: passFocus,
          style: const TextStyle(
              color: darkFontColor, fontWeight: FontWeight.bold),
          controller: passwordController,
          validator: (value) => validateField(value, context),
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: darkFontColor,
              size: 20,
            ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: textFieldBackground,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 45, maxHeight: 25),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: darkFontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: textFieldBackground),
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: darkFontColor),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
        ));
  }

  forgetPass() {
    return Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => SendOtp(
                              title:
                                  getTranslated(context, 'FORGOT_PASS_TITLE'),
                            )));
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: white, fontWeight: FontWeight.normal)),
            ),
          ],
        ));
  }

  registerRider() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 40.0, right: 40.0, top: 15.0, bottom: 15.0),
      child: RichText(
        text: TextSpan(
          text: "${getTranslated(context, 'LETS_GET_YOU_ON_BOARD')!} ",
          style: TextStyle(
              fontSize: 14,
              color: white.withValues(alpha: 0.76),
              fontWeight: FontWeight.w500),
          children: <TextSpan>[
            TextSpan(
              text: getTranslated(context, 'CREATE_YOUR_ACCOUNT')!,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => RegistrationScreen()));
                },
            ),
          ],
        ),
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, 'SIGNIN_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: backgroundDark,
          body: _isNetworkAvail
              ? SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.only(
                              top: deviceHeight * 0.18,
                            ),
                            child: SvgPicture.asset(
                              setSvgPath("app_logo"),
                              height: 90,
                              width: 90,
                              fit: BoxFit.contain,
                            )),
                        setMobileNo(),
                        setPass(),
                        forgetPass(),
                        loginBtn(),
                        registerRider(),
                        termAndPolicyTxt(),
                      ],
                    ),
                  ),
                )
              : noInternet(context)),
    );
  }
}
