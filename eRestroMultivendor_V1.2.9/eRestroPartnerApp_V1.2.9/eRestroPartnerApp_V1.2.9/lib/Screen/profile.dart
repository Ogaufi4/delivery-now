import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/Map.dart';
import 'package:project/Screen/media.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import '../Helper/api_base_helper.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../Model/RestorentTime Model/weekTime.dart';
import '../Model/city/cityModel.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

String? latitutute, longitude;
List<String> profileImage = [];
String? lat, long;
List<Map<String, dynamic>> workingDaysvar = [];

class StateProfile extends State<Profile> with TickerProviderStateMixin {
//========================== Variable Dectlaration =============================
  List<Map<String, dynamic>> workingDaysvar = [];
  var addressProfFile, nationalIdentityCardFile, storeLogoFile;
  late Future<TimeOfDay?> selectedTime24Hour;
  List<WeekTimeModel> timeList = [];
  //morning time
  TimeOfDay timeSunM = const TimeOfDay(hour: 09, minute: 00),
      timeMonM = const TimeOfDay(hour: 00, minute: 00),
      timeTueM = const TimeOfDay(hour: 00, minute: 00),
      timeWedM = const TimeOfDay(hour: 00, minute: 00),
      timeThuM = const TimeOfDay(hour: 00, minute: 00),
      timeFriM = const TimeOfDay(hour: 00, minute: 00),
      timeSatM = const TimeOfDay(hour: 00, minute: 00);
  // evening time
  TimeOfDay timeSunE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeMonE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeTueE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeWedE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeThuE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeFriE = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay timeSatE = const TimeOfDay(hour: 00, minute: 00);
  // ''''
  bool? suncheck = false,
      moncheck = false,
      tuecheck = false,
      wedcheck = false,
      thucheck = false,
      fricheck = false,
      satcheck = false;
  String? name,
      email,
      mobile,
      address,
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
      cityName,
      licenceName,
      licenceCode,
      licenceStatus;
  String? commisionValue;
  int typeOfRestorent = 1;
  bool restorentstatus = true;
  bool cityLoading = true;
  String restorentsStatus = "1";
  String selfPickup = "1";
  String deliveryOrdersStatus = '1';

  int? selCityPos = -1;
  StateSetter? cityState;
  List<CityModel> citySearchLIst = [];
  List<CityModel> cityList = [];
  bool _isLoading = true;
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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
      licenceNameC,
      licenceCodeC;

  bool isSelected = false;
  bool _isNetworkAvail = true;
  bool _showCurPassword = false, _showPassword = false, _showCmPassword = false;
  Animation? buttonSqueezeanimation;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  AnimationController? buttonController;
  List<File> licenceProofFile = [];

  // Add this controller for location search
  // final TextEditingController _locationSearchController = TextEditingController();
  // List<SuggestionItem> _locationSuggestions = [];
  // bool _isLocationLoading = false;

  String? _localSelectedAddress;

//============================= Init method ====================================

  @override
  void initState() {
    super.initState();
    print("JWT_TOCKEN: $JWT_TOCKEN");

    mobileC = TextEditingController();
    nameC = TextEditingController();
    emailC = TextEditingController();
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
    curPassC = TextEditingController();
    newPassC = TextEditingController();
    confPassC = TextEditingController();

    getCities();
    getRestaurantDetail();
    profileImage = [];
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cityController.addListener(
      () {
        citySearch(
          _cityController.text,
        );
      },
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

    _loadLocalAddress();
  }

  Future<void> _loadLocalAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _localSelectedAddress = prefs.getString('profile_address');
    if (_localSelectedAddress != null && _localSelectedAddress!.isNotEmpty) {
      addressC?.text = _localSelectedAddress!;
      setState(() {});
    }
  }

  Future<void> _saveLocalAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_address', address);
  }

//============================= dispose method =================================

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    emailC!.dispose();
    storenameC!.dispose();
    storeurlC!.dispose();
    storeDescC!.dispose();
    accnameC!.dispose();
    accnumberC!.dispose();
    bankcodeC!.dispose();
    banknameC!.dispose();
    latitututeC!.dispose();
    longituteC!.dispose();
    taxnameC!.dispose();
    pannumberC!.dispose();
    taxnumberC!.dispose();
    licenceNameC!.dispose();
    licenceCodeC!.dispose();
    // _locationSearchController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//================= User Details frome Shared Preferance =======================
  Future<void> getRestaurantDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      CUR_USERID = await getPrefrence(Id);
      var parameter = {Id: CUR_USERID};
      apiBaseHelper
          .postAPICall(getRestaurantDetailsApi, parameter, context)
          .then(
        (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            commisionValue = data[0]["commission"] ?? "";
            var timeWeek = data[0]["partner_working_time"] as List;
            timeList = timeWeek
                .map(
                  (timeWeek) => WeekTimeModel.fromJson(timeWeek),
                )
                .toList();
            mobile = data[0][Mobile];
            name = data[0]["owner_name"];
            email = data[0][Email];
            address = data[0]["partner_address"];
            CUR_USERID = data[0]["partner_id"];
            storename = data[0][restaurantName];
            cookingtime = data[0]["cooking_time"];
            storeDesc = data[0][description];
            accNo = data[0][accountNumber];
            accname = data[0][accountName];
            bankcode = data[0][BankCOde];
            bankname = data[0][bankNAme];
            latitutute = data[0][Latitude];
            longitude = data[0][Longitude];
            taxname = data[0][taxName];
            taxnumber = data[0][taxNumber];
            pannumber = data[0][panNumber];
            licenceName = data[0][licence_name];
            licenceCode = data[0][licence_code];
            licenceStatus = data[0][licence_status];
            status = data[0][STATUS];
            typeOfRestorent = int.parse(data[0]["partner_indicator"]);

            status == "0" ? restorentstatus = false : restorentstatus = true;

            restorentsStatus = status!;
            deliveryOrdersStatus = data[0]["permissions"]['delivery_orders'];
            selfPickup = data[0]["permissions"]['self_pickup'];
            storelogo = data[0]["partner_profile"];
            city = data[0]["city_id"];
            cityName = data[0]["city_name"];
            mobileC!.text = mobile ?? "";
            nameC!.text = name ?? "";
            emailC!.text = email ?? "";
            addressC!.text = address ?? "";
            storenameC!.text = storename ?? "";
            storeurlC!.text = cookingtime ?? "";
            storeDescC!.text = storeDesc ?? "";
            accnameC!.text = accname ?? "";
            accnumberC!.text = accNo ?? "";
            bankcodeC!.text = bankcode ?? "";
            banknameC!.text = bankname ?? "";
            latitututeC!.text = latitutute ?? "";
            longituteC!.text = longitude ?? "";
            taxnameC!.text = taxname ?? "";
            taxnumberC!.text = taxnumber ?? "";
            pannumberC!.text = pannumber ?? "";
            licenceNameC!.text = licenceName ?? "";
            licenceCodeC!.text = licenceCode ?? "";
            //weekEnd Time
            for (var element in timeList) {
              if (element.day == "Sunday") {
                timeSunM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeSunE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                suncheck = true;
              } else if (element.day == "Monday") {
                timeMonM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeMonE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                moncheck = true;
              } else if (element.day == "Tuesday") {
                timeTueM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeTueE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                tuecheck = true;
              } else if (element.day == "Wednesday") {
                timeWedM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeWedE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                wedcheck = true;
              } else if (element.day == "Thursday") {
                timeThuM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeThuE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                thucheck = true;
              } else if (element.day == "Friday") {
                timeFriM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeFriE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                fricheck = true;
              } else if (element.day == "Saturday") {
                timeSatM = TimeOfDay(
                    hour: int.parse(element.openingTime!.substring(0, 2)),
                    minute: int.parse(element.openingTime!.substring(3, 5)));
                timeSatE = TimeOfDay(
                    hour: int.parse(element.closingTime!.substring(0, 2)),
                    minute: int.parse(element.closingTime!.substring(3, 5)));
                satcheck = true;
              }
            }
            _isLoading = false;
            setState(
              () {},
            );
          } else {
            setsnackbar(
              msg!,
              context,
            );
          }
        },
        onError: (error) {
          setsnackbar(
            error.toString(),
            context,
          );
        },
      );
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isLoading = false;
          },
        );
      }
    }
    return;
  }

  Future<void> getCities() async {
    try {
      Response response = await post(
        getCitiesApi,
        headers: await ApiUtils.getHeaders(),
      ).timeout(
        const Duration(
          seconds: timeOut,
        ),
      );

      var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        cityList =
            (data as List).map((data) => CityModel.fromJson(data)).toList();

        citySearchLIst.addAll(cityList);
      } else {
        setsnackbar(msg!, context);
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
      setsnackbar(
        getTranslated(context, 'somethingMSg')!,
        context,
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

//===================== noInternet Widget ======================================

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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

                Future.delayed(
                  const Duration(seconds: 2),
                ).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
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

//========================= Network awailabilitry ==============================

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await buttonController!.reverse();
      restorentRegisterAPI();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
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
      workingDaysvar.removeAt(
        selectedDayIndedx,
      );
    }
    if (check!) {
      Map<String, dynamic> singleday = {
        "day": day,
        "opening_time": "${opening.hour}:${opening.minute}:00",
        "closing_time": "${closing.hour}:${closing.minute}:00",
        "is_open": "1"
      };
      workingDaysvar.add(
        singleday,
      );
    }
  }

//============================= For API Call ==================================

  Future<void> restorentRegisterAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
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
        var request = http.MultipartRequest(
          "POST",
          updateUserApi,
        );
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[Id] = CUR_USERID!;
        if (mobile != null) {
          request.fields["name"] = name!;
        }
        if (mobile != null) {
          request.fields[Mobile] = mobile!;
        }
        if (email != null) {
          request.fields[Email] = email!;
        }
        if (address != null) {
          request.fields[Address] = address!;
        }
        if (storename != null) {
          request.fields[restaurantName] = storename!;
        }
        if (taxname != null) {
          request.fields[tax_name] = taxname!;
        }
        if (taxnumber != null) {
          request.fields[tax_number] = taxnumber!;
        }
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
        if (latitutute != null) {
          request.fields[Latitude] = latitutute!;
        }
        if (longitude != null) {
          request.fields[Longitude] = longitude!;
        }
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
        if (cookingtime != null) {
          request.fields["cooking_time"] = cookingtime!;
        }
        if (addressProfFile != null) {
          final mimeType = lookupMimeType(addressProfFile.path);
          var extension = mimeType!.split("/");
          var addproff = await http.MultipartFile.fromPath(
            AddressProof,
            addressProfFile.path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
          );
          request.files.add(addproff);
        }
        if (nationalIdentityCardFile != null) {
          final mimeType = lookupMimeType(nationalIdentityCardFile.path);
          var extension = mimeType!.split("/");
          var nationalproff = await http.MultipartFile.fromPath(
            NationalIdentityCard,
            nationalIdentityCardFile.path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
          );
          request.files.add(nationalproff);
        }
        if (storeLogoFile != null) {
          final mimeType = lookupMimeType(storeLogoFile.path);
          var extension = mimeType!.split("/");
          var storelogo = await http.MultipartFile.fromPath(
            "profile",
            storeLogoFile.path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
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
        if (profileImage.isNotEmpty) {
          request.fields["gallary"] = profileImage.join(",");
        }
        request.fields["type"] = typeOfRestorent.toString();
        request.fields["status"] = restorentsStatus;
        request.fields["delivery_orders"] = deliveryOrdersStatus;
        request.fields["self_pickup"] =
            selfPickup; //request.fields["restro_profile"] = selfPickup;

        if (city != null) {
          request.fields["city_id"] = city!;
        }

        var weekdaysjson = json.encode(workingDaysvar);
        request.fields["working_time"] = weekdaysjson;
        print(request.fields);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        print("getdata:${request.fields["restro_profile"]}--$getdata");
        if (!error) {
          showMsgDialog(msg!);
          await buttonController!.reverse();
        } else {
          if (getdata[statusCode] == "120") {
            reLogin(context);
          }
          await buttonController!.reverse();
          showMsgDialog(msg!);
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(
            context,
            'somethingMSg',
          )!,
          context,
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

  showMsgDialog(String msg) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    padding: const EdgeInsets.fromLTRB(
                      20.0,
                      20.0,
                      20.0,
                      20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg,
                            style: const TextStyle(
                              color: fontColor,
                            ),
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

//========================== build Method ======================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      //backgroundColor: lightWhite,
      backgroundColor: white,
      appBar: getAppBar(
        getTranslated(context, "EDIT_PROFILE_LBL")!,
        context,
      ),
      body: _isLoading ? showCircularProgress() : bodyPart(),
    );
  }

//========================== build Method ======================================
  bodyPart() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: _isNetworkAvail
            ? Column(
                children: <Widget>[
                  getprofileImage(),
                  getFirstHeader(),
                  getSecondHeader(),
                  getThirdHeader(),
                  getFurthHeader(),
                  changePass(),
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
                  otherImages(
                    getTranslated(context, "Profile")!,
                    0,
                  ),
                  uploadedOtherImageShow(),
                  restorentType(),
                  restorentStatus(),
                  deliveryOrdersStatusSwitch(),
                  selfPickupStatus(),
                  setCities(),
                  workingDays(),
                  permissions(),
                  adminCommition(),
                  updateBtn(),
                ],
              )
            : noInternet(context),
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

  permissions() {
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
            "${getTranslated(context, "Permissions")!} *",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 08,
          ),
          permissionField(
            getTranslated(context, "View Customer's Details? ")!,
            customerViewPermission,
          ),
          const SizedBox(
            height: 08,
          ),
          permissionField(
            getTranslated(context, "View Order's OTP? *")!,
            viewOrderOtp,
          ),
          const SizedBox(
            height: 08,
          ),
          permissionField(
            getTranslated(
                context, "Can assign Rider? & Can chnage deliver status? *")!,
            assignRider,
          ),
          const SizedBox(
            height: 08,
          ),
          permissionField(
            getTranslated(context, "Email Notification? *")!,
            isEmailSettingOn,
          ),
        ],
      ),
    );
  }

  permissionField(String title, bool val) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 5,
          ),
          Expanded(
            flex: 10,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 1,
            child: val
                ? const Icon(
                    Icons.done,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
          ),
        ],
      ),
    );
  }

  adminCommition() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "Admin Commission(%) ")!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  getTranslated(context,
                      "(Commission(%) to be given to the Super Admin on order.)")!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: white,
              ),
              child: Text(
                commisionValue!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
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
              fontWeight: FontWeight.bold,
            ),
          ),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
            ),
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
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    pickTime(
                      context,
                      index,
                      false,
                    );
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
                getTranslated(
                  context,
                  "Open",
                )!,
              )
            ],
          ),
        ],
      ),
    );
  }

  setCities() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getTranslated(context, "Select City")!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          selCityPos != null && selCityPos != -1
                              ? citySearchLIst[selCityPos!].name!
                              : cityName != null
                                  ? cityName!
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
                    padding: const EdgeInsets.fromLTRB(
                      20.0,
                      20.0,
                      0,
                      0,
                    ),
                    child: Text(
                      getTranslated(
                        context,
                        "Select City",
                      )!,
                      style: const TextStyle(
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: primary,
                        size: 17,
                      ),
                      hintText: getTranslated(context, "Search")!,
                      hintStyle: TextStyle(
                        color: primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
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
                            padding: EdgeInsets.symmetric(
                              vertical: 50.0,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
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

  selfPickupStatus() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Self Pickup")!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Deliver Orders")!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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

  restorentStatus() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Status")!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  restorentstatus = value;
                  if (value) {
                    restorentsStatus = "1";
                  } else {
                    restorentsStatus = "0";
                  }
                },
              );
            },
            value: restorentstatus,
          ),
        ],
      ),
    );
  }

  restorentType() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(
              context,
              "Type of Restaurant",
            )!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: () {
              typeOfRestorent = 1;
              setState(
                () {},
              );
            },
            child: Container(
              decoration: typeOfRestorent == 1
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
              typeOfRestorent = 2;
              setState(() {});
            },
            child: Container(
              decoration: typeOfRestorent == 2
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
              typeOfRestorent = 3;
              setState(() {});
            },
            child: Container(
              decoration: typeOfRestorent == 3
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
    );
  }

  uploadedOtherImageShow() {
    return profileImage.isEmpty
        ? Container()
        : SizedBox(
            width: double.infinity,
            height: 105,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: profileImage.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.all(
                    6.0,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Image.network(
                        profileImage[i],
                        width: 150,
                        height: 200,
                      ),
                      InkWell(
                        onTap: () {
                          if (mounted) {
                            setState(
                              () {
                                profileImage.removeAt(i);
                              },
                            );
                          }
                        },
                        child: Container(
                          color: black,
                          child: const Icon(
                            Icons.clear,
                            size: 18,
                            color: white,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
  }

  otherImages(String from, int pos) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.only(
        top: 30.0,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Restaurant Images")!,
            style: const TextStyle(
              fontSize: 16,
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
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Media(
                    from: from,
                    pos: pos,
                    type: "profile",
                  ),
                ),
              ).then(
                (value) {
                  setState(
                    () {},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  selectedMainImageShow(File? name) {
    return name == null
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
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
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                name.length,
                (index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    name[index],
                    //width: 100,
                    height: 200,
                  ),
                ),
              ),
            ),
          );
  }

  uploadStoreLogo(
    String title,
    int number,
  ) {
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
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                width: 90,
                height: 40,
                child: Center(
                  child: Text(
                    getTranslated(
                      context,
                      "Upload",
                    )!,
                    style: const TextStyle(
                      color: white,
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
      setState(
        () {
          if (number == 1) {
            nationalIdentityCardFile = image;
          }
          if (number == 2) {
            addressProfFile = image;
          }
          if (number == 3) {
            storeLogoFile = image;
          }
        },
      );
    } else {
      // User canceled the picker
    }
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
    } else {
      // User canceled the picker
    }
  }

//=========================== profile Image ====================================

  getprofileImage() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 30.0,
      ),
      child: LOGO != ''
          ? Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: black,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  LOGO, height: 100, width: 100, fit: BoxFit.cover,
                  //radius: 100,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primary),
              ),
              child: const Icon(
                Icons.account_circle,
                size: 100,
              ),
            ),
    );
  }

//============================== First Header ==================================

  getFirstHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 5.0,
      ),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.person_outlined,
              getTranslated(context, "Owner Name")!,
              name,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "ADD_NAME_LBL")!,
              sellernameKey,
              TextInputType.text,
              (val) => validateUserName(val, context),
              0,
            ),
            getDivider(),
            commanDesingFields(
              Icons.phone_in_talk_outlined,
              getTranslated(context, "MOBILEHINT_LBL")!,
              mobile,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "Add Mobile Number")!,
              mobilenumberKey,
              TextInputType.number,
              (val) => validateMob(val, context),
              1,
            ),
            getDivider(),
            commanDesingFields(
              Icons.email_outlined,
              getTranslated(context, "Email")!,
              email,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addEmail")!,
              emailKey,
              TextInputType.text,
              (val) => validateField(val, context),
              2,
            ),
            getDivider(),
            commanDesingFields(
              Icons.location_on_outlined,
              getTranslated(context, "Addresh")!,
              address,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddAddress")!,
              addressKey,
              TextInputType.text,
              (val) => validateField(val, context),
              3,
            ),
          ],
        ),
      ),
    );
  }

//============================ Second Header ===================================

  getSecondHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 5.0,
      ),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.store_outlined,
              getTranslated(context, "restaurant Name")!,
              storename,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addStoreName")!,
              storenameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              4,
            ),
            getDivider(),
            //replace
            commanDesingFields(
              Icons.watch_later_outlined,
              getTranslated(context, "Cooking Time")!,
              cookingtime,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "Add Cooking Time")!,
              storeurlKey,
              TextInputType.number,
              (val) => validateField(val, context),
              5,
            ),
            getDivider(),
            commanDesingFields(
              Icons.description_outlined,
              getTranslated(context, "Description")!,
              storeDesc,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addDescription")!,
              storeDescKey,
              TextInputType.text,
              (val) => validateField(val, context),
              6,
            ),
          ],
        ),
      ),
    );
  }

//============================ Third Header ====================================

  getThirdHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 5.0,
      ),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.format_list_numbered_outlined,
              getTranslated(context, "AccountNumber")!,
              accNo,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addAccontNumber")!,
              accnumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              7,
            ),
            getDivider(),
            commanDesingFields(
              Icons.import_contacts_outlined,
              getTranslated(context, "AccountName")!,
              accname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addAccountName")!,
              accnameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              8,
            ),
            getDivider(),
            commanDesingFields(
              Icons.request_quote_outlined,
              getTranslated(context, "BankCode")!,
              bankcode,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addBankCode")!,
              bankcodeKey,
              TextInputType.text,
              (val) => validateField(val, context),
              9,
            ),
            getDivider(),
            commanDesingFields(
              Icons.account_balance_outlined,
              getTranslated(context, "BankName")!,
              bankname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addBankName")!,
              banknameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              10,
            ),
          ],
        ),
      ),
    );
  }

//========================= Fourth Header ======================================

  getFurthHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 5.0,
      ),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          side: BorderSide(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Column(
          children: <Widget>[
            commanDesingFields(
              Icons.travel_explore_outlined,
              getTranslated(context, "Latitute")!,
              latitutute,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLatitute")!,
              latitututeKey,
              TextInputType.text,
              (val) => validateField(val, context),
              11,
              true,
              true,
            ),
            getDivider(),
            commanDesingFields(
              Icons.language_outlined,
              getTranslated(context, "Longitude")!,
              longitude,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLongitude")!,
              longituteKey,
              TextInputType.text,
              (val) => validateField(val, context),
              12,
              true,
              false,
            ),
            getDivider(),
            commanDesingFields(
              Icons.text_snippet_outlined,
              getTranslated(context, "TaxName")!,
              taxname,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addTaxName")!,
              taxnameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              13,
            ),
            getDivider(),
            commanDesingFields(
              Icons.assignment_outlined,
              getTranslated(context, "TaxNumber")!,
              taxnumber,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addTaxNumber")!,
              taxnumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              14,
            ),
            getDivider(),
            commanDesingFields(
              Icons.picture_in_picture_outlined,
              getTranslated(context, "PanNumber")!,
              pannumber,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "addPanNumber")!,
              pannumberKey,
              TextInputType.text,
              (val) => validateField(val, context),
              15,
            ),
            getDivider(),
            commanDesingFields(
              Icons.picture_in_picture_outlined,
              getTranslated(context, "LicenceName")!,
              licenceName,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLicenceName")!,
              licenceNameKey,
              TextInputType.text,
              (val) => validateField(val, context),
              16,
            ),
            getDivider(),
            commanDesingFields(
              Icons.picture_in_picture_outlined,
              getTranslated(context, "LicenceCode")!,
              licenceCode,
              getTranslated(context, "NotAdded")!,
              getTranslated(context, "AddLicenceCode")!,
              licenceCodeKey,
              TextInputType.text,
              (val) => validateField(val, context),
              17,
            ),
          ],
        ),
      ),
    );
  }

//============================== Divider =======================================

  getDivider() {
    return const Divider(
      height: 1,
      color: black,
    );
  }

//=========================== Saller Name ======================================
  commanDesingFields(
    IconData? icon,
    String title,
    String? variable,
    String empty,
    String addField,
    GlobalKey<FormState> key,
    TextInputType? keybordtype,
    String? Function(String?)? validation,
    int index, [
    bool? fromMap,
    bool? Langitute,
  ]) {
    bool isFromMap = fromMap ?? false;
    bool isFromLangitute = Langitute ?? false;

    return Padding(
      padding: const EdgeInsets.all(
        15.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(
              icon,
              color: primary,
              size: 27,
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: lightBlack2,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  variable != "" && variable != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                variable,
                                style: const TextStyle(
                                  color: lightBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            index == 17
                                ? Text(
                                    licenceStatus == "0"
                                        ? getTranslated(context, "notApproved")!
                                        : getTranslated(context, "approved")!,
                                    style: const TextStyle(
                                      color: red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              empty,
                              style: const TextStyle(
                                color: lightBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            index == 17
                                ? Text(
                                    licenceStatus == "0"
                                        ? getTranslated(context, "notApproved")!
                                        : getTranslated(context, "approved")!,
                                    style: const TextStyle(
                                      color: red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                ],
              ),
            ),
          ),
          isFromMap
              ? isFromLangitute
                  ? IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        size: 20,
                        color: primary,
                      ),
                      onPressed: () async {
                        LocationPermission permission;
                        permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        final LocationSettings locationSettings =
                            LocationSettings(
                          accuracy: LocationAccuracy.high,
                          // distanceFilter: 100,
                        );
                        Position position = await Geolocator.getCurrentPosition(
                            locationSettings: locationSettings);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              latitude: longitude == null || longitude == ''
                                  ? position.latitude
                                  : double.parse(longitude!),
                              longitude: longitude == null || longitude == ''
                                  ? position.longitude
                                  : double.parse(longitude!),
                            ),
                          ),
                        ).then((result) async {
                          if (result != null &&
                              result is Map<String, dynamic>) {
                            _localSelectedAddress = result['maintext'] ?? '';
                            addressC!.text = _localSelectedAddress!;
                            address = _localSelectedAddress!;
                            latitututeC!.text =
                                result['latitude']?.toString() ?? '';
                            longituteC!.text =
                                result['longitude']?.toString() ?? '';
                            await _saveLocalAddress(_localSelectedAddress!);
                            setState(() {});
                          }
                        });
                      },
                    )
                  : Container()
              : Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 20,
                      color: black,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: const EdgeInsets.all(0),
                            elevation: 2.0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20.0,
                                    20.0,
                                    0,
                                    2.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        addField,
                                        style: const TextStyle(
                                          color: primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(color: black),
                                Form(
                                  key: key,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20.0,
                                      0,
                                      20.0,
                                      0,
                                    ),
                                    child: TextFormField(
                                      keyboardType: keybordtype,
                                      style: const TextStyle(
                                        color: black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      validator: validation,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
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
                                          return licenceNameC;
                                        } else if (index == 17) {
                                          return licenceCodeC;
                                        }
                                        return unusedC;
                                      }(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  getTranslated(context, "CANCEL")!,
                                  style: const TextStyle(
                                    color: lightBlack,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  setState(
                                    () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                              TextButton(
                                child: Text(
                                  getTranslated(context, "SAVE_LBL")!,
                                  style: const TextStyle(
                                    color: primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  final form = key.currentState!;
                                  if (form.validate()) {
                                    form.save();
                                    setState(
                                      () {
                                        () {
                                          if (index == 0) {
                                            name = nameC!.text;
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
                                            licenceName = licenceNameC!.text;
                                          } else if (index == 17) {
                                            licenceCode = licenceCodeC!.text;
                                          }
                                        }();
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
        ],
      ),
    );
  }

//============================ Change Pass =====================================

  changePass() {
    return SizedBox(
      height: 60,
      width: width,
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 15.0,
              bottom: 15.0,
            ),
            child: Text(
              getTranslated(context, "CHANGE_PASS_LBL")!,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            _showDialog();
          },
        ),
      ),
    );
  }

  _showDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setStater,
          ) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        20.0,
                        0,
                        2.0,
                      ),
                      child: Text(
                        getTranslated(context, "CHANGE_PASS_LBL")!,
                        style: const TextStyle(color: fontColor),
                      ),
                    ),
                    const Divider(color: lightBlack),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20.0,
                              0,
                              20.0,
                              0,
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (val) => validatePass(val, context),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "CUR_PASS_LBL")!,
                                hintStyle: const TextStyle(
                                  color: lightBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showCurPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showCurPassword = !_showCurPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              obscureText: !_showCurPassword,
                              controller: curPassC,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20.0,
                              0,
                              20.0,
                              0,
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (val) => validatePass(val, context),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText:
                                    getTranslated(context, "NEW_PASS_LBL")!,
                                hintStyle: const TextStyle(
                                  color: lightBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showPassword = !_showPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              onChanged: (v) => setState(
                                () {
                                  newPass = v;
                                },
                              ),
                              obscureText: !_showPassword,
                              controller: newPassC,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              20.0,
                              0,
                              20.0,
                              0,
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return getTranslated(
                                      context, "CON_PASS_REQUIRED_MSG")!;
                                }
                                if (value != newPass) {
                                  return getTranslated(
                                      context, "CON_PASS_NOT_MATCH_MSG")!;
                                } else {
                                  return null;
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    context, "CONFIRMPASSHINT_LBL")!,
                                hintStyle: const TextStyle(
                                  color: lightBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_showCmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  iconSize: 20,
                                  color: lightBlack,
                                  onPressed: () {
                                    setStater(
                                      () {
                                        _showCmPassword = !_showCmPassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              obscureText: !_showCmPassword,
                              controller: confPassC,
                              onChanged: (v) => setState(
                                () {
                                  confPass = v;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, "CANCEL")!,
                    style: const TextStyle(
                      color: lightBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, "SAVE_LBL")!,
                    style: const TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final form = formKey.currentState!;
                    if (form.validate()) {
                      curPass = curPassC!.text;
                      newPass = newPassC!.text;
                      form.save();
                      setState(
                        () {
                          Navigator.pop(context);
                        },
                      );
                      changePassWord();
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

//==================== Same API But Only PassPassword ==========================

  Future<void> changePassWord() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        Id: CUR_USERID,
        Name: name ?? "",
        Mobile: mobile ?? "",
        Email: email ?? "",
        Address: address ?? "",
        StoreName: storename ?? "",
        Storeurl: cookingtime ?? "",
        storeDescription: storeDesc ?? "",
        accountNumber: accNo ?? "",
        accountName: accname ?? "",
        bankCode: bankcode ?? "",
        bankName: bankname ?? "",
        Latitude: latitutute ?? "",
        Longitude: longitude ?? "",
        taxName: taxname ?? "",
        taxNumber: taxnumber ?? "",
        panNumber: pannumber ?? "",
        STATUS: status ?? "1",
        OLDPASS: curPass,
        NEWPASS: newPass,
        restaurantName: storename,
        description: storeDesc,
        "cooking_time": cookingtime,
        "type": typeOfRestorent.toString(),
        "delivery_orders": deliveryOrdersStatus
      };
      apiBaseHelper.postAPICall(updateUserApi, parameter, context).then(
        (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            Navigator.pop(context);
            setsnackbar(
              msg!,
              context,
            );
          } else {
            Navigator.pop(context);
            setsnackbar(
              msg!,
              context,
            );
          }
        },
        onError: (error) {
          setsnackbar(
            error.toString(),
            context,
          );
        },
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
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

//============================== LoginBtn ======================================

  updateBtn() {
    return AppBtn(
      title: getTranslated(context, "Update Profile")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        _playAnimation();
        checkNetwork();
      },
    );
  }

//========================= circular Progress ==================================

  Widget showCircularProgress() {
    return const Center(
      child: CircularProgressIndicator(
        color: primary,
      ),
    );
  }

  // Add this widget to the form, above setCities()
  // Widget locationSearchField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         getTranslated(context, "Search Location") ?? "Search Location",
  //         style: Theme.of(context).textTheme.bodySmall,
  //       ),
  //       TextField(
  //         controller: _locationSearchController,
  //         decoration: InputDecoration(
  //           prefixIcon: Icon(Icons.search, color: primary, size: 20),
  //           hintText: getTranslated(context, "Type location...") ??
  //               "Type location...",
  //           suffixIcon: _isLocationLoading
  //               ? SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(strokeWidth: 2))
  //               : null,
  //         ),
  //       ),
  //       if (_locationSuggestions.isNotEmpty)
  //         Container(
  //           constraints: BoxConstraints(maxHeight: 200),
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: _locationSuggestions.length,
  //             itemBuilder: (context, index) {
  //               final suggestion = _locationSuggestions[index];
  //               final place = suggestion.placePrediction;
  //               return ListTile(
  //                 title: Text(place.structuredFormat.mainText.text.isNotEmpty
  //                     ? place.structuredFormat.mainText.text
  //                     : place.place),
  //                 subtitle: Text(place.structuredFormat.secondaryText.text),
  //                 onTap: () async {
  //                   setState(() {
  //                     _isLocationLoading = true;
  //                   });
  //                   var param = {'id': place.placeId};
  //                   var res = await apiBaseHelper.postAPICall(
  //                       getLocationDetailsUrl, param, context);
  //                   setState(() {
  //                     _isLocationLoading = false;
  //                   });
  //                   if (res != null) {
  //                     final details = LocationDetailsModel.fromJson(res);
  //                     addressC?.text = details.formattedAddress ?? '';
  //                     latitututeC?.text =
  //                         details.location?.latitude?.toString() ?? '';
  //                     longituteC?.text =
  //                         details.location?.longitude?.toString() ?? '';
  //                     if (details.addressComponents != null &&
  //                         details.addressComponents!.isNotEmpty) {
  //                       final cityComp = details.addressComponents!.firstWhere(
  //                         (c) =>
  //                             c.types != null && c.types!.contains('locality'),
  //                         orElse: () => AddressComponents(),
  //                       );
  //                       if (cityComp.longText != null &&
  //                           cityComp.longText!.isNotEmpty) {
  //                         _cityController.text = cityComp.longText!;
  //                         cityName = cityComp.longText!;
  //                       }
  //                     }
  //                     _locationSearchController.text =
  //                         details.formattedAddress ?? details.name ?? '';
  //                     _locationSuggestions = [];
  //                     setState(() {});
  //                   }
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //     ],
  //   );
  // }

//========================= everything is completed ============================
}
