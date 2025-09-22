import 'dart:async';

import 'package:project/Model/Transaction_Model.dart';
import 'package:flutter/material.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Home.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateWallet();
  }
}

class StateWallet extends State<WalletHistory> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  ScrollController controller = ScrollController();
  List<TransactionModel> tempList = [];
  TextEditingController? amtC, bankDetailC;
  String? bottomSheetItemindex = "1";

  List<TransactionModel> tranList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getRiderWalletTransaction();
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
        appBar: getAppBar(getTranslated(context, 'WALLET')!, context),
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
                        child: RefreshIndicator(
                            key: _refreshIndicatorKey,
                            onRefresh: _refresh,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
                              controller: controller,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
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
                                              " ${getTranslated(context, 'CURBAL_LBL')}",
                                              style:
                                                  Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text("${CUR_CURRENCY!} ${double.parse(CUR_BALANCE).toStringAsFixed(2)}",
                                            style:
                                                Theme.of(context).textTheme.titleLarge!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                                        SimBtn(
                                          size: 0.8,
                                          title: getTranslated(context, 'WITHDRAW_MONEY'),
                                          onBtnSelected: () {
                                            _showDialog();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                tranList.isEmpty
                                    ? Center(child: Text(getTranslated(context, 'noItem')!))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: (offset < total) ? tranList.length + 1 : tranList.length,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return (index == tranList.length && isLoadingmore)
                                              ? const Center(child: CircularProgressIndicator())
                                              : listItem(index);
                                        },
                                      ),
                              ]),
                            ))))
            : noInternet(context));
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

  Future<void> getUserDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID};

        apiBaseHelper.postAPICall(getBoyDetailApi, parameter, context).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
            String tempCom = data[COM_METHOD];
            saveUserDetail(
              data[ID],
              data[USERNAME],
              data[EMAIL],
              data[MOBILE],
              data[ADDRESS],
              tempCom.replaceAll("_", " "),
              data[COMMISSION],
              data[ACTIVE],
              double.parse(data[BALANCE]).toStringAsFixed(2),
              data[TOKEN],
            );
          } else {
            setSnackbar(msg!);
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
      actions: [
        Container(
            width: 33.0,
            margin: const EdgeInsets.all(12),
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
                                        decoration: bottomSheetItemindex == "1"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'SHOW_TRANS')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemindex == "1" ? white : black)),
                                            onPressed: () {
                                              tranList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                bottomSheetItemindex = "1";
                                              });
                                              getRiderWalletTransaction();
                                              Navigator.pop(context, 'option 1');
                                            }))),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                        width: deviceWidth! - 40,
                                        decoration: bottomSheetItemindex == "2"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'SHOW_FUND_TRANSFERS')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemindex == "2" ? white : black)),
                                            onPressed: () {
                                              tranList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                bottomSheetItemindex = "2";
                                              });
                                              getTransaction();
                                              Navigator.pop(context, 'option 1');
                                            }))),
                                Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, bottom: 15.0),
                                    child: Container(
                                        width: deviceWidth! - 40,
                                        decoration: bottomSheetItemindex == "3"
                                            ? boxDecorationContainer(10.0, black, black)
                                            : boxDecorationContainerBoarder(10, white, black),
                                        child: TextButton(
                                            child: Text(getTranslated(context, 'SHOW_REQ')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(color: bottomSheetItemindex == "3" ? white : black)),
                                            onPressed: () {
                                              tranList.clear();
                                              offset = 0;
                                              total = 0;
                                              setState(() {
                                                _isLoading = true;
                                                bottomSheetItemindex = "3";
                                              });
                                              getRequest();
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

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                        child: Text(
                          getTranslated(context, 'SEND_REQUEST')!,
                          style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: darkFontColor),
                        )),
                    const Divider(color: lightFontColor),
                    Form(
                        key: _formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) => validateField(value, context),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: getTranslated(context, 'WITHDRWAL_AMT'),
                                    hintStyle:
                                        Theme.of(this.context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
                                  ),
                                  controller: amtC,
                                )),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                child: TextFormField(
                                  validator: (value) => validateField(value, context),
                                  keyboardType: TextInputType.multiline,
                                  //maxLines: null,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: BANK_DETAIL,
                                    hintStyle:
                                        Theme.of(this.context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
                                  ),
                                  controller: bankDetailC,
                                )),
                          ],
                        ))
                  ])),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, 'CANCEL')!,
                      style: Theme.of(this.context).textTheme.titleSmall!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                    child: Text(
                      getTranslated(context, 'SEND_LBL')!,
                      style: Theme.of(this.context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formkey.currentState!;
                      if (form.validate()) {
                        form.save();
                        setState(() {
                          Navigator.pop(context);
                        });
                        sendRequest();
                      }
                    })
              ],
            );
          });
        });
  }

  listItem(int index) {
    Color back;
    if (tranList[index].status!.toLowerCase() == "success".toLowerCase() || tranList[index].status!.toLowerCase() == ACCEPTED.toLowerCase()) {
      back = Colors.green;
    } else if (tranList[index].status!.toLowerCase() == PENDING.toLowerCase()) {
      back = Colors.orange;
    } else {
      back = Colors.red;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(8)),
        child: InkWell(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "${getTranslated(context, 'AMT_LBL')} : ${CUR_CURRENCY!} ${double.parse(tranList[index].amt!).toStringAsFixed(2)}",
                        style: const TextStyle(color: darkFontColor, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(tranList[index].date!),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("${getTranslated(context, 'ID_LBL')} : ${tranList[index].id!}"),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(color: back, borderRadius: const BorderRadius.all(Radius.circular(4.0))),
                        child: Text(
                          capitalize(tranList[index].status!),
                          style: const TextStyle(color: white),
                        ),
                      )
                    ],
                  ),
                  tranList[index].type != "" && tranList[index].type != null && tranList[index].type!.isNotEmpty
                      ? Text("${getTranslated(context, 'TYPE')} : ${tranList[index].type!}")
                      : Container(),
                  tranList[index].opnBal != "" && tranList[index].opnBal != null && tranList[index].opnBal!.isNotEmpty
                      ? Text("${getTranslated(context, 'OPNBL_LBL')} : ${double.parse(tranList[index].opnBal!).toStringAsFixed(2)}")
                      : Container(),
                  tranList[index].clsBal != "" && tranList[index].clsBal != null && tranList[index].clsBal!.isNotEmpty
                      ? Text("${getTranslated(context, 'CLBL_LBL')} : ${double.parse(tranList[index].clsBal!).toStringAsFixed(2)}")
                      : Container(),
                  tranList[index].msg != "" && tranList[index].msg!.isNotEmpty
                      ? Text("${getTranslated(context, 'MSG_LBL')} : ${tranList[index].msg!}")
                      : Container(),
                ]))),
      ),
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
                  getTransaction();
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

  Future<void> getRiderWalletTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          RIDER_ID: CUR_USERID,
        };

        apiBaseHelper.postAPICall(getRiderWalletTransactionsApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List).map((data) => TransactionModel.fromJson(data)).toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          print("_message$error");
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }

    return;
  }

  Future<void> getTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID,
        };

        apiBaseHelper.postAPICall(getFundTransferApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List).map((data) => TransactionModel.fromJson(data)).toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          print("_message$error");
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }

    return;
  }

  Future<void> getRequest() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID,
        };

        apiBaseHelper.postAPICall(getWithReqApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List).map((data) => TransactionModel.fromReqJson(data)).toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
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

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    setState(() {
      _isLoading = true;
      bottomSheetItemindex == "1";
    });
    offset = 0;
    total = 0;
    tranList.clear();
    getUserDetail();
    return getRiderWalletTransaction();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      if (mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total)
            bottomSheetItemindex == "1"
                ? getRiderWalletTransaction()
                : bottomSheetItemindex == "2"
                    ? getTransaction()
                    : getRequest();
        });
      }
    }
  }
}
