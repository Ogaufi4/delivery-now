import 'dart:async';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:project/Screen/Authentication/restorentRegistration.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../Helper/api_base_helper.dart';
import '../../Helper/app_button.dart';
import '../../Helper/color.dart';
import '../../Helper/constant.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../TermFeed/policys.dart';
import 'verify_otp.dart';

// ignore: must_be_immutable
class SendOtp extends StatefulWidget {
  String? title;

  SendOtp({Key? key, this.title}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    buttonController!.dispose();
    super.dispose();
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

  Future<void> getVerifyUser() async {
    var data = {Mobile: mobile, isForgotPassword: "1"};
    apiBaseHelper.postAPICall(verifyUserApi, data, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (widget.title == getTranslated(context, "SEND_OTP_TITLE")!) {
          if (!error) {
            setsnackbar(
              msg!,
              context,
            );
            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);
            Future.delayed(const Duration(seconds: 1)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtp(
                      mobileNumber: mobile!,
                      countryCode: countrycode,
                      title: getTranslated(context, "SEND_OTP_TITLE")!,
                    ),
                  ),
                );
              },
            );
          } else {
            setsnackbar(
              msg!,
              context,
            );
          }
        }
        if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")!) {
          if (!error) {
            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyOtp(
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: getTranslated(context, "FORGOT_PASS_TITLE")!,
                ),
              ),
            );
          } else {
            setsnackbar(msg!, context);
          }
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

  verifyCodeTxt() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslated(context, "SEND_VERIFY_CODE_LBL")!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: fontColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  setCountryCode() {
    return CountryCodePicker(
      showCountryOnly: false,
      searchDecoration: InputDecoration(
        hintText: getTranslated(context, "COUNTRY_CODE_LBL")!,
        fillColor: black,
      ),
      showOnlyCountryWhenClosed: false,
      initialSelection: countryCode,
      dialogSize: Size(width, height * 0.9),
      alignLeft: true,
      textStyle: const TextStyle(
        color: black,
        fontWeight: FontWeight.bold,
      ),
      onChanged: (CountryCode countryCode) {
        countrycode = countryCode.toString().replaceFirst("+267", "");
        countryName = countryCode.name;
      },
      onInit: (code) {
        countrycode = code.toString().replaceFirst("+267", "");
      },
    );
  }

  setMono() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: mobileController,
      style: const TextStyle(
        color: black,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String? value) {
        mobile = value;
      },
      validator: (val) => validateMob(val!, context),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: getTranslated(context, "Enter phone number")!,
        hintStyle: const TextStyle(
          color: lightFont,
          fontWeight: FontWeight.normal,
          fontSize: 17,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
      ),
    );
  }

  verifyBtn() {
    return AppBtn(
      title: widget.title == getTranslated(context, "SEND_OTP_TITLE") ? getTranslated(context, "Send OTP")! : getTranslated(context, "GET_PASSWORD")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  termAndPolicyTxt() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            getTranslated(context, "CONTINUE_AGREE_LBL")!,
            style: const TextStyle(
              color: fontColor,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(
            height: 3.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Policy(
                          title: getTranslated(context, "TERM_CONDITIONS")!,
                          index: 2,
                        ),
                      ));
                },
                child: Text(
                  getTranslated(context, "TERMS_SERVICE_LBL")!,
                  style: const TextStyle(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Text(
                getTranslated(context, "AND_LBL")!,
                style: const TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.normal,
                ),
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
                        title: getTranslated(context, "PRIVACYPOLICY")!,
                        index: 3,
                      ),
                    ),
                  );
                },
                child: Text(
                  getTranslated(context, "PRIVACYPOLICY")!,
                  style: const TextStyle(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.initState();
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
                          setMobileNo(),
                          loginButton(),
                          SizedBox(height: height * 0.15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  getTranslated(context, "CONTINUE_AGREE_LBL")!,
                                  style: const TextStyle(color: white, fontSize: 12.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Policy(
                                              title: getTranslated(context, "TERM_CONDITIONS")!,
                                              index: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        getTranslated(context, 'TERMS_SERVICE_LBL')!,
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 12.0,
                                          decoration: TextDecoration.underline,
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
                                              title: getTranslated(context, "PRIVACYPOLICY")!,
                                              index: 3,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        getTranslated(context, "PRIVACYPOLICY")!,
                                        style: const TextStyle(
                                          color: white,
                                          fontSize: 12.0,
                                          decoration: TextDecoration.underline,
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
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SellerRegister(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    getTranslated(context, "Register as New Restaurant")!,
                                    style: const TextStyle(
                                      color: white,
                                      fontSize: 12.0,
                                      decoration: TextDecoration.underline,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
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
        child: Text(
          getTranslated(context, "Submit")!,
          style: const TextStyle(
            fontSize: 18.0,
            color: white,
          ),
        ),
      ),
    );
  }

  Widget verifyCodeTxt1() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslated(context, "SEND_VERIFY_CODE_LBL")!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: fontColor,
            fontWeight: FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
    );
  }

  setMobileNo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: white,
      ),
      width: width * 0.9,
      margin: EdgeInsets.only(bottom: height / 60.0, top: height / 5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: setCountryCode(),
          ),
          Expanded(
            flex: 5,
            child: setMono(),
          ),
        ],
      ),
    );
  }
}
