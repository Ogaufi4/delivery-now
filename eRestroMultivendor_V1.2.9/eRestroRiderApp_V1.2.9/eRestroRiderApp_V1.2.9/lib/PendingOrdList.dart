import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'Model/Order_Model.dart';
import 'OrderDetail.dart';

class PendingOrdList extends StatefulWidget {
  const PendingOrdList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePendingOrdList();
  }
}

List<Order_Model> penOrderList = [];
int offset = 0;
int total = 0;
bool isLoadingmore = true;
bool _isLoading = true;

class StatePendingOrdList extends State<PendingOrdList> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();
  List<Order_Model> tempList = [];
  TextEditingController? amtC, bankDetailC;

  @override
  void initState() {
    super.initState();
    getPendingOrder();
    controller.addListener(_scrollListener);
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

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
    amtC = TextEditingController();
    bankDetailC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        key: _scaffoldKey,
        appBar: getAppBar(PENDING_ORDER_LBL, context),
        body: _isNetworkAvail
            ? _isLoading
                ? shimmer()
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20.0, right: 10.0, left: 10.0),
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10.0),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
                            color: white,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, -9),
                                blurRadius: 10,
                                spreadRadius: 0,
                                color: shadowColor,
                              )
                            ]),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 9.0, right: 9.0, top: 10.0),
                              child: InkWell(
                                child: Text(
                                  "* Please do refresh before accepting order",
                                  style:
                                      Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                onTap: () {
                                  offset = 0;
                                  total = 0;
                                  penOrderList.clear();

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  getPendingOrder();
                                  setState(() {});
                                },
                              ),
                            ),
                            penOrderList.isEmpty
                                ? Center(child: Text(getTranslated(context, 'noItem')!))
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: (offset < total) ? penOrderList.length + 1 : penOrderList.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return (index == penOrderList.length && isLoadingmore)
                                          ? const Center(child: CircularProgressIndicator())
                                          : orderItem(index);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  )
            : noInternet(context));
  }

  orderItem(int index) {
    Order_Model model = penOrderList[index];
    Color back;

    if ((model.activeStatus) == DELIVERED) {
      back = Colors.green;
    } else if ((model.activeStatus) == OUT_FOR_DELIVERY) {
      back = Colors.orange;
    } else if ((model.activeStatus) == CANCLED || model.activeStatus == RETURNED) {
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
      margin: const EdgeInsets.only(bottom: 10.0, top: 13.0, left: 7.0, right: 7.0),
      child: Container(
        decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Order No.${model.id!}"),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: back, borderRadius: const BorderRadius.all(Radius.circular(4.0))),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 14),
                            Expanded(
                              child: Text(
                                model.name != "" && model.name!.isNotEmpty ? " ${capitalize(model.name!)}" : " ",
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
                              style: const TextStyle(color: darkFontColor, decoration: TextDecoration.underline),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.money, size: 14),
                          Text(" Payable: ${CUR_CURRENCY!} ${model.payable!}"),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, size: 14),
                      Text(" Order on: ${model.orderDate!}"),
                    ],
                  ),
                )
              ])),
          onTap: () async {
            print(penOrderList[index].total);
            await Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => OrderDetail(model: penOrderList[index], isPendOrd: true)),
            );
          },
        ),
      ),
    );
  }

  _launchCaller(index) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: penOrderList[index].mobile,
    );
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> sendRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, AMOUNT: amtC!.text.toString(), PAYMENT_ADD: bankDetailC!.text.toString()};

        apiBaseHelper.postAPICall(sendWithReqApi, parameter, context).then((getdata) {
          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            CUR_BALANCE = double.parse(getdata["data"]).toStringAsFixed(2);
          }
          if (mounted) setState(() {});
          setSnackbar(msg);
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
      }
    }

    return;
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
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(color: darkFontColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: white,
    );
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

  Future<void> getPendingOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };
        apiBaseHelper.postAPICall(getPendingOrdersApi, parameter, context).then((getdata) {
          bool error = getdata["error"];
          total = int.parse(getdata["total"]);

          if (!error) {
            if (offset < total) {
              tempList.clear();
              var data = getdata["data"];

              tempList = (data as List).map((data) => Order_Model.fromJson(data)).toList();

              penOrderList.addAll(tempList);

              offset = offset + perPage;
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

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    setState(() {
      _isLoading = true;
    });
    offset = 0;
    total = 0;
    penOrderList.clear();
    return getPendingOrder();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) getPendingOrder();
        });
      }
    }
  }
}
