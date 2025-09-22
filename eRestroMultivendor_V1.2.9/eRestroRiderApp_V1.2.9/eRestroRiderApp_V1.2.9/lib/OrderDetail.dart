import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/Map.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Home.dart';
import 'Model/Order_Model.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model? model;
  final Function? updateHome;
  final bool? isPendOrd;

  const OrderDetail({Key? key, this.model, this.updateHome, this.isPendOrd}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<String> statusList = [];
  bool _isProgress = false;
  String? curStatus, otp;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;

  bool isScroll = true;

  @override
  void initState() {
    super.initState();

    otpC = TextEditingController();

    statusList = [
      OUT_FOR_DELIVERY,
      DELIVERED,
      CANCLED,
    ];

    curStatus = widget.model!.activeStatus;
    for (int i = 0; i < widget.model!.itemList!.length; i++) {
      widget.model!.itemList![i].curSelected = widget.model!.itemList![i].status;
    }

    if (widget.model!.payMethod == "Bank Transfer") {
      statusList.removeWhere((element) => element == CONFIRMED);
    }

    print("activeStatus:${widget.model!.activeStatus}");
    if (widget.isPendOrd == true) {
      isScroll = true;
    } else {
      isScroll = false;
    }

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
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
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
                  Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
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

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    Order_Model model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate;

    if (model.listStatus!.contains(CONFIRMED)) {
      pDate = model.listDate![model.listStatus!.indexOf(CONFIRMED)];

      if (pDate != "") {
        List d = pDate!.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PREPARING)) {
      prDate = model.listDate![model.listStatus!.indexOf(PREPARING)];
      if (prDate != "") {
        List d = prDate!.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(OUT_FOR_DELIVERY)) {
      sDate = model.listDate![model.listStatus!.indexOf(OUT_FOR_DELIVERY)];
      if (sDate != "") {
        List d = sDate!.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERED)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERED)];
      if (dDate != "") {
        List d = dDate!.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus!.indexOf(CANCLED)];
      if (cDate != "") {
        List d = cDate!.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primary,
      body: _isNetworkAvail
          ? Stack(
              children: [
                NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: controller,
                  clipBehavior: Clip.none,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        toolbarHeight: 0,
                        titleSpacing: 0,
                        pinned: true,
                        bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(43),
                            child: AppBar(
                              title: Text(
                                getTranslated(context, 'ORDER_DETAIL')!,
                                style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              elevation: 0,
                              centerTitle: true,
                              leading: Builder(builder: (BuildContext context) {
                                return Container(
                                  margin: const EdgeInsetsDirectional.only(
                                    start: 7.0,
                                    top: 5.0,
                                    bottom: 10.0,
                                  ),
                                  child: InkWell(
                                    child: const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: white,
                                      child: Center(
                                        child: Icon(
                                          Icons.keyboard_arrow_left,
                                          color: darkFontColor,
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
                              toolbarHeight: 43,
                            )),
                        backgroundColor: primary,
                        elevation: 0,
                        floating: true,
                      ),
                      SliverToBoxAdapter(
                          child: AnimatedContainer(
                        height: isScroll ? 180 : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 15.0),
                              child: Text("Hello $CUR_USERNAME,",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(top: 10.0, start: 20.0, end: 20.0),
                                child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.location_on, color: white, size: 25),
                                  widget.model!.address!.isNotEmpty
                                      ? Expanded(
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional.only(start: 5.0),
                                            child: Text(widget.model!.address!,
                                                softWrap: true,
                                                textAlign: TextAlign.start,
                                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: white)),
                                          ),
                                        )
                                      : Container(),
                                ]),
                              )),
                          Expanded(
                            flex: 5,
                            child: Padding(
                                padding: const EdgeInsetsDirectional.only(top: 20.0, start: 20.0, end: 20.0, bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      child: Container(
                                          padding: const EdgeInsetsDirectional.only(start: 18.0, end: 18.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: white,
                                          ),
                                          child: Text(
                                            getTranslated(context, 'ACC_LBL')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(color: darkFontColor, fontWeight: FontWeight.bold, fontSize: 14),
                                          )),
                                      onTap: () {
                                        setState(() {
                                          updateOrderReq("1", widget.model!.id);
                                        });
                                      },
                                    ),
                                    InkWell(
                                      child: Container(
                                          padding: const EdgeInsetsDirectional.only(start: 18.0, end: 18.0, top: 10.0, bottom: 10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: darkFontColor,
                                          ),
                                          child: Text(
                                            getTranslated(context, 'DECLINE_LBL')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(color: white, fontWeight: FontWeight.bold, fontSize: 14),
                                          )),
                                      onTap: () {
                                        setState(() {
                                          updateOrderReq("0", widget.model!.id);
                                        });
                                      },
                                    ),
                                  ],
                                )),
                          )
                        ]),
                      )),
                    ];
                  },
                  body: Padding(
                    padding: EdgeInsets.only(top: isScroll ? 0.0 : 20.0),
                    child: Container(
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
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Card(
                                        elevation: 0,
                                        child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${getTranslated(context, 'ORDER_ID_LBL')} - ${model.id!}",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                                ),
                                                Text(
                                                  "${getTranslated(context, 'ORDER_DATE')} - ${model.orderDate!}",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                                ),
                                                Text(
                                                  "${getTranslated(context, 'PAYMENT_MTHD')} - ${model.payMethod!}",
                                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                                ),
                                              ],
                                            ))),
                                    model.delDate != "" && model.delDate!.isNotEmpty
                                        ? Card(
                                            elevation: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(
                                                "${getTranslated(context, 'PREFER_DATE_TIME')}: ${model.delDate!} - ${model.delTime!}",
                                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                              ),
                                            ))
                                        : Container(),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: model.itemList!.length,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        OrderItem orderItem = model.itemList![i];
                                        return productItem(orderItem, model, i);
                                      },
                                    ),
                                    orderStaDetails(),
                                    restDetails(),
                                    shippingDetails(),
                                    priceDetails(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          widget.model!.activeStatus == CONFIRMED || widget.model!.activeStatus == PREPARING ? Container() : Container(),
                          widget.model!.activeStatus == CONFIRMED || widget.model!.activeStatus == PREPARING
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                                          child: DropdownButtonFormField(
                                            dropdownColor: white,
                                            isDense: true,
                                            iconEnabledColor: darkFontColor,
                                            hint: Text(
                                              "Update Status",
                                              style: Theme.of(this.context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              isDense: true,
                                              fillColor: white,
                                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: darkFontColor),
                                              ),
                                            ),
                                            onChanged: (dynamic newValue) {
                                              setState(() {
                                                curStatus = newValue;
                                              });
                                            },
                                            items: statusList.map((String st) {
                                              return DropdownMenuItem<String>(
                                                value: st,
                                                child: Text(
                                                  st == OUT_FOR_DELIVERY ? OUT_FOR_DELIVERY_LBL : capitalize(st),
                                                  style: Theme.of(this.context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      RawMaterialButton(
                                        constraints: const BoxConstraints.expand(width: 42, height: 42),
                                        onPressed: () {
                                          if (Is_RIDER_OTP_SETTING_ON == "1") {
                                            if (model.otp != "" && model.otp!.isNotEmpty && model.otp != "0" && curStatus == DELIVERED ||
                                                curStatus == CANCLED) {
                                              otpDialog(curStatus, model.otp, model.id, false, 0);
                                            } else {
                                              updateOrder(curStatus, model.id);
                                            }
                                          } else {
                                            updateOrder(curStatus, model.id);
                                          }
                                        },
                                        elevation: 2.0,
                                        fillColor: darkFontColor,
                                        padding: const EdgeInsetsDirectional.only(start: 5),
                                        shape: const CircleBorder(),
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.send,
                                            size: 20,
                                            color: white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                                          child: DropdownButtonFormField(
                                            dropdownColor: white,
                                            isDense: true,
                                            iconEnabledColor: darkFontColor,
                                            hint: Text(
                                              "Update Status",
                                              style: Theme.of(this.context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              isDense: true,
                                              fillColor: white,
                                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: darkFontColor),
                                              ),
                                            ),
                                            value: widget.model!.activeStatus,
                                            onChanged: (dynamic newValue) {
                                              setState(() {
                                                curStatus = newValue;
                                              });
                                            },
                                            items: statusList.map((String st) {
                                              return DropdownMenuItem<String>(
                                                value: st,
                                                child: Text(
                                                  st == OUT_FOR_DELIVERY ? OUT_FOR_DELIVERY_LBL : capitalize(st),
                                                  style: Theme.of(this.context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(color: darkFontColor, fontWeight: FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      RawMaterialButton(
                                        constraints: const BoxConstraints.expand(width: 42, height: 42),
                                        onPressed: () {
                                          if (Is_RIDER_OTP_SETTING_ON == "1") {
                                            if (model.otp != "" && model.otp!.isNotEmpty && model.otp != "0" && curStatus == DELIVERED ||
                                                curStatus == CANCLED) {
                                              otpDialog(curStatus, model.otp, model.id, false, 0);
                                            } else {
                                              updateOrder(curStatus, model.id);
                                            }
                                          } else {
                                            updateOrder(curStatus, model.id);
                                          }
                                        },
                                        elevation: 2.0,
                                        fillColor: darkFontColor,
                                        padding: const EdgeInsetsDirectional.only(start: 5),
                                        shape: const CircleBorder(),
                                        child: const Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.send,
                                            size: 20,
                                            color: white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
    );
  }

  getAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0))),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AnimatedContainer(
            alignment: Alignment.topLeft,
            padding: const EdgeInsetsDirectional.only(
              start: 20.0,
            ),
            duration: const Duration(seconds: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Hello $CUR_USERNAME", textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: white)),
              ],
            ),
          )),
      title: Text(
        getTranslated(context, 'ORDER_DETAIL')!,
        style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(13),
          child: InkWell(
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: white,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: darkFontColor,
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
    );
  }

  showRequestDialogue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            alignment: Alignment.center,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(top: 10, right: 10, child: bottomSheetHandle(context)),
                Container(
                  height: deviceHeight * 0.38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 47, horizontal: 22.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("Accept", style: Theme.of(context).textTheme.displayMedium),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Text("decline", style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  otpDialog(String? curSelected, String? otp, String? id, bool item, int index) async {
    print("otp:$otp");
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
                          getTranslated(context, 'OTP_LBL')!,
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
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return getTranslated(context, 'FIELD_REQUIRED');
                                    } else if (value.trim() != otp) {
                                      return getTranslated(context, 'OTPERROR');
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: InputDecoration(
                                    hintText: getTranslated(context, 'OTP_ENTER'),
                                    hintStyle:
                                        Theme.of(this.context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
                                  ),
                                  controller: otpC,
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
                          this.otp = otpC!.text;
                          Navigator.pop(context);
                        });
                        updateOrder(curSelected, id);
                      }
                    })
              ],
            );
          });
        });
  }

  priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(getTranslated(context, 'PRICE_DETAIL')!,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold))),
              const Divider(
                color: lightFontColor,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'PRICE_LBL')} :", style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("${CUR_CURRENCY!} ${(double.parse(widget.model!.subTotal!)).toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'DELIVERY_CHARGE_LBL')} :",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("+ ${CUR_CURRENCY!} ${widget.model!.delCharge!}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'TAXPER')} (${widget.model!.taxPer!}) :",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("+ ${CUR_CURRENCY!} ${widget.model!.taxAmt!}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'DELIVERY_TIP_LBL')}:",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("+ ${CUR_CURRENCY!} ${widget.model!.delTip!}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'PROMO_CODE_DIS_LBL')} :",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("- ${CUR_CURRENCY!} ${widget.model!.promoDis!}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'WALLET_BAL')} :", style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor)),
                    Text("- ${CUR_CURRENCY!} ${widget.model!.walBal!}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${getTranslated(context, 'TOTAL_PRICE')} :",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold)),
                    Text("${CUR_CURRENCY!} ${double.parse(widget.model!.payable!).round()}",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ])));
  }

  deliTipDetails() {
    return widget.model!.delTip != ""
        ? Card(
            elevation: 0,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        children: [
                          Text(getTranslated(context, 'DELIVERY_TIP_LBL')!,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(
                            "${CUR_CURRENCY!} ${widget.model!.delTip!}",
                            style:
                                Theme.of(context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      )),
                ])))
        : Container();
  }

  orderStaDetails() {
    return widget.model!.activeStatus == CONFIRMED || widget.model!.activeStatus == PREPARING
        ? Card(
            elevation: 0,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        children: [
                          Text(getTranslated(context, 'ORDER_STA_LBL')!,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(
                            widget.model!.activeStatus! == CONFIRMED ? ORDER_RECEIVED : capitalize(widget.model!.activeStatus!),
                            style:
                                Theme.of(context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      )),
                ])))
        : Container();
  }

  restDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 15.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text(getTranslated(context, 'REST_DETAIL_LBL')!,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (widget.model!.activeStatus == CONFIRMED || widget.model!.activeStatus == PREPARING)
                        InkWell(
                          child: Container(
                              padding: const EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 6.0, bottom: 6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: darkFontColor,
                              ),
                              child: Text(
                                getTranslated(context, 'TRACK_REST')!,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: white, fontWeight: FontWeight.bold, fontSize: 14),
                              )),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MapScreen(
                                        latitude: double.parse(widget.model!.itemList![0].partDetails![0].latitude!),
                                        longitude: double.parse(widget.model!.itemList![0].partDetails![0].longitude!),
                                        orderId: widget.model!.id,
                                        isDel: false,
                                      )),
                            );
                          },
                        ),
                    ],
                  )),
              const Divider(
                color: lightFontColor,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    widget.model!.itemList![0].partDetails![0].par_name != "" && widget.model!.itemList![0].partDetails![0].par_name!.isNotEmpty
                        ? " ${capitalize(widget.model!.itemList![0].partDetails![0].par_name!)}"
                        : " ",
                  )),
              widget.model!.itemList![0].partDetails![0].address!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                      child: Text(widget.model!.itemList![0].partDetails![0].address!, style: const TextStyle(color: lightFontColor)))
                  : Container(),
              widget.model!.itemList![0].partDetails![0].email!.isNotEmpty
                  ? InkWell(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email,
                                size: 15,
                                color: darkFontColor,
                              ),
                              Text(" ${widget.model!.itemList![0].partDetails![0].email!}",
                                  style: const TextStyle(color: darkFontColor, decoration: TextDecoration.underline)),
                            ],
                          )),
                      onTap: () {
                        _launchEmail(widget.model!.itemList![0].partDetails![0].email!);
                      })
                  : Container(),
              widget.model!.itemList![0].partDetails![0].mobile!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                      child: InkWell(
                        onTap: () {
                          _launchCaller(widget.model!.itemList![0].partDetails![0].mobile!);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call,
                              size: 15,
                              color: darkFontColor,
                            ),
                            Text(" ${widget.model!.itemList![0].partDetails![0].mobile!}",
                                style: const TextStyle(color: darkFontColor, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ])));
  }

  shippingDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text(getTranslated(context, 'SHIPPING_DETAIL')!,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: darkFontColor, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (widget.model!.activeStatus == OUT_FOR_DELIVERY)
                        InkWell(
                          child: Container(
                              padding: const EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 6.0, bottom: 6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: darkFontColor,
                              ),
                              child: Text(
                                getTranslated(context, 'TRACK_ORDER_LBL')!,
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: white, fontWeight: FontWeight.bold, fontSize: 14),
                              )),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MapScreen(
                                        latitude: double.parse(widget.model!.latitude!),
                                        longitude: double.parse(widget.model!.longitude!),
                                        orderId: widget.model!.id,
                                        isDel: true,
                                      )),
                            );
                          },
                        ),
                    ],
                  )),
              const Divider(
                color: lightFontColor,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    widget.model!.name != "" && widget.model!.name!.isNotEmpty ? " ${capitalize(widget.model!.name!)}" : " ",
                  )),
              widget.model!.address!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                      child: Text(widget.model!.address!, style: const TextStyle(color: lightFontColor)))
                  : Container(),
              widget.model!.mobile!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                      child: InkWell(
                        onTap: () {
                          _launchCaller(widget.model!.mobile!);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.call,
                              size: 15,
                              color: darkFontColor,
                            ),
                            Text(" ${widget.model!.mobile!}", style: const TextStyle(color: darkFontColor, decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ])));
  }

  productItem(OrderItem orderItem, Order_Model model, int i) {
    List? att, val;
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }

    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(orderItem.image!),
                          height: 90.0,
                          width: 90.0,
                          placeholder: placeHolder(90),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItem.name ?? '',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: lightFontColor, fontWeight: FontWeight.normal),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            orderItem.attr_name!.isNotEmpty
                                ? ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att!.length,
                                    itemBuilder: (context, index) {
                                      return Row(children: [
                                        Flexible(
                                          child: Text(
                                            att![index].trim() + ":",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(start: 5.0),
                                          child: Text(
                                            val![index],
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),
                            Row(children: [
                              Text(
                                "${getTranslated(context, 'QUANTITY_LBL')}:",
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: 5.0),
                                child: Text(
                                  orderItem.qty!,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightFontColor),
                                ),
                              )
                            ]),
                            Text(
                              "${CUR_CURRENCY!} ${double.parse(orderItem.price!).toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: darkFontColor),
                            ),
                            Wrap(
                                spacing: 5.0,
                                runSpacing: 2.0,
                                direction: Axis.horizontal,
                                children: List.generate(orderItem.addOns!.length, (j) {
                                  Ad_ons addOnData = orderItem.addOns![j];
                                  return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${addOnData.qty!} x ${addOnData.title!}",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: black, fontSize: 10, overflow: TextOverflow.ellipsis),
                                            maxLines: 2),
                                        Text("$CUR_CURRENCY${addOnData.price!}, ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.primary, fontSize: 10, overflow: TextOverflow.ellipsis)),
                                      ]);
                                })),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  Future<void> updateOrderReq(String? status, String? id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {ORDERID: id, ACCEPT_ORDER: status, RIDER_ID: CUR_USERID};

        apiBaseHelper.postAPICall(updateOrderReqApi, parameter, context).then((getdata) {
          print(getdata);
          bool error = getdata["error"];
          String msg = getdata["message"];
          setSnackbar(msg);
          if (!error) {
            setState(() {
              isScroll = false;
            });
          }

          setState(() {
            _isProgress = false;
          });
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> updateOrder(String? status, String? id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {ORDERID: id.toString(), STATUS: status.toString(), RIDER_ID: CUR_USERID.toString()};
        print(parameter);

        if (Is_RIDER_OTP_SETTING_ON == "1") {
          if (status == DELIVERED || status == CANCLED) {
            parameter[OTP] = otp.toString();
          }
        }

        apiBaseHelper.postAPICall(updateOrderApi, parameter, context).then((getdata) {
          print(getdata);
          bool error = getdata["error"];
          String msg = getdata["message"];
          setSnackbar(msg);
          if (!error) {
            setState(() {
              widget.model!.activeStatus = status;
            });

            if (status == DELIVERED) {
              getUserDetail();
              manageLiveData(DELIVERED, latitude.toString(), longitude.toString());
            }
          }

          setState(() {
            _isProgress = false;
          });
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> manageLiveData(String? status, String lat, String long) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ORDERID: widget.model!.id, ORDER_STATUS: status, LATITUDE: lat, LONGITUDE: long};

        apiBaseHelper.postAPICall(manageLiveTrackApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {
            deleteLiveData();
          }
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> deleteLiveData() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ORDERID: widget.model!.id,
        };

        apiBaseHelper.postAPICall(deleteLiveTrackApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {}
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> getUserDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID};

        apiBaseHelper.postAPICall(getBoyDetailApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

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

  _launchCaller(String mobile) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: mobile,
    );
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  _launchEmail(email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{'subject': ''}),
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch $emailLaunchUri';
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
}
