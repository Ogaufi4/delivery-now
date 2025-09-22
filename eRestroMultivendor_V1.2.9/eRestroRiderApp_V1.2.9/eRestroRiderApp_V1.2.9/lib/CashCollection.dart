import 'dart:async';

import 'package:project/Model/CashCollection_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'OrderDetail.dart';

class CashCollection extends StatefulWidget {
  const CashCollection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateCash();
  }
}

int? total, offset;
List<CashColl_Model> cashList = [];
bool _isLoading = true;
bool isLoadingmore = true;

class StateCash extends State<CashCollection> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  List<CashColl_Model> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ScrollController controller = ScrollController();
  String? searchText;
  final TextEditingController _controller = TextEditingController();
  String _searchText = "", _lastsearch = "", currentCashCollectionBy = "";
  bool isLoadingmore = true, isGettingdata = false, isNodata = false;
  String? bottomSheetItemFilterByIndex = "1", bottomSheetItemOrderByIndex = "1";

  @override
  void initState() {
    offset = 0;
    total = 0;
    cashList.clear();
    getOrder(
      (bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin",
      "DESC",
    );
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
    controller.addListener(_scrollListener);
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = "";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchText = _controller.text;
          });
        }
      }

      if (_lastsearch != _searchText && ((_searchText.length > 1) || (_searchText == ""))) {
        _lastsearch = _searchText;
        isLoadingmore = true;
        offset = 0;
        getOrder((bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin", "DESC");
      }
    });
    super.initState();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder((bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin", "DESC");
        });
      }
    }
  }

  Future<void> getOrder(String from, String order) async {
    if (CUR_USERID != null) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          if (isLoadingmore) {
            if (mounted) {
              setState(() {
                isLoadingmore = false;
                isGettingdata = true;
                if (offset == 0) {
                  cashList = [];
                }
              });
            }

            var parameter = {
              RIDER_ID: CUR_USERID,
              STATUS: from == "delivery" ? RIDER_CASH : RIDER_CASH_COLL,
              LIMIT: perPage.toString(),
              OFFSET: offset.toString(),
              ORDER_BY: order,
              SEARCH: _searchText.trim(),
            };

            apiBaseHelper.postAPICall(getCashCollection, parameter, context).then((getdata) {
              bool error = getdata["error"];

              isGettingdata = false;
              if (offset == 0) isNodata = error;

              if (!error) {
                var data = getdata["data"];

                if (data.length != 0) {
                  List<CashColl_Model> items = [];
                  List<CashColl_Model> allitems = [];

                  items.addAll((data as List).map((data) => CashColl_Model.fromJson(data)).toList());

                  allitems.addAll(items);

                  for (CashColl_Model item in items) {
                    cashList.where((i) => i.id == item.id).map((obj) {
                      allitems.remove(item);
                      return obj;
                    }).toList();
                  }
                  cashList.addAll(allitems);

                  isLoadingmore = true;
                  offset = offset! + perPage;
                } else {
                  isLoadingmore = false;
                }
              } else {
                isLoadingmore = false;
              }

              if (mounted) {
                setState(() {
                  _isLoading = false;
                  currentCashCollectionBy = from;
                });
              }
            }, onError: (error) {
              setSnackbar(error.toString());
            });
          }
        } on TimeoutException catch (_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              isLoadingmore = false;
            });
          }
          setSnackbar(getTranslated(context, 'somethingMSg')!);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) if (mounted) {
        setState(() {
          isLoadingmore = false;
        });
      }
    }

    return;
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

  getAppBar(String title, BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: white,
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
      actions: [
        Container(
            width: 31.0,
            margin: const EdgeInsetsDirectional.only(start: 13.0, top: 13.0, bottom: 13.0, end: 0.0),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(11.0), color: darkFontColor),
                child: const Center(
                  child: Icon(
                    Icons.swap_vert,
                    color: white,
                    size: 22,
                  ),
                ),
              ),
              onTap: () {
                return openSortBottomSheet();
              },
            )),
        Container(
            width: 31.0,
            margin: const EdgeInsets.all(13),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(11.0), color: darkFontColor),
                child: const Center(
                  child: Icon(
                    Icons.tune,
                    color: white,
                    size: 22,
                  ),
                ),
              ),
              onTap: () {
                openFilterBottomSheet();
              },
            ))
      ],
    );
  }

  void openSortBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
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
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          bottomsheetLabel(getTranslated(context, 'ORDER_BY_TXT')!, context),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                      width: deviceWidth! - 40,
                                      decoration: bottomSheetItemOrderByIndex == "1"
                                          ? boxDecorationContainer(10.0, black, black)
                                          : boxDecorationContainerBoarder(10, white, black),
                                      child: TextButton(
                                          child: Text(getTranslated(context, 'ASC_TXT')!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(color: bottomSheetItemOrderByIndex == "1" ? white : black)),
                                          onPressed: () {
                                            cashList.clear();
                                            offset = 0;
                                            total = 0;
                                            setState(() {
                                              _isLoading = true;
                                              isLoadingmore = true;
                                            });

                                            getOrder(currentCashCollectionBy == "admin" ? "admin" : "delivery", "ASC");
                                            Navigator.pop(context, 'option 1');
                                          }),
                                    )),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                        width: deviceWidth! - 40,
                                        decoration: bottomSheetItemOrderByIndex == "2"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'DESC_TXT')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemOrderByIndex == "2" ? white : black)),
                                            onPressed: () {
                                              cashList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                isLoadingmore = true;
                                              });
                                              getOrder(currentCashCollectionBy == "admin" ? "admin" : "delivery", "DESC");
                                              Navigator.pop(context, 'option 1');
                                            }))),
                              ]),
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

  void openFilterBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
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
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          bottomsheetLabel(getTranslated(context, 'FILTER_BY')!, context),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                        width: deviceWidth! - 40,
                                        decoration: bottomSheetItemFilterByIndex == "1"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'RIDER_CASH_TXT')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemFilterByIndex == "1" ? white : black)),
                                            onPressed: () {
                                              cashList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                isLoadingmore = true;
                                                bottomSheetItemFilterByIndex = "1";
                                              });

                                              getOrder((bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin", "DESC");

                                              Navigator.pop(context, 'option 1');
                                            }))),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                        width: deviceWidth! - 40,
                                        decoration: bottomSheetItemFilterByIndex == "2"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'RIDER_CASH_COLL_TXT')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemFilterByIndex == "2" ? white : black)),
                                            onPressed: () {
                                              cashList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                isLoadingmore = true;
                                                bottomSheetItemFilterByIndex = "2";
                                              });
                                              getOrder((bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin", "DESC");
                                              Navigator.pop(context, 'option 2');
                                            }))),
                              ]),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      appBar: getAppBar(getTranslated(context, 'CASH_COLL')!, context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : Padding(
                  padding: const EdgeInsets.only(top: 15.0),
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
                      child: SingleChildScrollView(
                          controller: controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Card(
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.account_balance_wallet,
                                                color: darkFontColor,
                                              ),
                                              Text(
                                                " ${getTranslated(context, 'TOTAL_AMT')}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          cashList.isNotEmpty
                                              ? Text("${CUR_CURRENCY!} ${double.parse(cashList[0].cashReceived!).toStringAsFixed(2)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .copyWith(color: darkFontColor, fontWeight: FontWeight.bold))
                                              : Text("${CUR_CURRENCY!} 0",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                                Container(
                                    padding: const EdgeInsetsDirectional.only(start: 5.0, end: 5.0, top: 10.0),
                                    child: TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        filled: true,
                                        isDense: true,
                                        fillColor: textFieldBackground,
                                        prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        prefixIcon: const Icon(Icons.search),
                                        hintText: FIND_ORDERS,
                                        hintStyle: TextStyle(color: black.withValues(alpha: 0.3), fontWeight: FontWeight.normal),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(width: 0, style: BorderStyle.none, color: darkFontColor.withValues(alpha: 0.6)),
                                            borderRadius: BorderRadius.circular(10.0)),
                                      ),
                                    )),
                                cashList.isEmpty
                                    ? isGettingdata
                                        ? Container()
                                        : Container(
                                            padding: EdgeInsets.only(top: deviceHeight / 4),
                                            alignment: Alignment.center,
                                            child: Text(getTranslated(context, 'noItem')!))
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 13.0),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: (offset! < total!) ? cashList.length + 1 : cashList.length,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return (index == cashList.length && isLoadingmore)
                                                ? const Center(child: CircularProgressIndicator())
                                                : orderItem(index);
                                          },
                                        ),
                                      ),
                                isGettingdata ? const Center(child: CircularProgressIndicator()) : Container(),
                              ])))))
          : noInternet(context),
    );
  }

  orderItem(int index) {
    CashColl_Model model = cashList[index];
    Color back;
    if (model.type == "Collected") {
      back = Colors.green;
    } else {
      back = pink;
    }

    return Column(children: [
      InkWell(
        child: Card(
          elevation: 0,
          color: cardBgColor,
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "${getTranslated(context, 'AMT_LBL')} : ${CUR_CURRENCY!} ${double.parse(model.amount!).toStringAsFixed(2)}",
                          style: const TextStyle(color: darkFontColor, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(model.date!),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (model.orderId! != "" && model.orderId! != "")
                          Text("${getTranslated(context, 'ORDER_ID_LBL')} : ${model.orderId!}")
                        else
                          Text("${getTranslated(context, 'ID_LBL')} : ${model.id!}"),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(color: back, borderRadius: const BorderRadius.all(Radius.circular(4.0))),
                          child: Text(
                            capitalize(model.type!),
                            style: const TextStyle(color: white),
                          ),
                        )
                      ],
                    ),
                    Text("${getTranslated(context, 'MSG_LBL')} : ${model.message!}"),
                  ]))),
        ),
        onTap: () async {
          if (cashList[index].orderId != "" && cashList[index].orderId != "") {
            await Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => OrderDetail(model: cashList[index].orderDetails![0])),
            );
          }
        },
      ),
    ]);
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
                  getOrder((bottomSheetItemFilterByIndex == "1") ? "delivery" : "admin", "DESC");
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
}
