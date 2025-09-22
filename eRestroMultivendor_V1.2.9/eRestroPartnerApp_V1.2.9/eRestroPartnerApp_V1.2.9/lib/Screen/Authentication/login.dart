import 'dart:async';
import 'dart:io';
import 'package:project/Helper/keyboardOverlay.dart';
import 'package:project/Screen/Authentication/restorentRegistration.dart';
import 'package:project/Screen/Authentication/send_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/api_base_helper.dart';
import '../../Helper/app_button.dart';
import '../../Helper/color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../TermFeed/policys.dart';
import '../home.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
//============================= Variables Declaration ==========================

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController mobilenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode? passFocus, monoFocus = FocusNode();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  String? password,
      mobile,
      username,
      email,
      id,
      balance,
      image,
      address,
      city,
      area,
      pincode,
      srorename,
      storeurl,
      storeDesc,
      accNo,
      accname,
      bankCode,
      bankName,
      latitutute,
      longitude,
      taxname,
      taxNumber,
      panNumber,
      status,
      jwtToken,
      storeLogo;
  bool _isNetworkAvail = true;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  bool _showPassword = false;

//============================= INIT Method ====================================

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: width,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    super.initState();

    setState(
      () {
        mobilenumberController.text = "72185492";
        mobile = "72185492";
        passwordController.text = "12345678";
        password = "12345678";
      },
    );
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
  }

//========================= For Animation ======================================

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//============================= validateAndSubmit ==============================

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

//============================= Network Checking ===============================

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
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

//============================= Dispose Method =================================

  @override
  void dispose() {
    buttonController!.dispose();

    super.dispose();
  }

//============================= No Internet Widget =============================

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: kToolbarHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget),
                      );
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  //fcmTocken
  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

//============================= LOGIN API ======================================

  Future<void> getLoginUser() async {
    String fcmToken = await getFCMToken();
    var data = {
      Mobile: mobile,
      Password: password,
      DEVICETYPE: Platform.isAndroid ? "android" : "ios",
      FCMID: fcmToken,
    };

    apiBaseHelper.postAPICall(getUserLoginApi, data, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          setSnackbarForLogin(scaffoldMessengerKey, context, msg!);

          var data = getdata["data"];
          id = data["partner_id"];
          username = data["owner_name"];
          email = data[Email];
          mobile = data[Mobile];
          city = data[City];
          area = data[Area];
          address = data["partner_address"];
          pincode = data[Pincode];
          image = data[IMage];
          balance = data["balance"];
          CUR_USERID = id!;
          CUR_USERNAME = username!;
          CUR_BALANCE = balance!;
          srorename = data[StoreName] ?? "";
          storeDesc = data[storeDescription] ?? "";
          accNo = data[accountNumber] ?? "";
          accname = data[accountName] ?? "";
          bankCode = data[BankCOde] ?? "";
          bankName = data[bankNAme] ?? "";
          latitutute = data[Latitude] ?? "";
          longitude = data[Longitude] ?? "";
          taxname = data[taxName] ?? "";
          taxNumber = data[taxNumber] ?? "";
          panNumber = data[panNumber] ?? "";
          status = data[STATUS] ?? "";
          storeLogo = data[StoreLogo] ?? "";
          var cityid = data["city_id"];
          var cityname = data["city_name"];
          jwtToken = getdata[token] ?? "";
          JWT_TOCKEN = jwtToken!;

          saveUserDetail(
              id!,
              username!,
              email!,
              mobile!,
              address!,
              srorename!,
              storeDesc!,
              accNo!,
              accname!,
              bankCode ?? "",
              bankName ?? "",
              latitutute ?? "",
              longitude ?? "",
              taxname ?? "",
              taxNumber!,
              panNumber!,
              status!,
              storeLogo!,
              cityid,
              cityname,
              jwtToken!);
          setPrefrenceBool(isLogin, true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
          );
        } else {
          setSnackbarForLogin(scaffoldMessengerKey, context, msg!);
          await buttonController!.reverse();

          setState(
            () {},
          );
        }
      },
      onError: (error) {
        setSnackbarForLogin(scaffoldMessengerKey, context, error.toString());
      },
    );
  }

//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: backgroundDark,
          key: _scaffoldKey,
          body: _isNetworkAvail
              ? Form(
                  key: _formkey,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom,
                            left: 15,
                            right: 15,
                            top: height / 17.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: height / 9.0),
                              SvgPicture.asset(
                                setSvgPath("app_logo"),
                                height: 120,
                                width: 120,
                              ),
                              setMobileNo(),
                              setPass(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SendOtp(
                                            title: getTranslated(
                                                context, "FORGOT_PASS_TITLE")!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Text(
                                        getTranslated(
                                            context, "Forgot Password ?")!,
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              AppBtn(
                                title: getTranslated(context, "Submit")!,
                                btnAnim: buttonSqueezeanimation,
                                btnCntrl: buttonController,
                                padding: 0.0,
                                index: 1,
                                onBtnSelected: () async {
                                  validateAndSubmit();
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SellerRegister(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Text(
                                        getTranslated(context,
                                            "Register as New Restaurant")!,
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.08),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      getTranslated(
                                          context, "CONTINUE_AGREE_LBL")!,
                                      style: const TextStyle(
                                          color: white, fontSize: 12.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Policy(
                                                  title: getTranslated(context,
                                                      "TERM_CONDITIONS")!,
                                                  index: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            getTranslated(
                                                context, 'TERMS_SERVICE_LBL')!,
                                            style: const TextStyle(
                                              color: white,
                                              fontSize: 12.0,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          getTranslated(context, "AND_LBL")!,
                                          style: const TextStyle(
                                            color: white,
                                            fontSize: 12.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Policy(
                                                  title: getTranslated(context,
                                                      "PRIVACYPOLICY")!,
                                                  index: 3,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            getTranslated(
                                                context, "PRIVACYPOLICY")!,
                                            style: const TextStyle(
                                              color: white,
                                              fontSize: 12.0,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const Text(
                                          " ,",
                                          style: TextStyle(
                                            color: white,
                                            fontSize: 12.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : noInternet(context),
        ),
      ),
    );
  }

  setMobileNo() {
    return Container(
      decoration: boxDecorationContainer(white, 10.0),
      height: height / 16.0,
      padding: EdgeInsets.only(left: width / 20.0),
      margin: EdgeInsets.only(
          left: width / 35.0,
          right: width / 32.0,
          bottom: height / 60.0,
          top: height / 5.0),
      child: TextFormField(
        controller: mobilenumberController,
        decoration: const InputDecoration(
          counterStyle: TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: enterphonenumber,
          labelStyle: TextStyle(
            color: lightFont,
            fontSize: 17.0,
          ),
          hintStyle: TextStyle(
            color: black,
            fontSize: 17.0,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        keyboardType: TextInputType.number,
        focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
        onSaved: (String? value) {
          mobile = value;
        },
        onChanged: (String? value) {
          mobile = value;
        },
        validator: (val) => validateMob(val!, context),
        style: const TextStyle(
          color: black,
          fontSize: 17.0,
        ),
      ),
    );
  }

  setPass() {
    return Container(
      decoration: boxDecorationContainer(white, 10.0),
      height: height / 16.0,
      padding: EdgeInsets.only(left: width / 20.0),
      margin: EdgeInsets.only(
        left: width / 35.0,
        right: width / 32.0,
        bottom: height / 60.0,
        top: height / 99.0,
      ),
      child: TextFormField(
        controller: passwordController,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          counterStyle: const TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: enterPassword,
          labelStyle: TextStyle(
            color: lightFont,
            fontSize: 17.0,
          ),
          hintStyle: const TextStyle(
            color: black,
            fontSize: 17.0,
          ),
          isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 15),
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,
                color: black),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
        ),
        keyboardType: TextInputType.text,
        focusNode: passFocus,
        onSaved: (String? value) {
          password = value;
        },
        onChanged: (String? value) {
          password = value;
        },
        validator: (val) => validatePass(val!, context),
        style: const TextStyle(
          color: black,
          fontSize: 17.0,
        ),
      ),
    );
  }

  loginButton() {
    return TextButton(
      onPressed: () async {
        validateAndSubmit();
      },
      child: Container(
        width: width,
        alignment: Alignment.center,
        decoration: boxDecorationContainer(primary, 10.0),
        margin: EdgeInsets.only(bottom: height / 20.0),
        padding: const EdgeInsets.all(12),
        child: const Text(
          login,
          style: TextStyle(
            fontSize: 18.0,
            color: white,
          ),
        ),
      ),
    );
  }
}
