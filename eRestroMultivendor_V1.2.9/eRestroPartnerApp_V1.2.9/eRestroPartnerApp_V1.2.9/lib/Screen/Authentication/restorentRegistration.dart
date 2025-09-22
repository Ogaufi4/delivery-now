import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/Map.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../Helper/api_base_helper.dart';
import '../../Helper/app_button.dart';
import '../../Helper/color.dart';
import '../../Helper/constant.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../../Model/city/cityModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

class SellerRegister extends StatefulWidget {
  const SellerRegister({Key? key}) : super(key: key);

  @override
  _SellerRegisterState createState() => _SellerRegisterState();
}

String? latitutute, longitude;
List<String> profileImage = [];

class _SellerRegisterState extends State<SellerRegister>
    with TickerProviderStateMixin {
//============================= Variables Declaration ==========================
  List<Map<String, dynamic>> workingDaysvar = [];

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<CityModel> citySearchLIst = [];
  List<CityModel> cityList = [];
  bool _isNetworkAvail = true;
  bool cityLoading = true;
  String restorentsStatus = "2";
  StateSetter? cityState;
  int? selCityPos = -1;
  var addressProfFile, nationalIdentityCardFile, storeLogoFile;
  List<File> licenceProofFile = [];
  late Future<TimeOfDay?> selectedTime24Hour;
  String selfPickup = "1";
  String deliveryOrdersStatus = '1';
  //morning time
  TimeOfDay timeSunM = const TimeOfDay(hour: 09, minute: 00),
      timeMonM = const TimeOfDay(hour: 09, minute: 00),
      timeTueM = const TimeOfDay(hour: 09, minute: 00),
      timeWedM = const TimeOfDay(hour: 09, minute: 00),
      timeThuM = const TimeOfDay(hour: 09, minute: 00),
      timeFriM = const TimeOfDay(hour: 09, minute: 00),
      timeSatM = const TimeOfDay(hour: 09, minute: 00);
  // evening time
  TimeOfDay timeSunE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeMonE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeTueE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeWedE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeThuE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeFriE = const TimeOfDay(hour: 06, minute: 00);
  TimeOfDay timeSatE = const TimeOfDay(hour: 06, minute: 00);
  bool? suncheck = true,
      moncheck = true,
      tuecheck = true,
      wedcheck = true,
      thucheck = true,
      fricheck = true,
      satcheck = true;
  int type = 1;
  String? ownerName,
      email,
      mobile,
      address,
      image,
      curPass,
      newPass,
      confPass,
      loaction,
      accNo,
      storename,
      cookingtime,
      storeDesc,
      accname,
      bankname,
      bankcode,
      taxname,
      taxnumber,
      pannumber,
      status,
      storelogo,
      city,
      password,
      confirmPassword,
      licenceName,
      licenceCode;
  FocusNode? nameFocus,
      emailFocus,
      mobileFocus,
      addressFocus,
      curPassFocuss,
      newPassFocuss,
      confPassFocus,
      loactionFocus,
      accNoFocus,
      storenameFocus,
      cookingtimeFocus,
      storeDescFocus,
      accnameFocus,
      banknameFocus,
      bankcodeFocus,
      latitututeFocus,
      longitudeFocus,
      taxnameFocus,
      taxnumberFocus,
      pannumberFocus,
      statusFocus,
      storelogoFocus,
      cityFocus,
      passwordFocus,
      licenceNameFocus,
      licenceCodeFocus,
      confirmPasswordFocus = FocusNode();
  GlobalKey<FormState> sellernameKey = GlobalKey<FormState>();
  GlobalKey<FormState> mobilenumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> emailKey = GlobalKey<FormState>();
  GlobalKey<FormState> addressKey = GlobalKey<FormState>();
  GlobalKey<FormState> storenameKey = GlobalKey<FormState>();
  GlobalKey<FormState> storeurlKey = GlobalKey<FormState>();
  GlobalKey<FormState> storeDescKey = GlobalKey<FormState>();
  GlobalKey<FormState> accnameKey = GlobalKey<FormState>();
  GlobalKey<FormState> accnumberKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  GlobalKey<FormState> bankcodeKey = GlobalKey<FormState>();
  GlobalKey<FormState> banknameKey = GlobalKey<FormState>();
  GlobalKey<FormState> latitututeKey = GlobalKey<FormState>();
  GlobalKey<FormState> longituteKey = GlobalKey<FormState>();
  GlobalKey<FormState> taxnameKey = GlobalKey<FormState>();
  GlobalKey<FormState> taxnumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> pannumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> licenceNameKey = GlobalKey<FormState>();
  GlobalKey<FormState> licenceCodeKey = GlobalKey<FormState>();
  TextEditingController? nameC,
      emailC,
      mobileC,
      addressC,
      storenameC,
      storeurlC,
      storeDescC,
      accnameC,
      accnumberC,
      bankcodeC,
      banknameC,
      latitututeC,
      longituteC,
      taxnameC,
      taxnumberC,
      pannumberC,
      curPassC,
      newPassC,
      confPassC,
      unusedC,
      passwordC,
      confirmPasswordC,
      licenceNameC,
      licenceCodeC;
  bool obscureConfirmPassword = true, obscurePassword = true;

//============================= INIT Method ====================================

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    getCities();
    profileImage = [];

    mobileC = TextEditingController();
    nameC = TextEditingController();
    emailC = TextEditingController();
    newPassC = TextEditingController();
    confPassC = TextEditingController();
    addressC = TextEditingController();
    storenameC = TextEditingController();
    storeurlC = TextEditingController();
    storeDescC = TextEditingController();
    accnameC = TextEditingController();
    accnumberC = TextEditingController();
    bankcodeC = TextEditingController();
    banknameC = TextEditingController();
    latitututeC = TextEditingController();
    longituteC = TextEditingController();
    taxnameC = TextEditingController();
    pannumberC = TextEditingController();
    taxnumberC = TextEditingController();
    licenceNameC = TextEditingController();
    licenceCodeC = TextEditingController();

    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

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
    _cityController.addListener(() {
      citySearch(_cityController.text);
    });
  }

  Future<void> getCities() async {
    try {
      Response response =
          await post(getCitiesApi, headers: await ApiUtils.getHeaders())
              .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        cityList =
            (data as List).map((data) => CityModel.fromJson(data)).toList();

        citySearchLIst.addAll(cityList);
      } else {
        ShowMsgDialog(msg!);
      }
      cityLoading = false;
      if (cityState != null) {
        cityState!(
          () {},
        );
      }
      if (mounted) {
        setState(
          () {},
        );
      }
    } on TimeoutException catch (_) {
      ShowMsgDialog(
        getTranslated(context, 'somethingMSg')!,
      );
    }
  }

  Future<void> citySearch(String searchText) async {
    citySearchLIst.clear();
    for (int i = 0; i < cityList.length; i++) {
      CityModel map = cityList[i];

      if (map.name!.toLowerCase().contains(searchText)) {
        citySearchLIst.add(map);
      }
    }

    if (mounted) {
      cityState!(
        () {},
      );
    }
  }

//============================= For Animation ==================================

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

//============================= Network Checking ===============================

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await buttonController!.reverse();
      restorentRegisterAPI();
    } else {
      Future.delayed(
        const Duration(seconds: 2),
      ).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
    }
  }

  addweekendData(
      String day, TimeOfDay opening, TimeOfDay closing, bool? check) {
    int selectedDayIndedx =
        workingDaysvar.indexWhere((element) => element["day"] == day);

    if (selectedDayIndedx == -1) {
    } else {
      workingDaysvar.removeAt(selectedDayIndedx);
    }
    if (check!) {
      Map<String, dynamic> singleday = {
        "day": day,
        "opening_time": "${opening.hour}:${opening.minute}:00",
        "closing_time": "${closing.hour}:${closing.minute}:00",
        "is_open": "1"
      };
      workingDaysvar.add(singleday);
    }
  }

  //fcmTocken
  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

//============================= For API Call ==================================

  Future<void> restorentRegisterAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
    String fcmToken = await getFCMToken();
    if (_isNetworkAvail) {
      try {
        () {
          addweekendData("Sunday", timeSunM, timeSunE, suncheck);
          addweekendData("Monday", timeMonM, timeMonE, moncheck);
          addweekendData("Tuesday", timeTueM, timeTueE, tuecheck);
          addweekendData("Wednesday", timeWedM, timeWedE, wedcheck);
          addweekendData("Thursday", timeThuM, timeThuE, thucheck);
          addweekendData("Friday", timeFriM, timeFriE, fricheck);
          addweekendData("Saturday", timeSatM, timeSatE, satcheck);
        }();
        var request = http.MultipartRequest("POST", updateUserApi);
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[Name] = ownerName!;
        request.fields[Mobile] = mobile!;
        request.fields[Email] = email!;
        request.fields["password"] = password!;
        request.fields[Address] = address!;
        request.fields[restaurantName] = storename!;
        request.fields[tax_name] = taxname!;
        request.fields[tax_number] = taxnumber!;
        request.fields[DEVICETYPE] = Platform.isAndroid ? "android" : "ios";
        request.fields[FCMID] = fcmToken;
        if (pannumber != null) {
          request.fields[pan_number] = pannumber!;
        }
        if (bankname != null) {
          request.fields[bank_name] = bankname!;
        }
        if (bankcode != null) {
          request.fields["bank_code"] = bankcode!;
        }
        if (storeDesc != null) {
          request.fields[description] = storeDesc!;
        }
        request.fields[Latitude] = latitutute!;
        request.fields[Longitude] = longitude!;
        if (accNo != null) {
          request.fields[accountNumber] = accNo!;
        }
        if (accname != null) {
          request.fields[accountName] = accname!;
        }
        if (licenceName != null) {
          request.fields[licence_name] = licenceName!;
        }
        if (licenceCode != null) {
          request.fields[licence_code] = licenceCode!;
        }
        request.fields["cooking_time"] = cookingtime!;
        if (addressProfFile != null) {
          final mimeType = lookupMimeType(addressProfFile.path);
          var extension = mimeType!.split("/");
          var addproff = await http.MultipartFile.fromPath(
            AddressProof,
            addressProfFile.path,
            contentType: MediaType('image', extension[1]),
          );
          request.files.add(addproff);
        }
        if (nationalIdentityCardFile != null) {
          final mimeType = lookupMimeType(nationalIdentityCardFile.path);
          var extension = mimeType!.split("/");
          var nationalproff = await http.MultipartFile.fromPath(
            NationalIdentityCard,
            nationalIdentityCardFile.path,
            contentType: MediaType('image', extension[1]),
          );
          request.files.add(nationalproff);
        }
        if (storeLogoFile != null) {
          final mimeType = lookupMimeType(storeLogoFile.path);
          var extension = mimeType!.split("/");
          var storelogo = await http.MultipartFile.fromPath(
            "profile",
            storeLogoFile.path,
            contentType: MediaType('image', extension[1]),
          );
          request.files.add(storelogo);
        }
        for (var i = 0; i < licenceProofFile.length; i++) {
          final mimeType = lookupMimeType(licenceProofFile[i].path);

          var extension = mimeType!.split("/");
          var pic = await http.MultipartFile.fromPath(
              licence_proof, licenceProofFile[i].path,
              contentType: MediaType('image', extension[1]));
          request.files.add(pic);
          print(licenceProofFile[i].path);
        }
        request.fields["delivery_orders"] = deliveryOrdersStatus;
        request.fields["restro_profile"] = selfPickup;

        request.fields["type"] = type.toString();
        request.fields["status"] = restorentsStatus;
        if (city != null) {
          request.fields["city_id"] = city!;
        } else {
          ShowMsgDialog(
            getTranslated(context, "Please Select your city")!,
          );
        }
        var weekdaysjson = json.encode(workingDaysvar);
        request.fields["working_time"] = weekdaysjson;
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        if (!error) {
          print("partner register:${getdata}");
          ShowMsgDialog(msg!);
          if (msg == "partner Registered Successfully") {
            Future.delayed(
              const Duration(seconds: 2),
              () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<String>(
                    builder: (context) => const SellerRegister(),
                  ),
                );
              },
            );
          }
          await buttonController!.reverse();
        } else {
          if (getdata[statusCode] == "120") {
            reLogin(context);
          }
          await buttonController!.reverse();
          ShowMsgDialog(msg!);
        }
      } on TimeoutException catch (_) {
        ShowMsgDialog(
          getTranslated(context, 'somethingMSg')!,
        );
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
          },
        );
      }
    }
  }

  ShowMsgDialog(String msg) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: Theme.of(this.context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: black),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool validateAndSave() {
    if (true) {
      if (ownerName == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add name")!,
        );
        return false;
      } else if (password == null) {
        ShowMsgDialog(
          getTranslated(context, "please add Password field")!,
        );
        return false;
      } else if (password!.length < 6) {
        ShowMsgDialog(
          getTranslated(context, "Password must be at least 6 Character")!,
        );
        return false;
      } else if (confirmPassword == null) {
        ShowMsgDialog(
          getTranslated(context, "please add Confirm Password field")!,
        );
        return false;
      } else if (confirmPassword != password) {
        ShowMsgDialog(
          getTranslated(context, "Confirm Password and Password not matching")!,
        );
        return false;
      } else if (mobile == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add mobile number")!,
        );
        return false;
      } else if (email == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add email id")!,
        );
        return false;
      } else if (address == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add Address")!,
        );
        return false;
      } else if (storename == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add Restaurant name")!,
        );
        return false;
      } else if (taxname == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add tax name")!,
        );
        return false;
      } else if (taxnumber == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add tax number")!,
        );
        return false;
      } else if (latitutute == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add latitutute")!,
        );
        return false;
      } else if (longitude == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add longitude")!,
        );
        return false;
      } else if (cookingtime == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add cooking time")!,
        );
        return false;
      } else if (addressProfFile == null) {
        ShowMsgDialog(
          getTranslated(context, "Please upload address prof")!,
        );
        return false;
      } else if (nationalIdentityCardFile == null) {
        ShowMsgDialog(
          getTranslated(context, "Please upload national Identity Card File")!,
        );
        return false;
      } else if (storeLogoFile == null) {
        ShowMsgDialog(
          getTranslated(context, "Please upload store Logo File")!,
        );
        return false;
      } else if (licenceName == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add licence name")!,
        );
        return false;
      } else if (licenceCode == null) {
        ShowMsgDialog(
          getTranslated(context, "Please add licence code")!,
        );
        return false;
      } else if (storeLogoFile == null) {
        ShowMsgDialog(
          getTranslated(context, "Please upload licence proof File")!,
        );
        return false;
      }
      return true;
    }
  }

//============================= Dispose Method =================================

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
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    emailC!.dispose();
    storenameC!.dispose();
    storeurlC!.dispose();
    storeDescC!.dispose();
    accnameC!.dispose();
    newPassC!.dispose();
    confPassC!.dispose();
    accnumberC!.dispose();
    bankcodeC!.dispose();
    banknameC!.dispose();
    latitututeC!.dispose();
    longituteC!.dispose();
    taxnameC!.dispose();
    pannumberC!.dispose();
    taxnumberC!.dispose();
    buttonController!.dispose();
    licenceNameC!.dispose();
    licenceCodeC!.dispose();
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

//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [backgroundDark, backgroundDark],
                        stops: [0, 1],
                      ),
                    ),
                  ),
                  getLoginContainer(),
                ],
              )
            : noInternet(context),
      ),
    );
  }

//============================= Login Container widget =========================

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.05,
      textDirection: Directionality.of(context),
      child: ClipRect(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: black,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom * 0.8,
          ),
          height: MediaQuery.of(context).size.height * 0.90,
          width: MediaQuery.of(context).size.width * 0.95,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  SvgPicture.asset(
                    setSvgPath("app_logo"),
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  setSignInLabel(),
                  commanDesingFields(
                    Icons.person_outlined,
                    getTranslated(context, "Owner Name")!,
                    TextInputType.text,
                    0,
                  ),
                  commanDesingFields(
                    Icons.phone_in_talk_outlined,
                    getTranslated(context, "MOBILEHINT_LBL")!,
                    TextInputType.number,
                    1,
                  ),
                  commanDesingFields(
                    Icons.email_outlined,
                    getTranslated(context, "Email")!,
                    TextInputType.text,
                    2,
                  ),
                  commanDesingFields(
                    Icons.password_outlined,
                    getTranslated(context, "PASSHINT_LBL")!,
                    TextInputType.text,
                    16,
                  ),
                  commanDesingFields(
                    Icons.password_rounded,
                    getTranslated(context, "CONFIRMPASSHINT_LBL")!,
                    TextInputType.text,
                    17,
                  ),
                  commanDesingFields(
                    Icons.location_on_outlined,
                    getTranslated(context, "Addresh")!,
                    TextInputType.text,
                    3,
                  ),
                  commanDesingFields(
                    Icons.store_outlined,
                    getTranslated(context, "restaurant Name")!,
                    TextInputType.text,
                    4,
                  ),
                  commanDesingFields(
                    Icons.watch_later_outlined,
                    getTranslated(context, "Cooking Time")!,
                    TextInputType.number,
                    5,
                  ),
                  commanDesingFields(
                    Icons.description_outlined,
                    getTranslated(context, "Description")!,
                    TextInputType.text,
                    6,
                  ),
                  commanDesingFields(
                    Icons.format_list_numbered_outlined,
                    getTranslated(context, "AccountNumber")!,
                    TextInputType.text,
                    7,
                  ),
                  commanDesingFields(
                    Icons.import_contacts_outlined,
                    getTranslated(context, "AccountName")!,
                    TextInputType.text,
                    8,
                  ),
                  commanDesingFields(
                    Icons.request_quote_outlined,
                    getTranslated(context, "BankCode")!,
                    TextInputType.text,
                    9,
                  ),
                  commanDesingFields(
                    Icons.account_balance_outlined,
                    getTranslated(context, "BankName")!,
                    TextInputType.text,
                    10,
                  ),
                  commanDesingFields(
                      Icons.travel_explore_outlined,
                      getTranslated(context, "Latitute")!,
                      TextInputType.text,
                      11,
                      true,
                      false),
                  commanDesingFields(
                      Icons.language_outlined,
                      getTranslated(context, "Longitude")!,
                      TextInputType.text,
                      12,
                      false,
                      true),
                  commanDesingFields(
                    Icons.text_snippet_outlined,
                    getTranslated(context, "TaxName")!,
                    TextInputType.text,
                    13,
                  ),
                  commanDesingFields(
                    Icons.assignment_outlined,
                    getTranslated(context, "TaxNumber")!,
                    TextInputType.text,
                    14,
                  ),
                  commanDesingFields(
                    Icons.picture_in_picture_outlined,
                    getTranslated(context, "PanNumber")!,
                    TextInputType.text,
                    15,
                  ),
                  commanDesingFields(
                    Icons.picture_in_picture_outlined,
                    getTranslated(context, "LicenceName")!,
                    TextInputType.text,
                    18,
                  ),
                  commanDesingFields(
                    Icons.picture_in_picture_outlined,
                    getTranslated(context, "LicenceCode")!,
                    TextInputType.text,
                    19,
                  ),
                  uploadStoreLogo(
                    getTranslated(context, "LicenceProof")!,
                    4,
                  ),
                  selectedMainImageListShow(licenceProofFile),
                  uploadStoreLogo(
                    getTranslated(context, "National Identity Card")!,
                    1,
                  ),
                  selectedMainImageShow(nationalIdentityCardFile),
                  uploadStoreLogo(
                    getTranslated(context, "Address Proof")!,
                    2,
                  ),
                  selectedMainImageShow(addressProfFile),
                  uploadStoreLogo(
                    getTranslated(context, "Profile")!,
                    3,
                  ),
                  selectedMainImageShow(storeLogoFile),
                  restorentType(),
                  deliveryOrdersStatusSwitch(),
                  selfPickupStatus(),
                  setCities(),
                  workingDays(),
                  updateBtn(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  selfPickupStatus() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Self Pickup")!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  if (value) {
                    selfPickup = "1";
                  } else {
                    selfPickup = "0";
                  }
                },
              );
            },
            value: selfPickup == "1" ? true : false,
          ),
        ],
      ),
    );
  }

  deliveryOrdersStatusSwitch() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 0.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Deliver Orders")!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  if (value) {
                    deliveryOrdersStatus = "1";
                  } else {
                    deliveryOrdersStatus = "0";
                  }
                },
              );
            },
            value: deliveryOrdersStatus == '1' ? true : false,
          ),
        ],
      ),
    );
  }

  workingDays() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        top: 30.0,
        bottom: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getTranslated(context, "Working Days")!} *",
            style: const TextStyle(
              fontSize: 16,
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          getDays(getTranslated(context, "Sunday")!, 0),
          getDays(getTranslated(context, "Monday")!, 1),
          getDays(getTranslated(context, "Tuesday")!, 2),
          getDays(getTranslated(context, "Wednesday")!, 3),
          getDays(getTranslated(context, "Thursday")!, 4),
          getDays(getTranslated(context, "Friday")!, 5),
          getDays(getTranslated(context, "Saturday")!, 6),
        ],
      ),
    );
  }

  getDays(
    String title,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        right: 8.0,
        left: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontSize: 14,
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickTime(context, index, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                  ),
                  child: Text(
                    "${() {
                      if (index == 0) {
                        return timeSunM.hour.toString().padLeft(2, '0');
                      } else if (index == 1) {
                        return timeMonM.hour.toString().padLeft(2, '0');
                      } else if (index == 2) {
                        return timeTueM.hour.toString().padLeft(2, '0');
                      } else if (index == 3) {
                        return timeWedM.hour.toString().padLeft(2, '0');
                      } else if (index == 4) {
                        return timeThuM.hour.toString().padLeft(2, '0');
                      } else if (index == 5) {
                        return timeFriM.hour.toString().padLeft(2, '0');
                      } else if (index == 6) {
                        return timeSatM.hour.toString().padLeft(2, '0');
                      }
                    }()} : ${() {
                      if (index == 0) {
                        return timeSunM.minute.toString().padLeft(2, '0');
                      } else if (index == 1) {
                        return timeMonM.minute.toString().padLeft(2, '0');
                      } else if (index == 2) {
                        return timeTueM.minute.toString().padLeft(2, '0');
                      } else if (index == 3) {
                        return timeWedM.minute.toString().padLeft(2, '0');
                      } else if (index == 4) {
                        return timeThuM.minute.toString().padLeft(2, '0');
                      } else if (index == 5) {
                        return timeFriM.minute.toString().padLeft(2, '0');
                      } else if (index == 6) {
                        return timeSatM.minute.toString().padLeft(2, '0');
                      }
                    }()}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    left: 8.0,
                  ),
                  child: Text(
                    getTranslated(context, "to")!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    pickTime(context, index, false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                  ),
                  child: Text(
                    "${() {
                      if (index == 0) {
                        return timeSunE.hour.toString().padLeft(2, '0');
                      } else if (index == 1) {
                        return timeMonE.hour.toString().padLeft(2, '0');
                      } else if (index == 2) {
                        return timeTueE.hour.toString().padLeft(2, '0');
                      } else if (index == 3) {
                        return timeWedE.hour.toString().padLeft(2, '0');
                      } else if (index == 4) {
                        return timeThuE.hour.toString().padLeft(2, '0');
                      } else if (index == 5) {
                        return timeFriE.hour.toString().padLeft(2, '0');
                      } else if (index == 6) {
                        return timeSatE.hour.toString().padLeft(2, '0');
                      }
                    }()} : ${() {
                      if (index == 0) {
                        return timeSunE.minute.toString().padLeft(2, '0');
                      } else if (index == 1) {
                        return timeMonE.minute.toString().padLeft(2, '0');
                      } else if (index == 2) {
                        return timeTueE.minute.toString().padLeft(2, '0');
                      } else if (index == 3) {
                        return timeWedE.minute.toString().padLeft(2, '0');
                      } else if (index == 4) {
                        return timeThuE.minute.toString().padLeft(2, '0');
                      } else if (index == 5) {
                        return timeFriE.minute.toString().padLeft(2, '0');
                      } else if (index == 6) {
                        return timeSatE.minute.toString().padLeft(2, '0');
                      }
                    }()}",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: () {
                  if (index == 0) {
                    return suncheck;
                  } else if (index == 1) {
                    return moncheck;
                  } else if (index == 2) {
                    return tuecheck;
                  } else if (index == 3) {
                    return wedcheck;
                  } else if (index == 4) {
                    return thucheck;
                  } else if (index == 5) {
                    return fricheck;
                  } else if (index == 6) {
                    return satcheck;
                  }
                }(),
                onChanged: (bool? value) {
                  setState(
                    () {
                      () {
                        if (index == 0) {
                          suncheck = value!;
                        } else if (index == 1) {
                          moncheck = value!;
                        } else if (index == 2) {
                          tuecheck = value!;
                        } else if (index == 3) {
                          wedcheck = value!;
                        } else if (index == 4) {
                          thucheck = value!;
                        } else if (index == 5) {
                          fricheck = value!;
                        } else if (index == 6) {
                          satcheck = value!;
                        }
                      }();
                    },
                  );
                },
              ),
              Text(
                getTranslated(context, "Open")!,
                style: const TextStyle(
                  fontSize: 16,
                  color: white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future pickTime(
    BuildContext context,
    int index,
    bool morning,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: () {
        if (index == 0) {
          if (morning) {
            return timeSunM;
          } else {
            return timeSunE;
          }
        } else if (index == 1) {
          if (morning) {
            return timeMonM;
          } else {
            return timeMonE;
          }
        } else if (index == 2) {
          if (morning) {
            return timeTueM;
          } else {
            return timeTueE;
          }
        } else if (index == 3) {
          if (morning) {
            return timeWedM;
          } else {
            return timeWedE;
          }
        } else if (index == 4) {
          if (morning) {
            return timeThuM;
          } else {
            return timeThuE;
          }
        } else if (index == 5) {
          if (morning) {
            return timeFriM;
          } else {
            return timeFriE;
          }
        } else if (index == 6) {
          if (morning) {
            return timeSatM;
          } else {
            return timeSatE;
          }
        }
        return timeSunM;
      }(),
    );

    if (newTime == null) return;
    if (index == 0) {
      if (morning) {
        setState(() => timeSunM = newTime);
      } else {
        setState(() => timeSunE = newTime);
      }
    } else if (index == 1) {
      if (morning) {
        setState(() => timeMonM = newTime);
      } else {
        setState(() => timeMonE = newTime);
      }
    } else if (index == 2) {
      if (morning) {
        setState(() => timeTueM = newTime);
      } else {
        setState(() => timeTueE = newTime);
      }
    } else if (index == 3) {
      if (morning) {
        setState(() => timeWedM = newTime);
      } else {
        setState(() => timeWedE = newTime);
      }
    } else if (index == 4) {
      if (morning) {
        setState(() => timeThuM = newTime);
      } else {
        setState(() => timeThuE = newTime);
      }
    } else if (index == 5) {
      if (morning) {
        setState(() => timeFriM = newTime);
      } else {
        setState(() => timeFriE = newTime);
      }
    } else if (index == 6) {
      if (morning) {
        setState(() => timeSatM = newTime);
      } else {
        setState(() => timeSatE = newTime);
      }
    }
  }

  setCities() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: GestureDetector(
            child: InputDecorator(
              decoration: const InputDecoration(
                fillColor: white,
                isDense: true,
                border: InputBorder.none,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getTranslated(context, "Select City")!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          selCityPos != null &&
                                  selCityPos != -1 &&
                                  citySearchLIst.isNotEmpty
                              ? citySearchLIst[selCityPos!].name!
                              : "",
                          style: TextStyle(
                            color: selCityPos != null ? fontColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right)
                ],
              ),
            ),
            onTap: () {
              cityDialog();
            },
          ),
        ),
      ),
    );
  }

  cityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            cityState = setStater;
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                    child: Text(
                      getTranslated(context, "Select City")!,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleMedium!
                          .copyWith(
                            color: fontColor,
                          ),
                    ),
                  ),
                  TextField(
                    controller: _cityController,
                    autofocus: false,
                    style: const TextStyle(
                      color: black,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                      prefixIcon:
                          const Icon(Icons.search, color: primary, size: 17),
                      hintText: getTranslated(context, "Search")!,
                      hintStyle:
                          TextStyle(color: primary.withValues(alpha: 0.5)),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: white),
                      ),
                    ),
                  ),
                  const Divider(color: lightBlack),
                  cityLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : (citySearchLIst.isNotEmpty)
                          ? Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: getCityList(),
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: getNoItem(context),
                            )
                ],
              ),
            );
          },
        );
      },
    );
  }

  getCityList() {
    return citySearchLIst
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(
                    () {
                      selCityPos = index;
                      Navigator.of(context).pop();
                    },
                  );
                }
                city = citySearchLIst[selCityPos!].id;
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    citySearchLIst[index].name!,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  selectedMainImageShow(File? name) {
    return name == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              name,
              width: 200,
              height: 200,
            ),
          );
  }

  selectedMainImageListShow(List<File>? name) {
    return name == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  name.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      name[index],
                      height: 200,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  uploadStoreLogo(String title, int number) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 90,
                height: 40,
                child: Center(
                  child: Text(
                    getTranslated(context, "Upload")!,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              onTap: () {
                if (number == 4) {
                  mainImageListFromGallery(setModalState);
                } else {
                  mainImageFromGallery(number);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  mainImageFromGallery(int number) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      File image = File(result.files.single.path!);
      setState(() {
        if (number == 1) {
          nationalIdentityCardFile = image;
        }
        if (number == 2) {
          addressProfFile = image;
        }
        if (number == 3) {
          storeLogoFile = image;
        }
      });
    } else {}
  }

  void mainImageListFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      licenceProofFile = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
    } else {}
  }

  restorentType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getTranslated(context, "Type of Restaurant")!,
              style: const TextStyle(
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {
                type = 1;
                setState(
                  () {},
                );
              },
              child: Container(
                decoration: type == 1
                    ? BoxDecoration(
                        border: Border.all(
                          color: black,
                          width: 1,
                        ),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    setSvgPath("veg_icon"),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                type = 2;
                setState(
                  () {},
                );
              },
              child: Container(
                decoration: type == 2
                    ? BoxDecoration(
                        border: Border.all(
                          color: black,
                          width: 1,
                        ),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    setSvgPath("non_veg_icon"),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                type = 3;
                setState(() {});
              },
              child: Container(
                decoration: type == 3
                    ? BoxDecoration(
                        border: Border.all(
                          color: black,
                          width: 1,
                        ),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    setSvgPath("veg_non_both"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//=========================== Saller Name ======================================
  commanDesingFields(
    IconData? icon,
    String title,
    TextInputType? keybordtype,
    int index, [
    bool? fromLatitute,
    bool? fromLongtitude,
  ]) {
    bool fromLatitute1 = fromLatitute ?? false;
    bool fromLongtitude1 = fromLongtitude ?? false;
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        textAlignVertical: (fromLatitute1 || index == 16 || index == 17)
            ? TextAlignVertical.center
            : TextAlignVertical.top,
        readOnly: fromLatitute1
            ? true
            : fromLongtitude1
                ? true
                : false,
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(
            () {
              if (index == 0) {
                return nameFocus;
              } else if (index == 1) {
                return mobileFocus;
              } else if (index == 2) {
                return emailFocus;
              } else if (index == 3) {
                return addressFocus;
              } else if (index == 4) {
                return storenameFocus;
              } else if (index == 5) {
                return cookingtimeFocus;
              } else if (index == 6) {
                return storeDescFocus;
              } else if (index == 7) {
                return accNoFocus;
              } else if (index == 8) {
                return accnameFocus;
              } else if (index == 9) {
                return bankcodeFocus;
              } else if (index == 10) {
                return banknameFocus;
              } else if (index == 11) {
                return latitututeFocus;
              } else if (index == 12) {
                return longitudeFocus;
              } else if (index == 13) {
                return taxnameFocus;
              } else if (index == 14) {
                return taxnumberFocus;
              } else if (index == 15) {
                return pannumberFocus;
              } else if (index == 16) {
                return passwordFocus;
              } else if (index == 17) {
                return confirmPasswordFocus;
              } else if (index == 18) {
                return licenceNameFocus;
              } else if (index == 19) {
                return licenceCodeFocus;
              }

              return nameFocus;
            }(),
          );
        },
        keyboardType: keybordtype,
        controller: () {
          if (index == 0) {
            return nameC;
          } else if (index == 1) {
            return mobileC;
          } else if (index == 2) {
            return emailC;
          } else if (index == 3) {
            return addressC;
          } else if (index == 4) {
            return storenameC;
          } else if (index == 5) {
            return storeurlC;
          } else if (index == 6) {
            return storeDescC;
          } else if (index == 7) {
            return accnumberC;
          } else if (index == 8) {
            return accnameC;
          } else if (index == 9) {
            return bankcodeC;
          } else if (index == 10) {
            return banknameC;
          } else if (index == 11) {
            return latitututeC;
          } else if (index == 12) {
            return longituteC;
          } else if (index == 13) {
            return taxnameC;
          } else if (index == 14) {
            return taxnumberC;
          } else if (index == 15) {
            return pannumberC;
          } else if (index == 16) {
            return newPassC;
          } else if (index == 17) {
            return confPassC;
          } else if (index == 18) {
            return licenceNameC;
          } else if (index == 19) {
            return licenceCodeC;
          }
          return unusedC;
        }(),
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: () {
          if (index == 0) {
            return nameFocus;
          } else if (index == 1) {
            return mobileFocus;
          } else if (index == 2) {
            return emailFocus;
          } else if (index == 3) {
            return addressFocus;
          } else if (index == 4) {
            return storenameFocus;
          } else if (index == 5) {
            return cookingtimeFocus;
          } else if (index == 6) {
            return storeDescFocus;
          } else if (index == 7) {
            return accNoFocus;
          } else if (index == 8) {
            return accnameFocus;
          } else if (index == 9) {
            return bankcodeFocus;
          } else if (index == 10) {
            return banknameFocus;
          } else if (index == 11) {
            return latitututeFocus;
          } else if (index == 12) {
            return longitudeFocus;
          } else if (index == 13) {
            return taxnameFocus;
          } else if (index == 14) {
            return taxnumberFocus;
          } else if (index == 15) {
            return pannumberFocus;
          } else if (index == 16) {
            return passwordFocus;
          } else if (index == 17) {
            return confirmPasswordFocus;
          } else if (index == 18) {
            return licenceNameFocus;
          } else if (index == 19) {
            return licenceCodeFocus;
          }
          return nameFocus;
        }(),
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (String? value) {
          () {
            if (index == 0) {
              ownerName = nameC!.text;
            } else if (index == 1) {
              mobile = mobileC!.text;
            } else if (index == 2) {
              email = emailC!.text;
            } else if (index == 3) {
              address = addressC!.text;
            } else if (index == 4) {
              storename = storenameC!.text;
            } else if (index == 5) {
              cookingtime = storeurlC!.text;
            } else if (index == 6) {
              storeDesc = storeDescC!.text;
            } else if (index == 7) {
              accNo = accnumberC!.text;
            } else if (index == 8) {
              accname = accnameC!.text;
            } else if (index == 9) {
              bankcode = bankcodeC!.text;
            } else if (index == 10) {
              bankname = banknameC!.text;
            } else if (index == 11) {
              latitutute = latitututeC!.text;
            } else if (index == 12) {
              longitude = longituteC!.text;
            } else if (index == 13) {
              taxname = taxnameC!.text;
            } else if (index == 14) {
              taxnumber = taxnumberC!.text;
            } else if (index == 15) {
              pannumber = pannumberC!.text;
            } else if (index == 16) {
              password = newPassC!.text;
            } else if (index == 17) {
              confirmPassword = confPassC!.text;
            } else if (index == 18) {
              licenceName = licenceNameC!.text;
            } else if (index == 19) {
              licenceCode = licenceCodeC!.text;
            }
          }();
        },
        onSaved: (String? value) {
          () {
            if (index == 0) {
              ownerName = nameC!.text;
            } else if (index == 1) {
              mobile = mobileC!.text;
            } else if (index == 2) {
              email = emailC!.text;
            } else if (index == 3) {
              address = addressC!.text;
            } else if (index == 4) {
              storename = storenameC!.text;
            } else if (index == 5) {
              cookingtime = storeurlC!.text;
            } else if (index == 6) {
              storeDesc = storeDescC!.text;
            } else if (index == 7) {
              accNo = accnumberC!.text;
            } else if (index == 8) {
              accname = accnameC!.text;
            } else if (index == 9) {
              bankcode = bankcodeC!.text;
            } else if (index == 10) {
              bankname = banknameC!.text;
            } else if (index == 11) {
              latitutute = latitututeC!.text;
            } else if (index == 12) {
              longitude = longituteC!.text;
            } else if (index == 13) {
              taxname = taxnameC!.text;
            } else if (index == 14) {
              taxnumber = taxnumberC!.text;
            } else if (index == 15) {
              pannumber = pannumberC!.text;
            } else if (index == 16) {
              password = passwordC!.text;
            } else if (index == 17) {
              confirmPassword = confirmPasswordC!.text;
            } else if (index == 18) {
              licenceName = licenceNameC!.text;
            } else if (index == 19) {
              licenceCode = licenceCodeC!.text;
            }
          }();
        },
        obscureText: index == 16
            ? obscurePassword
            : index == 17
                ? obscureConfirmPassword
                : false,
        decoration: InputDecoration(
          suffixIcon: fromLatitute1
              ? InkWell(
                  onTap: () async {
                    LocationPermission permission;

                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                    }
                    final LocationSettings locationSettings = LocationSettings(
                      accuracy: LocationAccuracy.high,
                    );
                    Position position = await Geolocator.getCurrentPosition(
                        locationSettings: locationSettings);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            latitude: position.latitude,
                            longitude: position.longitude,
                            from: true,
                          ),
                        ),
                      ).then(
                        (value) {
                          if (value != null && mounted) {
                            if (value is Map<String, dynamic>) {
                              latitutute = value['latitude'].toString();
                              longitude = value['longitude'].toString();
                              latitututeC!.text = latitutute!;
                              longituteC!.text = longitude!;
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          }
                        },
                      );
                    }
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: primary,
                  ),
                )
              : index == 16
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          if (obscurePassword == true) {
                            obscurePassword = false;
                          } else {
                            obscurePassword = true;
                          }
                        });
                      },
                      child: Icon(
                          obscurePassword == true
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: lightBlack2))
                  : index == 17
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              if (obscureConfirmPassword == true) {
                                obscureConfirmPassword = false;
                              } else {
                                obscureConfirmPassword = true;
                              }
                            });
                          },
                          child: Icon(
                              obscureConfirmPassword == true
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: lightBlack2))
                      : null,
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            icon,
            color: lightBlack2,
            size: 20,
          ),
          hintText: title,
          hintStyle: const TextStyle(
            color: lightBlack2,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslated(context, "New Registration")!,
          style: const TextStyle(
            color: white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  updateBtn() {
    return AppBtn(
      title: getTranslated(context, "Register")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      index: 1,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 50,
      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          setSvgPath("app_logo"),
        ),
      ),
    );
  }
}
