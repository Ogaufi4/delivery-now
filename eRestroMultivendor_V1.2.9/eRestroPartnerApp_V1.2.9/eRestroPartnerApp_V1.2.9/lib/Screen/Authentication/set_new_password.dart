import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/api_base_helper.dart';
import '../../Helper/app_button.dart';
import '../../Helper/color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import 'login.dart';

class SetPass extends StatefulWidget {
  final String mobileNumber;

  const SetPass({
    Key? key,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SetPass> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final confirmpassController = TextEditingController();
  FocusNode? passFocus, confirmPassFocus = FocusNode();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? password, comfirmpass;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getResetPass();
    } else {
      Future.delayed(
        const Duration(seconds: 2),
      ).then(
        (_) async {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
          await buttonController!.reverse();
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

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, "TRY_AGAIN_INT_LBL")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
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

  Future<void> getResetPass() async {
    var data = {
      mobileno: widget.mobileNumber,
      NEWPASS: password,
    };
    apiBaseHelper.postAPICall(forgotPasswordApi, data, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          setsnackbar(msg!, context);
          Future.delayed(
            const Duration(seconds: 1),
          ).then(
            (_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => const Login(),
                ),
              );
            },
          );
        } else {
          setsnackbar(msg!, context);
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

  forgotpassTxt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, "FORGOT_PASSWORDTITILE")!,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
    buttonController!.dispose();
    super.dispose();
  }

  setPasswordNo() {
    return Container(
      decoration: boxDecorationContainer(white, 10.0),
      height: height / 16.0,
      padding: EdgeInsets.only(left: width / 20.0),
      margin: EdgeInsets.only(left: width / 35.0, right: width / 32.0, bottom: height / 60.0, top: height / 5.0),
      child: TextFormField(
        obscureText: true,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        controller: passwordController,
        decoration: InputDecoration(
          counterStyle: const TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: getTranslated(context, "PASSHINT_LBL")!,
          labelStyle: const TextStyle(
            color: lightFont,
            fontSize: 17.0,
          ),
          hintStyle: const TextStyle(
            color: black,
            fontSize: 17.0,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        keyboardType: TextInputType.text,
        focusNode: passFocus,
        onSaved: (String? value) {
          password = value;
        },
        onChanged: (String? value) {
          password = value;
        },
        validator: (val) => validatePass(val, context),
        style: const TextStyle(
          color: black,
          fontSize: 17.0,
        ),
      ),
    );
  }

  setConfirmPassword() {
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
        controller: confirmpassController,
        obscureText: true,
        decoration: InputDecoration(
          counterStyle: const TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: getTranslated(context, "CONFIRMPASSHINT_LBL")!,
          labelStyle: const TextStyle(
            color: lightFont,
            fontSize: 17.0,
          ),
          hintStyle: const TextStyle(
            color: black,
            fontSize: 17.0,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        keyboardType: TextInputType.text,
        focusNode: passFocus,
        onSaved: (String? value) {
          comfirmpass = value;
        },
        onChanged: (String? value) {
          comfirmpass = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return getTranslated(context, "CON_PASS_REQUIRED_MSG")!;
          }
          if (value != password) {
            return getTranslated(context, "CON_PASS_NOT_MATCH_MSG")!;
          } else {
            return null;
          }
        },
        style: const TextStyle(
          color: black,
          fontSize: 17.0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: width * 0.7,
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
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setPassBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: AppBtn(
        title: getTranslated(context, "SET_PASSWORD")!,
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );
    return Scaffold(
      backgroundColor: backgroundDark,
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: 15,
                    right: 15,
                    top: height / 17.0,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                welcome,
                                style: TextStyle(
                                  fontSize: 28.0,
                                  color: white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / 9.0),
                          SvgPicture.asset(
                            setSvgPath("app_logo"),
                            height: 120,
                            width: 120,
                          ),
                          setPasswordNo(),
                          setConfirmPassword(),
                          setPasswordButton(),
                          SizedBox(
                            height: height * 0.15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : noInternet(context),
    );
  }

  setPasswordButton() {
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
        child: Text(
          getTranslated(context, "SET_PASSWORD")!,
          style: const TextStyle(fontSize: 18.0, color: white),
        ),
      ),
    );
  }
}
