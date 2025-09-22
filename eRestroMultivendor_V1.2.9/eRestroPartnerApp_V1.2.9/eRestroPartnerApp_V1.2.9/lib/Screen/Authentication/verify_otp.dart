import 'dart:async';
import 'package:project/Screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Helper/color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import 'set_new_password.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;

  const VerifyOtp({Key? key, required String this.mobileNumber, this.countryCode, this.title}) : super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password, mobile, countrycode;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
      ),
    );
    super.initState();
    getUserDetails();
    if (AUTHENTICATION_METHOD == "1") {
    } else {
      getSingature();
      _onVerifyCode();
    }
    Future.delayed(const Duration(seconds: 60)).then(
      (_) {
        _isClickable = true;
      },
    );
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

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(Mobile);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(
      () {},
    );
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setsnackbar(
          getTranslated(context, "OTPWR")!,
          context,
        );
      }
    } else {
      setState(
        () {},
      );

      Future.delayed(const Duration(seconds: 60)).then(
        (_) async {
          bool avail = await isNetworkAvailable();
          if (avail) {
            if (_isClickable) {
              _onVerifyCode();
            } else {
              setsnackbar(
                getTranslated(context, "OTPWR")!,
                context,
              );
            }
          } else {
            await buttonController!.reverse();
            setsnackbar(
              getTranslated(context, "somethingMSg")!,
              context,
            );
          }
        },
      );
    }
  }

  void _onVerifyCode() async {
    setState(
      () {
        isCodeSent = true;
      },
    );

    verificationCompleted(AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential).then(
        (UserCredential value) {
          if (value.user != null) {
            setsnackbar(
              getTranslated(context, "OTPMSG")!,
              context,
            );
            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);
            if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")!) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SetPass(mobileNumber: mobile!),
                ),
              );
            }
          } else {
            setsnackbar(
              getTranslated(context, "OTPERROR")!,
              context,
            );
          }
        },
      ).catchError(
        (error) {
          setsnackbar(
            error.toString(),
            context,
          );
        },
      );
    }

    verificationFailed(FirebaseAuthException authException) {
      setsnackbar(authException.message!, context);

      setState(
        () {
          isCodeSent = false;
        },
      );
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      setState(
        () {
          _verificationId = verificationId;
        },
      );
    }

    codeAutoRetrievalTimeout(String verificationId) {
      _verificationId = verificationId;
      setState(
        () {
          _isClickable = true;
          _verificationId = verificationId;
        },
      );
    }

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);

      _firebaseAuth.signInWithCredential(authCredential).then(
        (UserCredential value) async {
          if (value.user != null) {
            await buttonController!.reverse();
            setsnackbar(
              getTranslated(context, "OTPMSG")!,
              context,
            );
            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);
            if (widget.title == getTranslated(context, "SEND_OTP_TITLE")) {
            } else if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")) {
              Future.delayed(const Duration(seconds: 2)).then(
                (_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetPass(mobileNumber: mobile!),
                    ),
                  );
                },
              );
            }
          } else {
            setsnackbar(
              getTranslated(context, "OTPERROR")!,
              context,
            );
            await buttonController!.reverse();
          }
        },
      ).catchError(
        (error) async {
          setsnackbar(
            error.toString(),
            context,
          );

          await buttonController!.reverse();
        },
      );
    } else {
      setsnackbar(
        getTranslated(context, "ENTEROTP")!,
        context,
      );
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    var data = {Mobile: mobile, Otp: controller.text};
    apiBaseHelper.postAPICall(verifyOtpApi, data, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          setsnackbar(
            msg!,
            context,
          );
          setPrefrence(Mobile, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          if (widget.title == getTranslated(context, "SEND_OTP_TITLE")) {
          } else if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")) {
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetPass(mobileNumber: mobile!),
                  ),
                );
              },
            );
          }
        } else {
          setsnackbar(
            getTranslated(context, "OTPERROR")!,
            context,
          );
          await buttonController!.reverse();
        }
      },
      onError: (error) async {
        setsnackbar(
          "something wrong",
          context,
        );
      },
    );
  }

  Future<void> resendOtp() async {
    var data = {Mobile: mobile};
    apiBaseHelper.postAPICall(resendOtpApi, data, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          setsnackbar(
            msg!,
            context,
          );
          setPrefrence(Mobile, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
        } else {
          setsnackbar(
            getTranslated(context, "OTPERROR")!,
            context,
          );
          await buttonController!.reverse();
        }
      },
      onError: (error) async {
        setsnackbar(
          "something wrong",
          context,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: Container(
        alignment: Alignment.topCenter,
        child: Form(
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height / 15.0),
                  Text(
                    getTranslated(context, "OTP verification")!,
                    style: const TextStyle(
                      fontSize: 28.0,
                      color: black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.1),
                  Text(
                    getTranslated(context, "Please enter verification code")!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    getTranslated(context, "sent by SMS on your mobile number")!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    "+$countrycode - $mobile",
                    style: const TextStyle(fontSize: 20.0, color: black),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width / 20.0, bottom: 10.0, right: width / 15.0, top: height / 15.0),
                    child: PinFieldAutoFill(
                      controller: controller,
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: PinListenColorBuilder(black, lightFont),
                        textStyle: const TextStyle(color: black, fontSize: 28, fontWeight: FontWeight.w600),
                        gapSpace: 8.0,
                      ),
                      currentCode: otp,
                      codeLength: 6,
                      onCodeChanged: (String? code) {
                        otp = code;
                        if (controller.text.length == 6 || controller.text.length == 5) {
                          setState(() {});
                        }
                      },
                      onCodeSubmitted: (String code) {
                        otp = code;
                      },
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        if (AUTHENTICATION_METHOD == "1") {
                          verifyOtp();
                        } else {
                          _onFormSubmitted();
                        }
                      } else {
                        setsnackbar(getTranslated(context, 'ENTEROTP')!, context);
                      }
                    },
                    child: Container(
                      width: width,
                      alignment: Alignment.center,
                      decoration: boxDecorationContainerBorder(
                          controller.text.length == 6 ? red : commentBoxBorderColor, controller.text.length == 6 ? red : white, 10.0),
                      margin: EdgeInsets.only(bottom: height / 20.0, left: width / 20.0, right: width / 20.0, top: height / 20.0),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        getTranslated(context, "OTP_ENTER")!,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: controller.text.length == 6 ? white : commentBoxBorderColor,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    getTranslated(context, "Didn't get code yet? ")!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height / 99.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          if (AUTHENTICATION_METHOD == "1") {
                            resendOtp();
                          } else {
                            checkNetworkOtp();
                          }
                        },
                        child: Text(
                          getTranslated(context, "RESEND_OTP")!,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: red,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
