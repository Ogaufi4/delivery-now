import 'dart:async';

import 'package:project/CashCollection.dart';
import 'package:project/Helper/Session.dart';
import 'package:project/Localization/language_constant.dart';
import 'package:project/MaintainanceScreen.dart';
import 'package:project/OrderDetail.dart';
import 'package:project/PendingOrdList.dart';
import 'package:project/WalletHistsory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Helper/ApiBaseHelper.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/String.dart';
import 'Login.dart';
import 'Model/Order_Model.dart';

import 'Privacy_Policy.dart';
import 'Profile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

ApiBaseHelper apiBaseHelper = ApiBaseHelper();

class StateHome extends State<Home> with TickerProviderStateMixin {
  int curDrwSel = 0;

  bool _isNetworkAvail = true;
  List<Order_Model> tempList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? profile;
  String? drawerProfileImageUrl;
  ScrollController controller = ScrollController();
  List<String> statusList = [
    ALL,
    CONFIRMED,
    PREPARING,
    OUT_FOR_DELIVERY,
    DELIVERED,
    CANCLED,
  ];
  String? activeStatus = '';
  int? total, offset;
  int? totalP;
  List<Order_Model> orderList = [];
  int? selectLan;
  bool _isLoading = true;
  bool isLoadingmore = true;
  String? bottomSheetItemindex = "1";
  List<String?> languageList = [];
  List<String> langCode = [ENGLISH, HINDI, URDU];

  @override
  void initState() {
    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();
    offset = 0;
    total = 0;
    totalP = 0;
    orderList.clear();
    getSetting();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    Future.delayed(
      Duration.zero,
      () {
        languageList = [
          English,
          Hindi,
          Urdu,
        ];
      },
    );
    getSaveDetail();
    controller.addListener(_scrollListener);
    loadDrawerProfileImage();

    super.initState();
  }

  getSaveDetail() async {
    String getlng = await getPrefrence(LAGUAGE_CODE) ?? '';

    selectLan = langCode.indexOf(getlng == '' ? "en" : getlng);
  }

  void loadDrawerProfileImage() async {
    drawerProfileImageUrl = await getPrefrence('profile_image');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          appName,
          style: TextStyle(
              color: darkFontColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.sort, color: darkFontColor),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        iconTheme: const IconThemeData(color: primary),
        backgroundColor: white,
        actions: [
          InkWell(
              onTap: openFilterBottomSheet,
              child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: darkFontColor,
                  )))
        ],
      ),
      backgroundColor: white,
      drawer: _getDrawer(),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Stack(
                        children: [
                          Container(
                              margin: EdgeInsets.only(top: deviceHeight / 12),
                              padding:
                                  EdgeInsets.only(top: deviceHeight / 80.0),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40.0),
                                      topRight: Radius.circular(40.0)),
                                  color: white,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, -9),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      color: shadowColor,
                                    )
                                  ]),
                              child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    start: deviceWidth! / 25.0,
                                    end: deviceWidth! / 25.0,
                                    top: deviceHeight / 13.0,
                                  ),
                                  child: Column(children: [
                                    Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 9.0, end: 9.0),
                                        child: Divider(
                                          color: lightFontColor.withValues(
                                              alpha: 0.2),
                                          thickness: 1.5,
                                        )),
                                    orderList.isEmpty
                                        ? Center(
                                            child: Text(getTranslated(
                                                context, 'noItem')!))
                                        : ListView.builder(
                                            padding: const EdgeInsetsDirectional
                                                .only(bottom: 10),
                                            shrinkWrap: true,
                                            itemCount: (offset! < total!)
                                                ? orderList.length + 1
                                                : orderList.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return (index ==
                                                          orderList.length &&
                                                      isLoadingmore)
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : orderItem(index);
                                            },
                                          ),
                                  ]))),
                          Positioned.directional(
                              textDirection: Directionality.of(context),
                              top: deviceHeight / 35.0,
                              start: deviceWidth! / 10.0,
                              end: deviceWidth! / 10.0,
                              height: deviceHeight * 0.13,
                              child: _detailHeader()),
                        ],
                      )))
          : noInternet(context),
    );
  }

  void openFilterBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsetsDirectional.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          bottomsheetLabel(
                              getTranslated(context, 'FILTER_BY')!, context),
                          Flexible(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsetsDirectional.only(top: 10.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: getStatusList()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 20.0, end: 20.0, bottom: 15.0),
                  child: Container(
                    width: deviceWidth! - 40,
                    decoration: bottomSheetItemindex == index.toString()
                        ? boxDecorationContainer(10.0, black, black)
                        : boxDecorationContainerBoarder(10, white, black),
                    child: TextButton(
                        child: Text(
                            statusList[index] == OUT_FOR_DELIVERY
                                ? OUT_FOR_DELIVERY_LBL
                                : statusList[index] == CONFIRMED
                                    ? ORDER_RECEIVED
                                    : capitalize(statusList[index]),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color:
                                        bottomSheetItemindex == index.toString()
                                            ? white
                                            : black)),
                        onPressed: () {
                          setState(() {
                            activeStatus = index == 0 ? "" : statusList[index];
                            isLoadingmore = true;
                            _isLoading = true;
                            offset = 0;
                            total = 0;
                            orderList.clear();
                            bottomSheetItemindex = index.toString();
                          });

                          getOrder();

                          Navigator.pop(context, 'option $index');
                        }),
                  ),
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder();
        });
      }
    }
  }

  _getDrawer() {
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
              _getDrawerItem(
                  0, getTranslated(context, 'HOME_LBL')!, Icons.home_outlined),
              _getDrawerItem(1, getTranslated(context, 'PROFILE_LBL')!,
                  Icons.account_circle_outlined),
              _getDrawerItem(2, getTranslated(context, 'WALLET')!,
                  Icons.account_balance_wallet_outlined),
              _getDrawerItem(3, getTranslated(context, 'CASH_COLL')!,
                  Icons.money_outlined),
              _getDivider(),
              _getDrawerItem(8, getTranslated(context, "deleteAccount")!,
                  Icons.delete_outline),
              _getDrawerItem(4, getTranslated(context, 'CHANGE_LANGUAGE')!,
                  Icons.translate),
              _getDrawerItem(
                  5, getTranslated(context, 'PRIVACY')!, Icons.lock_outline),
              _getDrawerItem(6, getTranslated(context, 'TERM')!,
                  Icons.speaker_notes_outlined),
              CUR_USERID == "" || CUR_USERID == ""
                  ? Container()
                  : _getDivider(),
              CUR_USERID == "" || CUR_USERID == ""
                  ? Container()
                  : _getDrawerItem(
                      7, getTranslated(context, 'LOGOUT')!, Icons.input),
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
        padding: const EdgeInsetsDirectional.only(start: 10.0, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 8, start: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        CUR_USERNAME!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: white, fontWeight: FontWeight.bold),
                      ),
                      if (CUR_BALANCE != '')
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            "${getTranslated(context, 'WALLET_BAL')}: ${CUR_CURRENCY!}${double.parse(CUR_BALANCE).toStringAsFixed(2)}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: white, fontWeight: FontWeight.bold),
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  )),
            ),
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  right: 20,
                ),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.0, color: white)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: (drawerProfileImageUrl != null &&
                          drawerProfileImageUrl!.isNotEmpty)
                      ? Image.network(drawerProfileImageUrl!,
                          width: 62, height: 62, fit: BoxFit.cover)
                      : imagePlaceHolder(62),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        final result = await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Profile(),
            ));
        if (result == true) {
          loadDrawerProfileImage();
        } else {
          // Always reload to be safe
          loadDrawerProfileImage();
        }
        setState(() {});
      },
    );
  }

  _getDivider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        height: 1,
      ),
    );
  }

  _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
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
          style: TextStyle(
              color: curDrwSel == index ? white : black,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (title == getTranslated(context, 'HOME_LBL')) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
          } else if (title == getTranslated(context, 'PROFILE_LBL')) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Profile(),
                ));
          } else if (title == getTranslated(context, 'LOGOUT')) {
            logOutDailog();
          } else if (title == getTranslated(context, 'PRIVACY')) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: getTranslated(context, 'PRIVACY'),
                  ),
                ));
          } else if (title == getTranslated(context, 'TERM')) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: getTranslated(context, 'TERM'),
                  ),
                ));
          } else if (title == getTranslated(context, 'WALLET')!) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const WalletHistory(),
                ));
          } else if (title == getTranslated(context, 'CASH_COLL')) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const CashCollection(),
                ));
          } else if (title == getTranslated(context, 'CHANGE_LANGUAGE')) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            languageDialog();
          } else if (title == getTranslated(context, "deleteAccount")) {
            setState(
              () {
                curDrwSel = index;
              },
            );
            deleteAccountDialog();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    offset = 0;
    total = 0;
    totalP = 0;
    orderList.clear();

    setState(() {
      _isLoading = true;
    });
    getPendingOrder();
    return getOrder();
  }

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                getTranslated(context, 'LOGOUTTXT')!,
                style: Theme.of(this.context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: darkFontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, 'LOGOUTNO')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: lightFontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: Text(
                      getTranslated(context, 'LOGOUTYES')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: darkFontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      clearUserSession();

                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (context) => const Login()),
                          (Route<dynamic> route) => false);
                    })
              ],
            );
          });
        });
  }

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
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.13,
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                  child: Text(
                    getTranslated(context, 'CHOOSE_LANGUAGE_LBL')!,
                    style:
                        Theme.of(this.context).textTheme.titleMedium!.copyWith(
                              color: white,
                            ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: getLngList(context)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

                      print(
                          "selectLan--$selectLan--index--$index--langCode--${langCode[index]}");
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  getOrder();
                  getPendingOrder();
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);
        CUR_USERNAME = await getPrefrence(USERNAME);

        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };
        if (activeStatus != "") {
          parameter[ACTIVE_STATUS] = activeStatus;
        }
        apiBaseHelper.postAPICall(getOrdersApi, parameter, context).then(
            (getdata) {
          bool error = getdata["error"];

          total = int.parse(getdata["total"]);

          if (!error) {
            if (offset! < total!) {
              tempList.clear();
              var data = getdata["data"];

              tempList = (data as List)
                  .map((data) => Order_Model.fromJson(data))
                  .toList();

              orderList.addAll(tempList);

              CUR_BALANCE = orderList[0].balance!;

              offset = offset! + perPage;
              setState(() {});
            } else {
              setState(() {
                isLoadingmore = false;
              });
            }
          } else {
            setState(() {
              isLoadingmore = false;
            });
          }

          setState(() {
            _isLoading = false;
          });
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  orderItem(int index) {
    Order_Model model = orderList[index];
    Color back;

    if ((model.activeStatus) == DELIVERED) {
      back = Colors.green;
    } else if ((model.activeStatus) == OUT_FOR_DELIVERY) {
      back = Colors.orange;
    } else if ((model.activeStatus) == CANCLED) {
      back = Colors.red;
    } else if ((model.activeStatus) == PREPARING) {
      back = Colors.indigo;
    } else if (model.activeStatus == PENDING) {
      back = Colors.black;
    } else {
      back = Colors.cyan;
    }

    return Card(
      elevation: 0,
      margin:
          const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 7.0, right: 7.0),
      child: Container(
        decoration: BoxDecoration(
            color: cardBgColor, borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Order No.${model.id!}"),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: back,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0))),
                            child: Text(
                              capitalize(model.activeStatus == OUT_FOR_DELIVERY
                                  ? OUT_FOR_DELIVERY_LBL
                                  : model.activeStatus == CONFIRMED
                                      ? ORDER_RECEIVED
                                      : model.activeStatus!),
                              style: const TextStyle(color: white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(Icons.person, size: 14),
                                Expanded(
                                  child: Text(
                                    model.name != "" && model.name!.isNotEmpty
                                        ? " ${capitalize(model.name!)}"
                                        : " ",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.call,
                                  size: 14,
                                  color: darkFontColor,
                                ),
                                Text(
                                  " ${model.mobile!}",
                                  style: const TextStyle(
                                      color: darkFontColor,
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                            onTap: () {
                              _launchCaller(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.money, size: 14),
                              Text(
                                  " Payable: ${CUR_CURRENCY!} ${double.parse(model.payable!).toStringAsFixed(2)}"),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.payment, size: 14),
                              Text(" ${model.payMethod!}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, size: 14),
                          Text(" Order on: ${model.orderDate!}"),
                        ],
                      ),
                    )
                  ])),
          onTap: () async {
            await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      OrderDetail(model: orderList[index], isPendOrd: false)),
            );
          },
        ),
      ),
    );
  }

  _launchCaller(index) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: orderList[index].mobile,
    );
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> getPendingOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getPendingOrdersApi, parameter, context).then(
            (getdata) {
          print("getdata*******$getdata");
          bool error = getdata["error"];

          if (!error) {
            totalP = int.parse(getdata["total"]);
            setState(() {});
          } else {
            totalP = 0;
          }
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  _detailHeader() {
    return Container(
        padding: const EdgeInsetsDirectional.only(start: 3.0, end: 3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: primary,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: white,
                  ),
                  Text(
                    getTranslated(context, 'TOTAL_ORDER_LBL')!,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: white),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    total.toString(),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const WalletHistory(),
                      ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: white,
                    ),
                    Text(
                      getTranslated(context, 'BAL_LBL')!,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: white),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    if (CUR_BALANCE != '')
                      Text(
                        "${CUR_CURRENCY!} ${double.parse(CUR_BALANCE).toStringAsFixed(2)}",
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const PendingOrdList(),
                      ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pending_actions,
                      color: white,
                    ),
                    Text(
                      getTranslated(context, 'PENDING_ORDER_LBL')!,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: white),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      totalP.toString(),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: white, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Future<void> deleteAccountApi() async {
    CUR_USERID = await getPrefrence(ID);
    Map parameter = {RIDER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(deleteRiderApi, parameter, context).then(
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
          setSnackbar(msg!);
        }
      },
      onError: (error) {
        setSnackbar(error.toString());
      },
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
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.13,
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
                  child: Text(
                    getTranslated(context, 'deleteAccount')!,
                    style:
                        Theme.of(this.context).textTheme.titleMedium!.copyWith(
                              color: white,
                            ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 20.0, end: 20.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, 'deleteYourAccount')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: black,
                                  ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              getTranslated(
                                  context, 'deleteYourAccountSubTitle')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
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
                    color: red,
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

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter = {TYPE: SYSTEM_SETTINGS};
      apiBaseHelper.postAPICall(getSettingApi, parameter, context).then(
          (getdata) {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          Is_APP_IN_MAINTANCE = data[MAINTAINANCE_MODE];
          Is_RIDER_OTP_SETTING_ON = data[IsRIDER_OTP_SETTING_ON];
          AUTHENTICATION_METHOD =
              (getdata['authentication_mode'] ?? 0).toString();
          if (Is_APP_IN_MAINTANCE != "1") {
            getOrder();
            getPendingOrder();
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => MaintainanceScreen(),
                ));
          }

          CUR_CURRENCY = getdata["currency"] ?? "";
        } else {
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setSnackbar(error.toString());
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    } on FormatException catch (e) {
      setSnackbar(e.message);
    }
  }
}
