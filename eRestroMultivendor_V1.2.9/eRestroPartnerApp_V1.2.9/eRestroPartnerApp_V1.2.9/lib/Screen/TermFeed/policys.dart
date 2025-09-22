import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../Helper/api_base_helper.dart';
import '../../Helper/color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';

// ignore: must_be_immutable
class Policy extends StatefulWidget {
  String? title;
  int? index;
  Policy({
    Key? key,
    this.title,
    this.index,
  }) : super(key: key);
  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
//============================= Variables Declaration ==========================

  bool _isLoading = true;
  bool _isNetworkAvail = true;
  String? contactUs;
  String? termCondition;
  String? privacyPolicy;
  String? returnPolicy;
  String? shippingPolicy;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

//============================= initState Method ===============================

  @override
  void initState() {
    super.initState();
    getSettings();
  }

//========================= getStatics API =====================================

  getSettings() async {
    _isNetworkAvail = await isNetworkAvailable();
    var parameter = {};
    if (_isNetworkAvail) {
      apiBaseHelper.postAPICall(getSettingsApi, parameter, context).then(
        (getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            contactUs = getdata["data"]["contact_us"][0].toString();
            termCondition = getdata["data"]["terms_conditions"][0].toString();
            privacyPolicy = getdata["data"]["privacy_policy"][0].toString();
          } else {
            setSnackbar(msg);
          }
          setState(
            () {
              _isLoading = false;
            },
          );
        },
        onError: (error) {
          setSnackbar(error.toString());
        },
      );
    } else {
      setState(
        () {
          _isLoading = false;
          _isNetworkAvail = false;
        },
      );
    }
  }

//=============================== Snackbar =====================================

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: black),
        ),
        backgroundColor: white,
        elevation: 1.0,
      ),
    );
  }

//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: getAppBar(
        widget.title!,
        context,
      ),
      body: _isNetworkAvail
          ? _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Html(
                    data: () {
                      if (widget.index == 1) {
                        return contactUs ?? "";
                      } else if (widget.index == 2) {
                        return termCondition ?? "";
                      } else if (widget.index == 3) {
                        return privacyPolicy ?? "";
                      } else if (widget.index == 4) {
                        return returnPolicy ?? "";
                      } else if (widget.index == 5) {
                        return shippingPolicy ?? "";
                      } else {
                        return "";
                      }
                    }(),
                  ),
                )
          : noInternet(context),
    );
  }
}

//============================ No Internet Widget ==============================

noInternet(BuildContext context) {
  return Center(
    child: Text(
      getTranslated(context, "NoInternetAwailable")!,
    ),
  );
}
