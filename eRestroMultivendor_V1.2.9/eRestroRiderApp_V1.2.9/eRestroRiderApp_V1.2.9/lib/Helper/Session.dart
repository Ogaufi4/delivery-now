import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/Localization/demo_localization.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';
import 'Constant.dart';
import 'String.dart';

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

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

shadow() {
  return const BoxDecoration(
    boxShadow: [BoxShadow(color: Color(0x1a0400ff), offset: Offset(0, 0), blurRadius: 30)],
  );
}

placeHolder(double height) {
  return AssetImage(
    setPngPath("placeholder"),
  );
}

  setSvgPath(String name) {
    return "assets/images/svg/$name.svg";
  }

  setPngPath(String name) {
    return "assets/images/png/$name.png";
  }

errorWidget(double size) {
  return Icon(
    Icons.account_circle,
    color: Colors.grey,
    size: size,
  );
}

getAppBar(String title, BuildContext context) {
  return AppBar(
    elevation: 0,
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(13),
        child: InkWell(
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: darkFontColor,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_left,
                color: white,
                size: 28,
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }),
    title: Text(
      title,
      style: const TextStyle(color: darkFontColor, fontWeight: FontWeight.bold, fontSize: 18),
    ),
    centerTitle: true,
    backgroundColor: white,
  );
}

Widget bottomSheetHandle(BuildContext context) {
  return Container(
    alignment: Alignment.topRight,
    padding: const EdgeInsetsDirectional.only(top: 0.0, bottom: 25.0, end: 10.0),
    margin: const EdgeInsets.all(13),
    child: InkWell(
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
            color: black,
            border: Border.all(
              color: black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: const Center(
          child: Icon(
            Icons.close,
            color: white,
            size: 16,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    ),
  );
}

BoxDecoration boxDecorationContainer(double radius, Color color, Color boarderColor) {
  return BoxDecoration(
    border: Border.all(color: boarderColor),
    borderRadius: BorderRadius.circular(radius),
    color: color,
  );
}

BoxDecoration boxDecorationContainerBoarder(double radius, Color color, Color boarderColor) {
  return BoxDecoration(
    border: Border.all(color: boarderColor),
    borderRadius: BorderRadius.circular(radius),
    color: color,
  );
}

Widget bottomsheetLabel(String labelName, BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20.0),
      child: getHeading(labelName, context),
    );

Widget getHeading(String title, BuildContext context) {
  return Text(
    title,
    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: darkFontColor, fontSize: 17),
  );
}

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

noIntImage() {
  return SvgPicture.asset(
    "assets/images/no_internet.svg",
    fit: BoxFit.contain,
  );
}

String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}

noIntText(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Container(
        child: Text(getTranslated(context, 'NO_INTERNET')!,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: primary, fontWeight: FontWeight.normal))),
  );
}

noIntDec(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
    child: Text(getTranslated(context, 'NO_INTERNET_DISC')!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: lightFontColor,
              fontWeight: FontWeight.normal,
            )),
  );
}

Widget showCircularProgress(bool isProgress, Color color) {
  if (isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return const SizedBox(
    height: 0.0,
    width: 0.0,
  );
}

imagePlaceHolder(double size) {
  return SizedBox(
    height: size,
    width: size,
    child: Icon(
      Icons.account_circle,
      color: darkFontColor.withValues(alpha: 0.8),
      size: size,
    ),
  );
}

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(ID));
  waitList.add(prefs.remove(USERNAME));
  waitList.add(prefs.remove(MOBILE));
  waitList.add(prefs.remove(EMAIL));
  waitList.add(prefs.remove(ADDRESS));
  waitList.add(prefs.remove(COMMISSION_METHOD));
  waitList.add(prefs.remove(COMMISSION));
  waitList.add(prefs.remove(ACTIVE));
  waitList.add(prefs.remove(BALANCE));
  waitList.add(prefs.remove(TOKEN));
  CUR_USERID = '';
  CUR_USERNAME = "";
  CUR_BALANCE = '';

  await prefs.clear();
}

Future<void> saveUserDetail(String userId, String name, String email, String mobile, String address, String commMethod, String comm, String status,
    String balance, String jwtToken) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, userId));
  waitList.add(prefs.setString(USERNAME, name));
  waitList.add(prefs.setString(EMAIL, email));
  waitList.add(prefs.setString(MOBILE, mobile));
  waitList.add(prefs.setString(ADDRESS, address));
  waitList.add(prefs.setString(COMMISSION_METHOD, commMethod));
  waitList.add(prefs.setString(COMMISSION, comm));
  waitList.add(prefs.setString(ACTIVE, status));
  waitList.add(prefs.setString(BALANCE, balance));
  waitList.add(prefs.setString(TOKEN, jwtToken));
  await Future.wait(waitList);
}

String? validateField(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, 'FIELD_REQUIRED');
  } else {
    return null;
  }
}

String? validateEmail(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, 'EMAIL_REQUIRED');
  } else if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
      .hasMatch(value)) {
    return getTranslated(context, 'VALID_EMAIL');
  } else {
    return null;
  }
}

String? validateUserName(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, 'USER_REQUIRED');
  }
  if (value.length <= 1) {
    return getTranslated(context, 'USER_LENGTH');
  }
  return null;
}

String? validateMob(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, 'MOB_REQUIRED');
  }
  if (value.length < 9) {
    return getTranslated(context, 'VALID_MOB');
  }
  return null;
}

String? validatePass(String? value, BuildContext context) {
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_.?=^`-]).{8,}$');
  if (value!.isEmpty) {
    return getTranslated(context, 'PWD_REQUIRED');
  } else if (!regex.hasMatch(value)) {
    return getTranslated(context, 'PASSWORD_VALIDATION_MESSAGE');
  } else {
    return null;
  }
}

String? validateAltMob(String value, BuildContext context) {
  if (value.isNotEmpty) if (value.length < 9) {
    return getTranslated(context, 'VALID_MOB');
  }
  return null;
}

Widget getProgress() {
  return const Center(child: CircularProgressIndicator());
}

Widget getNoItem(BuildContext context) {
  return Center(child: Text(getTranslated(context, 'noItem')!));
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
              .map((_) => Padding(
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
                  ))
              .toList(),
        ),
      ),
    ),
  );
}
