import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/Screen/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Localization/demo_localization.dart';
import 'color.dart';
import 'string.dart';
import 'package:shimmer/shimmer.dart';

setSvgPath(String name) {
  return "assets/images/svg/$name.svg";
}

setPngPath(String name) {
  return "assets/images/png/$name.png";
}

BoxDecoration boxDecorationContainer(Color color, double radius) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
  );
}

BoxDecoration boxDecorationContainerBorder(Color color, Color colorBackground, double radius) {
  return BoxDecoration(
    color: colorBackground,
    border: Border.all(color: color),
    borderRadius: BorderRadius.circular(radius),
  );
}

//==================== Common SnackBar =========================================

setsnackbar(String msg, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: white,
        ),
      ),
      duration: const Duration(
        seconds: 2,
      ),
      backgroundColor: black,
      elevation: 1.0,
    ),
  );
}

setSnackbarForLogin(GlobalKey<ScaffoldMessengerState> scafoldkey, contex, String msg) {
  scafoldkey.currentState!.showSnackBar(
    SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: white,
        ),
      ),
      duration: const Duration(
        seconds: 2,
      ),
      backgroundColor: black,
      elevation: 1.0,
    ),
  );
}

//===============old================
String capitalize(String s) {
  if (s == "") {
    return "";
  } else {
    return s[0].toUpperCase() + s.substring(1);
  }
}

//============================= name verification ==============================

String? validateUserName(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "USER_REQUIRED")!;
  }
  if (value.length <= 1) {
    return getTranslated(context, "USER_LENGTH")!;
  }
  return null;
}

//============================= container decoration ===========================

shadow() {
  return const BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: white,
      )
    ],
  );
}

Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

//======================= Shimmer Effect =======================================

Widget shimmer() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map(
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80.0,
                        height: 80.0,
                        color: white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 18.0,
                              color: white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            Container(
                              width: double.infinity,
                              height: 8.0,
                              color: white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            Container(
                              width: 100.0,
                              height: 8.0,
                              color: white,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            Container(
                              width: 20.0,
                              height: 8.0,
                              color: white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

//======================= Show Dialog animation  ==================================

dialogAnimate(BuildContext context, Widget dialge) {
  return showGeneralDialog(
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: dialge,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
  );
}

//======================= Container Decoration  ==================================

back() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primary, primary],
      stops: [0, 1],
    ),
  );
}

//======================= Language Translate  ==================================

String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}

//======================= internet not awailable ===============================

noIntImage() {
  return SvgPicture.asset(
    setSvgPath("connection_lost"),
    fit: BoxFit.contain,
  );
}

noIntText(BuildContext context) {
  return Text(
    getTranslated(context, "NO_INTERNET")!,
    style: const TextStyle(
      color: primary,
      fontWeight: FontWeight.normal,
    ),
  );
}

noIntDec(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
    child: Text(
      getTranslated(context, "NO_INTERNET_DISC")!,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: lightBlack2,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

//======================= AppBar Widget ========================================

getAppBar(String title, BuildContext context) {
  return AppBar(
    titleSpacing: 0,
    elevation: 1,
    backgroundColor: white,
    leading: Builder(
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: shadow(),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).pop(),
            child: const Center(
              child: Icon(
                Icons.keyboard_arrow_left,
                color: primary,
                size: 30,
              ),
            ),
          ),
        );
      },
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: primary,
      ),
    ),
  );
}

String? validateField(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "FIELD_REQUIRED")!;
  } else {
    return null;
  }
}

//mobile verification

String? validateMob(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "MOB_REQUIRED")!;
  }
  if (value.length < 9) {
    return getTranslated(context, "VALID_MOB");
  }
  return null;
}

// product name velidatation

String? validateProduct(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "ProductNameRequired")!;
  }
  if (value.length < 3) {
    return getTranslated(context, "VALID_PRO_NAME")!;
  }
  return null;
}

// product name velidatation

String? validateThisFieldRequered(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "This Field is Required!")!;
  }

  return null;
}

// sort detail velidatation

String? sortdescriptionvalidate(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "Sort Description is required")!;
  }
  if (value.length < 3) {
    return getTranslated(context, "minimam 5 character is required ")!;
  }
  return null;
}

// password verification

String? validatePass(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "PWD_REQUIRED")!;
  } else if (value.length <= 5) {
    return getTranslated(context, "PWD_LENGTH")!;
  } else {
    return null;
  }
}

//for no iteam
Widget getNoItem(BuildContext context) {
  return Center(
    child: Text(
      getTranslated(context, "noItem")!,
    ),
  );
}

placeHolder(double height) {
  return AssetImage(
    setPngPath("placeholder"),
  );
}

erroWidget(double size) {
  return Image.asset(
    setPngPath("placeholder"),
    height: size,
    width: size,
  );
}

// progress
Widget showCircularProgress(bool isProgress, Color color) {
  if (isProgress) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
  return const SizedBox(
    height: 0.0,
    width: 0.0,
  );
}

//======================= height & width of device =============================

double height = 0;
double width = 0;

//============ connectivity_plus for checking internet connectivity ============

Future<bool> isNetworkAvailable() async {
  List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();

  // Iterate through the list to check if any of the results represent a valid connection
  for (var result in connectivityResults) {
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      return true;
    }
  }
  return false;
}

//=======================  Shared Preference List ==============================

//1. for Login -----------------------------------------------------------------
setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

//======================== User Detaile Save in funvtion =======================

Future<void> saveUserDetail(
  String userId,
  String name,
  String email,
  String mobile,
  String address,
  String storename,
  String storeDesc,
  String accNo,
  String accname,
  String bankCode,
  String bankName,
  String latitutute,
  String longitude,
  String taxname,
  String taxNumber,
  String panNumber,
  String status,
  String storelogo,
  String cityid,
  String cityname,
  String jwtToken,
) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(Id, userId));
  waitList.add(prefs.setString(Username, name));
  waitList.add(prefs.setString(Email, email));
  waitList.add(prefs.setString(Mobile, mobile));
  waitList.add(prefs.setString(Address, address));
  waitList.add(prefs.setString(StoreName, storename));
  waitList.add(prefs.setString(storeDescription, storeDesc));
  waitList.add(prefs.setString(accountNumber, accNo));
  waitList.add(prefs.setString(accountName, accname));
  waitList.add(prefs.setString(BankCOde, bankCode));
  waitList.add(prefs.setString(bankNAme, bankName));
  waitList.add(prefs.setString(Latitude, latitutute));
  waitList.add(prefs.setString(Longitude, longitude));
  waitList.add(prefs.setString(taxName, taxname));
  waitList.add(prefs.setString(taxNumber, taxNumber));
  waitList.add(prefs.setString(panNumber, panNumber));
  waitList.add(prefs.setString(StoreLogo, storelogo));
  waitList.add(prefs.setString("city_id", cityid));
  waitList.add(prefs.setString("city_name", cityname));
  waitList.add(prefs.setString(token, jwtToken));

  await Future.wait(waitList);
}

//for login
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails axisDirection,
  ) {
    return child;
  }
}

// for log out

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(Id));
  waitList.add(prefs.remove(Mobile));
  waitList.add(prefs.remove(Email));
  waitList.add(prefs.remove(token));
  CUR_USERID = '';
  CUR_USERNAME = "";
  JWT_TOCKEN = "";

  await prefs.clear();
}

reLogin(BuildContext context) {
  clearUserSession();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
      (Route<dynamic> route) => false);
}
