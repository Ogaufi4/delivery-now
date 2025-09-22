import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/MyTransactions.dart';
import 'package:project/Screen/promocodeList.dart';
import 'package:project/Screen/tags.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import '../Helper/api_base_helper.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/indicator.dart';
import '../Helper/push_notification_service.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import '../Localization/language_constant.dart';
import '../Model/OrdersModel/order_model.dart';
import '../main.dart';
import 'TermFeed/policys.dart';
import 'addAttribute.dart';
import 'add_product.dart';
import 'Authentication/login.dart';
import 'customers.dart';
import 'orderList.dart';
import 'productList.dart';
import 'profile.dart';
import 'walletHistory.dart';

class Home extends StatefulWidget {
  static final GlobalKey<_HomeState> globalKey = GlobalKey<_HomeState>();
  Home({Key? key}) : super(key: globalKey);

  @override
  _HomeState createState() => _HomeState();
}

int? total, offset;
List<Order_Model> orderList = [];
bool _isLoading = true;
bool isLoadingmore = true;
String? delPermission;
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
bool customerViewPermission = false;
bool viewOrderOtp = false;
bool assignRider = false;
bool isEmailSettingOn = false;

class _HomeState extends State<Home> with TickerProviderStateMixin {
//============================= Variables Declaration ==========================
  int curDrwSel = 0;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String?> languageList = [];
  List<Order_Model> tempList = [];
  String? all, received, processed, shipped, delivered, cancelled, returned, awaiting;
  String? totalorderCount,
      totalproductCount,
      totalcustCount,
      totaldelBoyCount,
      totalsoldOutCount,
      tagCount,
      totallowStockCount,
      totalTransactionCount;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  ScrollController? controller;
  int? selectLan;
  bool _isNetworkAvail = true;
  String? activeStatus;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

//===================================== For Chart ==============================

  int curChart = 0;
  Map<int, LineChartData>? chartList;
  List? days = [], dayEarning = [];
  List? months = [], monthEarning = [];
  List? weeks = [], weekEarning = [];
  List? catCountList = [], catList = [];
  List colorList = [];
  int? touchedIndex;

//============================= For Language Selection =========================

  List<String> langCode = [ENGLISH, HINDI, URDU];

  get lightWhite => null;
  String globalRestaurantTimeStatus = "1";
  String partnerWishPromocode = "0";

//============================= initState Method ===============================

  @override
  void initState() {
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();

    offset = 0;
    total = 0;
    chartList = {0: dayData(), 1: weekData(), 2: monthData()};

    orderList.clear();
    getSaveDetail();
    getStatics();
    getSetting();
    getRestaurantDetail();

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
    controller = ScrollController(keepScrollOffset: true);
    Future.delayed(
      Duration.zero,
      () {
        languageList = [
          getTranslated(context, 'English'),
          getTranslated(context, 'Hindi'),
          getTranslated(context, 'Urdu'),
        ];
      },
    );
    super.initState();
  }

//============================= getSaveDetail ==================================

  getSaveDetail() async {
    String getlng = await getPrefrence(LAGUAGE_CODE) ?? '';

    selectLan = langCode.indexOf(getlng == '' ? "en" : getlng);
  }

//============================= For Animation ==================================

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
      ),
    );
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightWhite,
        appBar: getAppBar(context),
        drawer: getDrawer(context),
        body: getBodyPart(),
        floatingActionButton: floatingBtn(),
      ),
    );
  }

//=============================== floating Button ==============================

  floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: black,
          child: const Icon(
            Icons.add,
            size: 32,
            color: white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const AddProduct(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

//=============================== chart coding  ================================

  getChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: backgroun1,
        ),
        height: 250,
        child: Card(
          elevation: 0,
          color: backgroun1,
          margin: const EdgeInsets.only(top: 10, left: 5, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8),
                  child: Text(
                    getTranslated(context, "ProductSales")!,
                    style: const TextStyle(color: primary),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: curChart == 0
                        ? TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: black,
                            disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                          )
                        : null,
                    onPressed: () {
                      setState(
                        () {
                          curChart = 0;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Day")!,
                    ),
                  ),
                  TextButton(
                    style: curChart == 1
                        ? TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: black,
                            disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                          )
                        : null,
                    onPressed: () {
                      setState(
                        () {
                          curChart = 1;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Week")!,
                    ),
                  ),
                  TextButton(
                    style: curChart == 2
                        ? TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: black,
                            disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                          )
                        : null,
                    onPressed: () {
                      setState(
                        () {
                          curChart = 2;
                        },
                      );
                    },
                    child: Text(
                      getTranslated(context, "Month")!,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: LineChart(
                  chartList![curChart]!,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

//1. LineChartData

  LineChartData dayData() {
    if (dayEarning!.isEmpty) {
      dayEarning!.add(0);
      days!.add(0);
    }
    List<FlSpot> spots = dayEarning!.asMap().entries.map(
      (e) {
        return FlSpot(
          double.parse(
            days![e.key].toString(),
          ),
          double.parse(
            e.value.toString(),
          ),
        );
      },
    ).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          color: primary,
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.5),
          ),
          aboveBarData: BarAreaData(
            show: true,
            color: fontColor.withValues(alpha: 0.2),
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, child) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: black,
                  fontSize: 08,
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(),
        topTitles: AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, child) {
              if (value.toInt() == child.max) {
                return const SizedBox.shrink();
              } else {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: black,
                    fontSize: 08,
                  ),
                );
              }
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  //2. catChart

  LineChartData weekData() {
    if (weekEarning!.isEmpty) {
      weekEarning!.add(0);
      weeks!.add(0);
    }
    List<FlSpot> spots = weekEarning!.asMap().entries.map(
      (e) {
        return FlSpot(
          double.parse(
            e.key.toString(),
          ),
          double.parse(
            e.value.toString(),
          ),
        );
      },
    ).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          color: primary,
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.5),
          ),
          aboveBarData: BarAreaData(
            show: true,
            color: fontColor.withValues(alpha: 0.2),
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, child) {
              return Text(
                weeks![value.toInt()].toString(),
                style: const TextStyle(
                  color: black,
                  fontSize: 08,
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(),
        topTitles: AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, child) {
              if (value.toInt() == child.max) {
                return const SizedBox.shrink();
              } else {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: black,
                    fontSize: 08,
                  ),
                );
              }
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  //2. monthData

  LineChartData monthData() {
    if (monthEarning!.isEmpty) {
      monthEarning!.add(0);
      months!.add(0);
    }

    List<FlSpot> spots = monthEarning!.asMap().entries.map(
      (e) {
        return FlSpot(
          double.parse(
            e.key.toString(),
          ),
          double.parse(
            e.value.toString(),
          ),
        );
      },
    ).toList();

    return LineChartData(
      lineTouchData: LineTouchData(enabled: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: 2,
          color: primary,
          belowBarData: BarAreaData(
            show: true,
            color: primary.withValues(alpha: 0.5),
          ),
          aboveBarData: BarAreaData(
            show: true,
            color: fontColor.withValues(alpha: 0.2),
          ),
          dotData: FlDotData(
            show: false,
          ),
        ),
      ],
      minY: 0,
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(),
        topTitles: AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 40,
            showTitles: true,
            getTitlesWidget: (value, child) {
              if (value.toInt() == child.max) {
                return const SizedBox.shrink();
              } else {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: black,
                    fontSize: 08,
                  ),
                );
              }
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, child) {
              return Text(
                months![value.toInt()].toString(),
                style: const TextStyle(
                  color: black,
                  fontSize: 08,
                ),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: fontColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  Color generateRandomColor() {
    Random random = Random();
    // Pick a random number in the range [0.0, 1.0)
    double randomDouble = random.nextDouble();
    return Color((randomDouble * 0xFFFFFF).toInt()).withValues(alpha: 1.0);
  }

//========================= getStatics API =====================================

  void appMaintenanceDialog() async {
    await dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (value, dynamic) async {},
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    setSvgPath(
                      "Maintenance",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: Text(
                      getTranslated(context, 'APP_MAINTENANCE')!,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getSetting() async {
    Map parameter = {};

    apiBaseHelper.postAPICall(getSettingsApi, parameter, context).then(
      (getdata) async {
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          var data = getdata['data']['system_settings'][0];
          Is_APP_IN_MAINTANCE = data['is_partner_app_maintenance_mode_on'];
          AUTHENTICATION_METHOD = (getdata['authentication_method'] ?? 0).toString();
          TAXGLOBAL = data['tax'];
          setState(
            () {},
          );
          if (Is_APP_IN_MAINTANCE == "1") {
            appMaintenanceDialog();
          }
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
  }

  Future<void> updateRestaurantStatus(String status) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          resturantId: CUR_USERID,
          globalRestaurantTime: status,
        };
        Response response =
            await post(updateRestaurantTimeAPI, headers: await ApiUtils.getHeaders(), body: parameter).timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            getRestaurantDetail();
          } else {
            if (getdata[statusCode] == "120") {
              reLogin(context);
            }
            setsnackbar(msg, context);
          }
        }
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, 'somethingMSg')!, context);

        setState(
          () {},
        );
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
    }
    return;
  }

  Future<void> getStatics() async {
    CUR_USERID = await getPrefrence(Id);
    CUR_USERNAME = await getPrefrence(Username);
    var parameter = {resturantId: CUR_USERID};

    apiBaseHelper.postAPICall(getStatisticsApi, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          CUR_CURRENCY = getdata["currency_symbol"];
          var count = getdata['counts'][0];
          totalorderCount = count["order_counter"];
          totalTransactionCount = count["transaction_counter"].toString();
          totalproductCount = count["product_counter"];
          totalsoldOutCount = count['count_products_sold_out_status'];
          tagCount = count['tag_counter'];
          totallowStockCount = count["count_products_low_status"];
          totalcustCount = count["user_counter"];

          weekEarning = getdata['earnings'][0]["weekly_earnings"]['total_sale'];
          days = getdata['earnings'][0]["daily_earnings"]['day'];
          dayEarning = getdata['earnings'][0]["daily_earnings"]['total_sale'];
          months = getdata['earnings'][0]["monthly_earnings"]['month_name'];
          monthEarning = getdata['earnings'][0]["monthly_earnings"]['total_sale'];
          customerViewPermission = () {
            if (count["permissions"]['customer_privacy'] == "1") {
              return true;
            } else {
              return false;
            }
          }();
          viewOrderOtp = () {
            if (count["permissions"]['view_order_otp'] == "1") {
              return true;
            } else {
              return false;
            }
          }();
          assignRider = () {
            if (count["permissions"]['assign_rider'] == "1") {
              return true;
            } else {
              return false;
            }
          }();
          isEmailSettingOn = () {
            if (count["permissions"]['is_email_setting_on'] == "1") {
              return true;
            } else {
              return false;
            }
          }();
          weeks = getdata['earnings'][0]["weekly_earnings"]['week'];
          chartList = {0: dayData(), 1: weekData(), 2: monthData()};

          catCountList = getdata['category_wise_food_count']['counter'];
          catList = getdata['category_wise_food_count']['cat_name'];

          colorList.clear();
          for (int i = 0; i < catList!.length; i++) {
            colorList.add(generateRandomColor());
          }
        } else {
          setsnackbar(msg!, context);
        }
        setState(
          () {
            _isLoading = false;
          },
        );
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
    return;
  }

//========================= get_seller_details API =============================

  Future<void> getRestaurantDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      String? jwtToken = await getPrefrence(token);
      print(jwtToken);
      CUR_USERID = await getPrefrence(Id);
      var parameter = {Id: CUR_USERID};
      apiBaseHelper.postAPICall(getRestaurantDetailsApi, parameter, context).then(
        (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            CUR_BALANCE = data[0][BALANCE].toString();
            LOGO = data[0]["partner_profile"].toString();
            RATTING = data[0]["partner_rating"] ?? "";
            NO_OFF_RATTING = data[0][NoOfRatings] ?? "";
            var id = data[0]["partner_id"];
            var username = data[0]["owner_name"];
            var email = data[0][Email];
            var mobile = data[0][Mobile];
            var address = data[0]["partner_address"];
            CUR_USERID = id!;
            CUR_USERNAME = username!;
            var srorename = data[0][restaurantName];
            var storeDesc = data[0][description];
            var accNo = data[0][accountNumber] ?? "";
            var accname = data[0][accountName];
            var bankCode = data[0][BankCOde];
            var bankName = data[0][bankNAme];
            var latitutute = data[0][Latitude];
            var longitude = data[0][Longitude];
            var taxname = data[0][taxName];
            var taxNumber = data[0]['tax_number'];
            var panNumber = data[0]['pan_number'];
            var status = data[0][STATUS];
            var cityid = data[0]["city_id"];
            var cityname = data[0]["city_name"];
            globalRestaurantTimeStatus = data[0][globalRestaurantTime];
            partnerWishPromocode = data[0]["permissions"]["partner_wise_promocode"];

            JWT_TOCKEN = jwtToken!;

            saveUserDetail(
                id!,
                username!,
                email!,
                mobile!,
                address!,
                srorename!,
                storeDesc!,
                accNo ?? "",
                accname ?? "",
                bankCode ?? "",
                bankName ?? "",
                latitutute ?? "",
                longitude ?? "",
                taxname ?? "",
                taxNumber!,
                panNumber ?? "",
                status!,
                storeLogo,
                cityid,
                cityname!,
                jwtToken);
          } else {
            setsnackbar(msg!, context);
          }
          setState(
            () {
              _isLoading = false;
            },
          );
        },
        onError: (error) {
          setsnackbar(error.toString(), context);
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

//============================ AppBar ==========================================

  getAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: const Text(
        appName,
        style: TextStyle(
          color: primary,
        ),
      ),
      backgroundColor: white,
      iconTheme: const IconThemeData(color: primary),
    );
  }

//============================= Drawer Implimentation ==========================

  getDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: white,
          child: ListView(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              _getHeader(),
              const Divider(),
              _getDrawerItem(0, getTranslated(context, "HOME")!, Icons.home_outlined),
              _getDrawerItem(1, getTranslated(context, "ORDERS")!, Icons.shopping_basket_outlined),
              const Divider(),
              _getDrawerItem(3, getTranslated(context, "WALLETHISTORY")!, Icons.account_balance_wallet_outlined),
              _getDrawerItem(11, getTranslated(context, "My Transactions")!, Icons.receipt_long_outlined),
              const Divider(),
              _getDrawerItem(4, getTranslated(context, "PRODUCTS")!, Icons.production_quantity_limits_outlined),
              _getDrawerItem(10, getTranslated(context, "Add Product")!, Icons.add),
              const Divider(),
              partnerWishPromocode == "1"
                  ? _getDrawerItem(14, getTranslated(context, "promoCode")!, Icons.discount_outlined)
                  : const SizedBox.shrink(),
              _getDrawerItem(13, getTranslated(context, "Add Attributes")!, Icons.edit_attributes_outlined),
              _getDrawerItem(12, getTranslated(context, "Tags")!, Icons.style_outlined),
              const Divider(),
              _getDrawerItem(14, getTranslated(context, "deleteAccount")!, Icons.delete_outline),
              _getDrawerItem(5, getTranslated(context, "ChangeLanguage")!, Icons.translate),
              _getDrawerItem(6, getTranslated(context, "Terms & Conditions")!, Icons.speaker_notes_outlined),
              const Divider(),
              _getDrawerItem(7, getTranslated(context, "PRIVACYPOLICY")!, Icons.lock_outline),
              _getDrawerItem(9, getTranslated(context, "CONTACTUS")!, Icons.contact_page_outlined),
              const Divider(),
              _getDrawerItem(8, getTranslated(context, "LOGOUT")!, Icons.logout),
            ],
          ),
        ),
      ),
    );
  }

  _getHeader() {
    return InkWell(
      child: Container(
        color: backgroundDark,
        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CUR_USERNAME!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text(
                      "${getTranslated(context, "WALLET_BAL")!}: $CUR_CURRENCY$CUR_BALANCE",
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getTranslated(context, "EDIT_PROFILE_LBL")!,
                            style: const TextStyle(color: white),
                          ),
                          const Icon(
                            Icons.arrow_right_outlined,
                            color: white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 20,
                  right: 20,
                ),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.0,
                    color: white,
                  ),
                ),
                child: LOGO != ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: sallerLogo(62),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: imagePlaceHolder(62),
                      ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Profile(),
          ),
        ).then(
          (value) {
            getStatics();
            getRestaurantDetail();
            setState(() {});
            Navigator.pop(context);
          },
        );
        setState(() {});
      },
    );
  }

//PlaceHolder Image For Drawer Header
  sallerLogo(double size) {
    return CircleAvatar(
      backgroundImage: NetworkImage(LOGO),
      radius: 25,
    );
  }

  imagePlaceHolder(double size) {
    return SizedBox(
      height: size,
      width: size,
      child: Icon(
        Icons.account_circle,
        color: Colors.white,
        size: size,
      ),
    );
  }

//Drawer Item List

  _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: const EdgeInsets.only(
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: curDrwSel == index
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primary, primary],
                stops: [0, 1],
              )
            : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icn,
          color: curDrwSel == index ? white : black,
        ),
        title: Text(
          title,
          style: TextStyle(color: curDrwSel == index ? white : black, fontSize: 15),
        ),
        onTap: () {
          if (title == getTranslated(context, "HOME")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
          } else if (title == getTranslated(context, "My Transactions")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionHistory(),
              ),
            );
          } else if (title == getTranslated(context, "ORDERS")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderList(),
              ),
            );
          } else if (title == getTranslated(context, "CUSTOMERS")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Customers(),
              ),
            );
          } else if (title == getTranslated(context, "Add Attributes")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddAttributes(),
              ),
            );
          } else if (title == getTranslated(context, "WALLETHISTORY")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WalletHistory(),
              ),
            );
          } else if (title == getTranslated(context, "PRODUCTS")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductList(
                  flag: '',
                ),
              ),
            );
          } else if (title == getTranslated(context, "ChangeLanguage")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            languageDialog();
          } else if (title == getTranslated(context, "Terms & Conditions")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Policy(
                  title: getTranslated(context, "TERM_CONDITIONS")!,
                  index: 2,
                ),
              ),
            );
          } else if (title == getTranslated(context, "CONTACTUS")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Policy(
                  title: getTranslated(context, "CONTACTUS")!,
                  index: 1,
                ),
              ),
            ).then(
              (value) {
                setState(
                  () {},
                );
              },
            );
          } else if (title == getTranslated(context, "PRIVACYPOLICY")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Policy(
                  title: getTranslated(context, "PRIVACYPOLICY")!,
                  index: 3,
                ),
              ),
            );
          } else if (title == getTranslated(context, "LOGOUT")!) {
            Navigator.pop(context);
            logOutDailog();
          } else if (title == getTranslated(context, "Add Product")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProduct(),
              ),
            );
          } else if (title == getTranslated(context, "Tags")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTags(),
              ),
            );
          } else if (title == getTranslated(context, "promoCode")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PromocodeList(),
              ),
            );
          } else if (title == getTranslated(context, "deleteAccount")!) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            Navigator.pop(context);
            deleteAccountDialog();
          }
        },
      ),
    );
  }

  deleteAccountDialog() async {
    await dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.13,
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                  child: Text(
                    getTranslated(context, 'deleteAccount')!,
                    style: Theme.of(this.context).textTheme.titleMedium!.copyWith(
                          color: white,
                        ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Text(
                          getTranslated(context, 'deleteYourAccount')!,
                          style: Theme.of(this.context).textTheme.bodySmall!.copyWith(
                                color: black,
                              ),
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          getTranslated(context, 'deleteYourAccountSubTitle')!,
                          style: Theme.of(this.context).textTheme.bodySmall!.copyWith(
                                color: black,
                              ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
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
                  getTranslated(context, "delete")!,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  deleteAccountApi();
                },
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteAccountApi() async {
    CUR_USERID = await getPrefrence(Id);
    Map parameter = {resturantId: CUR_USERID};

    apiBaseHelper.postAPICall(deletePartnerApi, parameter, context).then(
      (getdata) async {
        bool error = getdata['error'];
        String? msg = getdata['message'];

        if (!error) {
          Navigator.pop(context);
          clearUserSession();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const Login(),
              ),
              (Route<dynamic> route) => false);
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
  }

//============================= Language Implimentation ========================

  languageDialog() async {
    await dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.13,
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                  child: Text(
                    getTranslated(context, 'CHOOSE_LANGUAGE_LBL')!,
                    style: Theme.of(this.context).textTheme.titleMedium!.copyWith(
                          color: white,
                        ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: getLngList(context)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

//======================== Language List Generate ==============================

  List<Widget> getLngList(BuildContext ctx) {
    return languageList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(
                    () {
                      selectLan = index;
                      _changeLan(langCode[index], ctx);

                      print("selectLan--$selectLan--index--$index--langCode--${langCode[index]}");
                    },
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 25.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectLan == index ? primary : white,
                            border: Border.all(color: primary),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: selectLan == index
                                ? const Icon(
                                    Icons.check,
                                    size: 17.0,
                                    color: white,
                                  )
                                : const Icon(
                                    Icons.check_box_outline_blank,
                                    size: 15.0,
                                    color: white,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 15.0,
                          ),
                          child: Text(
                            languageList[index]!,
                            style: const TextStyle(color: lightBlack),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    index == languageList.length - 1
                        ? Container(
                            margin: const EdgeInsetsDirectional.only(
                              bottom: 10,
                            ),
                          )
                        : const Divider(
                            color: lightBlack,
                          ),
                  ],
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  void _changeLan(String language, BuildContext ctx) async {
    Locale locale = await setLocale(language);

    MyApp.setLocale(ctx, locale);
  }

//============================= Log-Out Implimentation =========================

  logOutDailog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Text(
                getTranslated(context, "LOGOUTTXT")!,
                style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, "LOGOUTNO")!,
                      style: const TextStyle(
                        color: lightBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: const TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    clearUserSession();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                        (Route<dynamic> route) => false);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

//=========================== Body Part Implimentation =========================

  getBodyPart() {
    return _isNetworkAvail
        ? _isLoading
            ? shimmer()
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 8,
                      right: 8,
                    ),
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10.0)),
                            padding: EdgeInsetsDirectional.all(16.0),
                            margin: EdgeInsetsDirectional.only(start: width / 40.0, end: width / 40.0, top: height / 99.0, bottom: height / 50.0),
                            child: Row(
                              children: [
                                Text(getTranslated(context, "acceptingOrder")!,
                                    style: TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w500)),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(globalRestaurantTimeStatus == "1" ? getTranslated(context, "onLabel")! : getTranslated(context, "offLabel")!,
                                        style: TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w500)),
                                    SizedBox(width: width / 40.0),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.decelerate,
                                        width: 52,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16.0),
                                          color: globalRestaurantTimeStatus == "1" ? white : white,
                                        ),
                                        child: AnimatedAlign(
                                          duration: const Duration(milliseconds: 300),
                                          alignment: globalRestaurantTimeStatus == "1" ? Alignment.centerRight : Alignment.centerLeft,
                                          curve: Curves.decelerate,
                                          child: Padding(
                                            padding: EdgeInsets.all(globalRestaurantTimeStatus == "1" ? 2.0 : 5.0),
                                            child: globalRestaurantTimeStatus == "1"
                                                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 25)
                                                : Icon(Icons.cancel, color: Theme.of(context).colorScheme.primary, size: 25),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(
                                          () {
                                            if (globalRestaurantTimeStatus == "0") {
                                              updateRestaurantStatus("1");
                                              globalRestaurantTimeStatus = "1";
                                            } else {
                                              updateRestaurantStatus("0");
                                              globalRestaurantTimeStatus = "0";
                                            }
                                          },
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            )),
                        firstHeader(),
                        const SizedBox(
                          height: 20,
                        ),
                        secondHeader(),
                        const SizedBox(
                          height: 020,
                        ),
                        thirdHeader(),
                        const SizedBox(
                          height: 20,
                        ),
                        fourthHeader(),
                        const SizedBox(
                          height: 20,
                        ),
                        getChart(),
                        catChart(),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              )
        : noInternet(context);
  }

//============================ Headers Implimentation ==========================

  firstHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        commanDesingButtons(
          1,
          0,
          "Order",
          getTranslated(context, "ORDER")!,
          totalorderCount,
        ),
        commanDesingButtons(
          1,
          1,
          "Products",
          getTranslated(context, "PRODUCT_LBL")!,
          totalproductCount,
        ),
      ],
    );
  }

  secondHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        commanDesingButtons(
          1,
          2,
          "tag_icon",
          getTranslated(context, "Tags")!,
          tagCount,
        ),
        commanDesingButtons(
          1,
          3,
          "Rating",
          getTranslated(context, "Rating")!,
          RATTING + r" / " + NO_OFF_RATTING,
        ),
      ],
    );
  }

  thirdHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        commanDesingButtons(
          1,
          4,
          "Sold_out_products",
          getTranslated(context, "Sold Out Products")!,
          totalsoldOutCount,
        ),
        commanDesingButtons(
          1,
          5,
          "Low_stock_products",
          getTranslated(context, "Low Stock Products")!,
          totallowStockCount,
        ),
      ],
    );
  }

  fourthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        commanDesingButtons(
          1,
          6,
          "Balance",
          getTranslated(context, "Earnings")!,
          "$CUR_CURRENCY $CUR_BALANCE",
        ),
        commanDesingButtons(
          1,
          7,
          "Transaction",
          getTranslated(context, "My Transactions")!,
          totalTransactionCount,
        ),
      ],
    );
  }

//============================ Desing Implimentation ===========================

  commanDesingButtons(
    int flex,
    int index,
    String svg,
    String title,
    String? data,
  ) {
    return Expanded(
      flex: flex,
      child: SizedBox(
        height: 130,
        child: InkWell(
          onTap: () {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderList(),
                ),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductList(
                    flag: '',
                  ),
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTags(),
                ),
              );
            } else if (index == 3) {
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductList(
                    flag: "sold",
                  ),
                ),
              );
            } else if (index == 5) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductList(
                    flag: "low",
                  ),
                ),
              );
            } else if (index == 6) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WalletHistory(),
                ),
              );
            } else if (index == 7) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistory(),
                ),
              );
            }
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: width * 0.5,
                height: 100,
                decoration: boxDecorationContainer(
                  offWhite,
                  15.0,
                ),
                padding: const EdgeInsets.only(
                  top: 40.0,
                ),
                margin: EdgeInsets.only(
                  top: 28,
                  right: width / 20.0,
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      data ?? "",
                      style: const TextStyle(
                        color: black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.only(right: width / 20.0),
                alignment: Alignment.topCenter,
                color: Colors.transparent,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      setSvgPath(svg),
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

//============================ Category Chart ==============================

  catChart() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: AspectRatio(
        aspectRatio: 1.23,
        child: Card(
          color: backgroun1,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, "CatWiseCount")!,
                  style: const TextStyle(color: primary),
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      height: 18,
                    ),
                    Expanded(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: .8,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(touchCallback: (fl, pieTouchResponse) {
                                  setState(
                                    () {
                                      final desiredTouch =
                                          pieTouchResponse!.touchedSection is! PointerExitEvent && pieTouchResponse.touchedSection is! PointerUpEvent;
                                      if (desiredTouch && pieTouchResponse.touchedSection != null) {
                                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      } else {
                                        touchedIndex = -1;
                                      }
                                    },
                                  );
                                }),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                startDegreeOffset: 180,
                                centerSpaceRadius: 40,
                                sections: showingSections(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        itemCount: colorList.length,
                        itemBuilder: (context, i) {
                          return Indicators(
                            color: colorList[i],
                            text: catList![i] + " " + catCountList![i],
                            textColor: touchedIndex == i ? Colors.black : Colors.grey,
                            isSquare: true,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      catCountList!.length,
      (i) {
        final isTouched = i == touchedIndex;

        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 60 : 50;

        return PieChartSectionData(
          color: colorList[i],
          value: double.parse(
            catCountList![i].toString(),
          ),
          title: "",
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            color: const Color(
              0xffffffff,
            ),
          ),
        );
      },
    );
  }

//============================ No Internet Widget ==============================

  noInternet(BuildContext context) {
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

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      getStatics();
                      getRestaurantDetail();
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

//============================ Refresh Implimentation ==========================

  Future<void> _refresh() async {
    Completer<void> completer = Completer<void>();
    await Future.delayed(
      const Duration(seconds: 3),
    ).then(
      (onvalue) {
        completer.complete();
        offset = 0;
        total = 0;
        orderList.clear();
        orderList.clear();
        getStatics();
        getRestaurantDetail();
        setState(
          () {
            _isLoading = true;
          },
        );
      },
    );
    return completer.future;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
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
  }
}
