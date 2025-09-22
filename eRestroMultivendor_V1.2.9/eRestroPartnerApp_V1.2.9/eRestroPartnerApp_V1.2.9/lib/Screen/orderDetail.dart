import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Helper/session.dart';
import 'package:project/Model/Ad-Ons/ad_ons.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/string.dart';
import '../Model/OrdersModel/order_items_model.dart';
import '../Model/OrdersModel/order_model.dart';
import '../Model/Person/person_model.dart';
import 'home.dart';
import 'package:intl/intl.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model? model;
  final Function? updateHome;

  const OrderDetail({
    Key? key,
    this.model,
    this.updateHome,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

List<PersonModel> delBoyList = [];

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  List<String> statusList = [];
  bool loadingData = true;
  bool _isProgress = false, isNoteVisible = true;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC, courierAgencyController, trackingIdController, urlController;
  String? cancelReason;
  final List<DropdownMenuItem> items = [];
  List<PersonModel> searchList = [];
  String? selectedValue, courierAgency, trackingId, url;
  int? selectedDelBoy;
  TextEditingController reasonController = TextEditingController();
  FocusNode? reasonFocus = FocusNode();
  final TextEditingController _controller = TextEditingController();
  late StateSetter delBoyState, selfPickupState;

  bool fabIsVisible = true;
  Future<List<Directory>?>? _externalStorageDirectories;

  DateTime? selectedDate;
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final DateFormat formatterDate = DateFormat('dd\\MM\\yyyy, hh:mm a');
  TextEditingController ownerNoteController = TextEditingController(text: "");
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    // Select date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 50),
    );

    if (pickedDate != null) {
      // Select time after date is picked
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(today),
      );

      if (pickedTime != null) {
        // Combine date and time
        selfPickupState(() {
          setState(() {
            selectedDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        });
      }
    }

    if (selectedDate != null) {
      print("Selected DateTime: ${formatDate(selectedDate!)}");
    } else {
      print("No date and time selected.");
    }
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  selfPickupStatusUpdate() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (
            BuildContext context,
            StateSetter setStater,
          ) {
            selfPickupState = setStater;
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
                          getTranslated(context, "pickupDetail")!,
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, "ownerNoteForSelfPickup")!,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: white,
                              border: Border.all(
                                color: backgroun2,
                                width: 1,
                              ),
                            ),
                            margin: EdgeInsetsDirectional.only(bottom: 10.0, end: 10.0, top: 10.0),
                            width: width,
                            padding: EdgeInsetsDirectional.zero,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: InputDecoration(border: InputBorder.none, isDense: true),
                              validator: (val) => validateField(val, context),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: ownerNoteController,
                            ),
                          ),
                          Text(
                            getTranslated(context, "selfPickupDateTime")!,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16,
                              color: black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: white,
                                  border: Border.all(
                                    color: backgroun2,
                                    width: 1,
                                  ),
                                ),
                                margin: EdgeInsetsDirectional.only(bottom: 10.0, end: 10.0, top: 10.0),
                                width: width,
                                padding: EdgeInsetsDirectional.only(top: 10, bottom: 10, start: 10, end: 10),
                                alignment: Alignment.centerLeft,
                                child: Text(selectedDate == null ? "Self Pickup Date Time" : "${formatter.format(selectedDate!)}",
                                    style: TextStyle(color: black, fontSize: 14.0, fontWeight: FontWeight.w400))),
                          ),
                        ],
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
                        Navigator.pop(context);
                      }
                    })
              ],
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    print("modelData:${widget.model!.isSelfPickUp!}");
    if (widget.model!.isSelfPickUp == "1") {
      statusList = [PLACED, PROCESSED, SHIPED, CANCLED, RETURNED, WAITING, READYFORPICKUP];
      setState(() {});
    } else {
      statusList = [PLACED, PROCESSED, SHIPED, DELIVERD, CANCLED, RETURNED, WAITING];
      setState(() {});
    }
    getStatics();
    getDeliveryBoy();
    _externalStorageDirectories = getExternalStorageDirectories(type: StorageDirectory.downloads);

    if (widget.model!.riderId != "") {
      selectedDelBoy = delBoyList.indexWhere(
        (f) => f.id == widget.model!.riderId,
      );
    }

    controller = ScrollController();
    controller.addListener(
      () {
        setState(
          () {
            fabIsVisible = controller.position.userScrollDirection == ScrollDirection.forward;
          },
        );
      },
    );
    buttonController = AnimationController(
        duration: const Duration(
          milliseconds: 2000,
        ),
        vsync: this);
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
    curStatus = widget.model!.activeStatus;

    _controller.addListener(
      () {
        searchOperation(
          _controller.text,
        );
      },
    );
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
          setState(() {});
        } else {
          setsnackbar(msg!, context);
        }
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
    return;
  }

//========================= getDeliveryBoy API =================================

  Future<void> getDeliveryBoy() async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      resturantId: CUR_USERID,
    };

    apiBaseHelper.postAPICall(getRidersApi, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          delBoyList.clear();
          var data = getdata["data"];
          delBoyList = (data as List)
              .map(
                (data) => PersonModel.fromJson(
                  data,
                ),
              )
              .toList();
          searchList.addAll(delBoyList);
          setState(
            () {
              loadingData = false;
            },
          );
        } else {
          setsnackbar(msg!, context);
          setState(
            () {
              loadingData = false;
            },
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(
                context,
                "TRY_AGAIN_INT_LBL",
              )!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.height;
    height = MediaQuery.of(context).size.width;

    Order_Model model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus!.contains(PLACED)) {
      pDate = model.listDate![model.listStatus!.indexOf(PLACED)];

      if (pDate != "") {
        List d = pDate!.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus!.indexOf(PROCESSED)];
      if (prDate != "") {
        List d = prDate!.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus!.indexOf(SHIPED)];
      if (sDate != "") {
        List d = sDate!.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERD)];
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
    if (model.listStatus!.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus!.indexOf(RETURNED)];
      if (rDate != "") {
        List d = rDate!.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroun1,
      appBar: getAppBar(
        getTranslated(context, "ORDERDETAIL")!,
        context,
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(
          milliseconds: 100,
        ),
        opacity: fabIsVisible ? 1 : 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 108.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: black,
                splashColor: primary,
                focusColor: white,
                onPressed: () async {
                  String text = (getTranslated(context, "Hello")! +
                      " " +
                      '${widget.model!.name} \n' +
                      getTranslated(context, "Your order with id")! +
                      ' : ${widget.model!.id} ' +
                      getTranslated(context, "is")! +
                      ' ${widget.model!.activeStatus}. ' +
                      getTranslated(context, "If you have further query feel free to contact us.Thank you.")! +
                      '.');
                  var whatsapp = ("${widget.model!.countryCode!}${widget.model!.mobile!}");

                  var whatappURLIos = "https://wa.me/$whatsapp?text=$text";
                  var encoded = Uri.encodeFull(whatappURLIos);

                  if (Platform.isIOS) {
                    // for iOS phone only

                    if (await canLaunchUrl(Uri.parse(encoded))) {
                      launchUrl(Uri.parse(encoded));
                    } else {
                      setsnackbar(
                        '${getTranslated(context, "Could not launch")!} $url',
                        context,
                      );
                    }
                  } else {
                    // android
                    if (await canLaunchUrl(Uri.parse(encoded))) {
                      launchUrl(Uri.parse(encoded));
                    } else {
                      setsnackbar(
                        '${getTranslated(context, "Could not launch")!} $url',
                        context,
                      );
                    }
                  }
                },
                heroTag: null,
                child: Image.asset(
                  setPngPath("whatsapp"),
                  width: 25,
                  height: 25,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: black,
                onPressed: () async {
                  String text =
                      '${getTranslated(context, "Hello")!} ${widget.model!.name},\n${getTranslated(context, "Your order with id")!} : ${widget.model!.id} ${getTranslated(context, "is")!} ${widget.model!.activeStatus}. ${getTranslated(context, "If you have further query feel free to contact us.Thank you.")!}';
                  var androiduri = 'sms:${widget.model!.mobile}?body=$text';
                  var iosuri = 'sms:${widget.model!.mobile}&body=$text';
                  var androidencoded = Uri.encodeFull(androiduri);
                  var iosencoded = Uri.encodeFull(iosuri);

                  if (Platform.isIOS) {
                    // for iOS phone only

                    if (await canLaunchUrl(Uri.parse(iosencoded))) {
                      launchUrl(Uri.parse(iosencoded));
                    } else {
                      setsnackbar(
                        '${getTranslated(context, "Could not launch")!} $url',
                        context,
                      );
                    }
                  } else {
                    // android
                    if (await canLaunchUrl(Uri.parse(androidencoded))) {
                      launchUrl(Uri.parse(androidencoded));
                    } else {
                      setsnackbar(
                        '${getTranslated(context, "Could not launch")!} $url',
                        context,
                      );
                    }
                  }
                },
                heroTag: null,
                child: const Icon(
                  Icons.message,
                  color: white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isNetworkAvail
          ? loadingData
              ? showCircularProgress(
                  true,
                  primary,
                )
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: controller,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Column(
                                children: [
                                  model.notes != ""
                                      ? Visibility(
                                          visible: isNoteVisible,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: const BoxDecoration(
                                                color: grey,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      style: BorderStyle.solid,
                                                      width: 2,
                                                      color: black,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              "${getTranslated(
                                                                context,
                                                                "NOTE",
                                                              )!}:",
                                                              style: const TextStyle(
                                                                color: white,
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                if (mounted) {
                                                                  setState(
                                                                    () {
                                                                      isNoteVisible = false;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: const Icon(
                                                                Icons.close,
                                                                size: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          model.notes!,
                                                          style: const TextStyle(
                                                            color: black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Card(
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          10.0,
                                        ),
                                      ),
                                      side: BorderSide(
                                        color: backgroun2,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(
                                        12.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "${getTranslated(
                                                  context,
                                                  "ORDER_ID_LBL",
                                                )!} - ",
                                                style: const TextStyle(
                                                  color: black,
                                                ),
                                              ),
                                              Text(
                                                model.id!,
                                                style: const TextStyle(
                                                  color: primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${getTranslated(
                                                  context,
                                                  "Order Date",
                                                )!} - ",
                                                style: const TextStyle(
                                                  color: black,
                                                ),
                                              ),
                                              Text(
                                                model.orderDate!,
                                                style: const TextStyle(
                                                  color: primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${getTranslated(
                                                  context,
                                                  "PAYMENT_MTHD",
                                                )!} : ",
                                                style: const TextStyle(
                                                  color: black,
                                                ),
                                              ),
                                              Text(
                                                model.payMethod!,
                                                style: const TextStyle(
                                                  color: primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  model.delDate != "" && model.delDate!.isNotEmpty
                                      ? Card(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                10.0,
                                              ),
                                            ),
                                            side: BorderSide(
                                              color: backgroun2,
                                              width: 1.0,
                                            ),
                                          ),
                                          elevation: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              12.0,
                                            ),
                                            child: Text(
                                              "${getTranslated(
                                                context,
                                                "PREFER_DATE_TIME",
                                              )!}: ${model.delDate!} - ${model.delTime!}",
                                              style: const TextStyle(
                                                color: lightBlack2,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: model.itemList!.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      OrderItem orderItem = model.itemList![i];
                                      return productItem(
                                        orderItem,
                                        model,
                                        i,
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  shippingDetails(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  dwnInvoice(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  selfPickupDetail(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  priceDetails(),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8.0,
                                  ),
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    dropdownColor: white,
                                    isDense: true,
                                    iconEnabledColor: black,
                                    hint: Text(
                                      getTranslated(
                                        context,
                                        "UpdateStatus",
                                      )!,
                                      style: const TextStyle(
                                        color: black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      isDense: true,
                                      fillColor: white,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: backgroun2,
                                        ),
                                      ),
                                    ),
                                    value: widget.model!.activeStatus,
                                    onChanged: (dynamic newValue) {
                                      setState(
                                        () {
                                          curStatus = newValue;
                                        },
                                      );
                                    },
                                    items: statusList.map(
                                      (String st) {
                                        return DropdownMenuItem<String>(
                                          value: st,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                () {
                                                  if (capitalize(st) == "Pending") {
                                                    return getTranslated(
                                                      context,
                                                      "PENDING",
                                                    )!;
                                                  } else if (capitalize(st) == "Confirmed") {
                                                    return getTranslated(context, "Confirmed")!;
                                                  } else if (capitalize(st) == "Preparing") {
                                                    return getTranslated(context, "Preparing")!;
                                                  } else if (capitalize(st) == "Out_for_delivery") {
                                                    return getTranslated(context, "Out for Delivery")!;
                                                  } else if (capitalize(st) == "Delivered") {
                                                    return getTranslated(context, "DELIVERED_LBL")!;
                                                  } else if (capitalize(st) == "Returned") {
                                                    return getTranslated(context, "RETURNED_LBL")!;
                                                  } else if (capitalize(st) == "Cancelled") {
                                                    return getTranslated(context, "CANCELLED_LBL")!;
                                                  } else if (capitalize(st) == "Ready_for_pickup") {
                                                    return getTranslated(context, "READY_FOR_PICKUP_LBL")!;
                                                  }
                                                  return capitalize(st);
                                                }(),
                                                style: const TextStyle(
                                                  color: black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                              assignRider && widget.model!.isSelfPickUp == "0"
                                  ? Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: white,
                                            border: Border.all(
                                              color: backgroun2,
                                            ),
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  selectedDelBoy != null && selectedDelBoy != -1
                                                      ? searchList[selectedDelBoy!].name!
                                                      : getTranslated(
                                                          context,
                                                          "Select Rider",
                                                        )!,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                color: black,
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          delboyDialog();
                                        },
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        curStatus == "cancelled" ? addCancelReason() : Container(),
                        Container(
                          margin: const EdgeInsets.all(10),
                          width: double.maxFinite,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: black,
                              disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.12),
                            ),
                            onPressed: () async {
                              _isNetworkAvail = await isNetworkAvailable();
                              if (_isNetworkAvail) {
                                bool isSelfPickUp = widget.model!.isSelfPickUp == "1";
                                bool isOwnerNoteEmpty = ownerNoteController.text.isEmpty;
                                bool isSelectedDateNull = selectedDate == null;

                                print(
                                    "isSelfPickUp == '1': ${widget.model?.isSelfPickUp == "1"}--${(isSelfPickUp && isOwnerNoteEmpty && isSelectedDateNull)}");
                                print("ownerNoteController.text.isEmpty: ${ownerNoteController.text.isEmpty}");
                                print("selectedDate == null: ${selectedDate == null}");

                                if ((widget.model!.isSelfPickUp == "1") && (ownerNoteController.text.isEmpty || selectedDate == null)) {
                                  selfPickupStatusUpdate();
                                } else {
                                  if (model.otp != "" && model.otp!.isNotEmpty && model.otp != "0" && curStatus == CANCLED) {
                                    otpDialog(
                                      curStatus,
                                      model.otp,
                                      model.id,
                                      false,
                                      0,
                                    );
                                  } else {
                                    updateOrder(
                                      curStatus,
                                      updateOrderStatusApi,
                                      model.id,
                                      false,
                                      0,
                                    );
                                  }
                                }
                              } else {
                                await buttonController!.reverse();
                                setState(
                                  () {},
                                );
                              }
                            },
                            child: Text(
                              getTranslated(context, "UPDATE ORDER")!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    showCircularProgress(
                      _isProgress,
                      primary,
                    ),
                  ],
                )
          : noInternet(context),
    );
  }

  addCancelReason() {
    return SizedBox(
      width: width * 0.9,
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(reasonFocus);
        },
        focusNode: reasonFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: reasonController,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          cancelReason = value;
        },
        decoration: InputDecoration(
          hintText: "Type reason for cancelation",
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.normal,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
        ),
      ),
    );
  }

  Future<void> searchOperation(String searchText) async {
    searchList.clear();
    for (int i = 0; i < delBoyList.length; i++) {
      PersonModel map = delBoyList[i];

      if (map.name!.toLowerCase().contains(searchText)) {
        searchList.add(map);
      }
    }

    if (mounted) {
      delBoyState(
        () {},
      );
    }
  }

  delboyDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setStater,
          ) {
            delBoyState = setStater;
            return AlertDialog(
              contentPadding: const EdgeInsets.all(
                0.0,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
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
                        "Select Rider",
                      )!,
                      style: const TextStyle(
                        color: primary,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    autofocus: false,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(
                        0,
                        15.0,
                        0,
                        15.0,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: black,
                        size: 17,
                      ),
                      hintText: getTranslated(
                        context,
                        "Search",
                      )!,
                      hintStyle: const TextStyle(
                        color: black,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: white,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: backgroun2,
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getLngList(),
                      ),
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

  List<Widget> getLngList() {
    return searchList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(
                    () {
                      selectedDelBoy = index;

                      Navigator.of(context).pop();
                    },
                  );
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(
                    8.0,
                  ),
                  child: Text(
                    searchList[index].name!,
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  otpDialog(
    String? curSelected,
    String? otp,
    String? id,
    bool item,
    int index,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setStater,
          ) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(
                0.0,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
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
                        getTranslated(context, "OTP_LBL")!,
                        style: const TextStyle(
                          color: fontColor,
                        ),
                      ),
                    ),
                    const Divider(
                      color: backgroun2,
                    ),
                    Form(
                      key: _formkey,
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
                              keyboardType: TextInputType.number,
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(context, "FIELD_REQUIRED")!;
                                } else if (value.trim() != otp) {
                                  return getTranslated(context, "OTPERROR")!;
                                } else {
                                  return null;
                                }
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: getTranslated(
                                  context,
                                  "OTP_ENTER",
                                )!,
                                hintStyle: const TextStyle(
                                  color: lightBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              controller: otpC,
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
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "SEND_LBL")!,
                    style: const TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final form = _formkey.currentState!;
                    if (form.validate()) {
                      form.save();
                      setState(
                        () {
                          Navigator.pop(context);
                        },
                      );
                      updateOrder(
                        curSelected,
                        updateOrderStatusApi,
                        id,
                        item,
                        index,
                      );
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

  _launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url = "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      setsnackbar(
        '${getTranslated(context, "Could not launch")!} $url',
        context,
      );
    }
  }

  selfPickupDetail() {
    return (widget.model!.isSelfPickUp == "1")
        ? Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              side: BorderSide(
                color: backgroun2,
                width: 1.0,
              ),
            ),
            elevation: 0,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  15.0,
                  0,
                  15.0,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          getTranslated(context, "pickupDetail")!,
                          style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            selfPickupStatusUpdate();
                          },
                          child: const Icon(
                            Icons.edit,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: backgroun2,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${getTranslated(context, "ownerNoteForSelfPickup")!} :",
                          style: const TextStyle(
                            color: black,
                          ),
                        ),
                        Text(
                          "${ownerNoteController.text}",
                          style: const TextStyle(
                            color: lightBlack2,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${getTranslated(context, "selfPickupDateTime")!} :",
                          style: const TextStyle(
                            color: black,
                          ),
                        ),
                        Text(
                          "${selectedDate == null ? "" : formatterDate.format(selectedDate!)}",
                          style: const TextStyle(
                            color: lightBlack2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ])))
        : SizedBox.shrink();
  }

  priceDetails() {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        side: BorderSide(
          color: backgroun2,
          width: 1.0,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                getTranslated(context, "PRICE_DETAIL")!,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              color: backgroun2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "PRICE_LBL")!} :",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  ),
                  Text(
                    "$CUR_CURRENCY ${(double.parse(widget.model!.subTotal!)).toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "DELIVERY_CHARGE")!} :",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  ),
                  Text(
                    "+ $CUR_CURRENCY ${widget.model!.delCharge!}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "TAXPER")!} (${widget.model!.totalTaxPercent}) :",
                    style: const TextStyle(color: lightBlack2),
                  ),
                  Text(
                    "+ $CUR_CURRENCY ${widget.model!.totalTaxAmount!}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "DELIVERY_TIP_LBL")!}:",
                    style: const TextStyle(color: lightBlack2),
                  ),
                  Text(
                    "+ $CUR_CURRENCY ${widget.model!.deliveryTip!}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "Promo Code Disount")!} :",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  ),
                  Text(
                    "- $CUR_CURRENCY ${widget.model!.promoDis!}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "WALLET_BAL")!} :",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  ),
                  Text(
                    "- $CUR_CURRENCY ${widget.model!.walBal!}",
                    style: const TextStyle(
                      color: lightBlack2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 5.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, "Tatal Payable")!} :",
                    style: const TextStyle(
                      color: lightBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$CUR_CURRENCY ${widget.model!.payable!}",
                    style: const TextStyle(
                      color: lightBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  shippingDetails() {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            10.0,
          ),
        ),
        side: BorderSide(
          color: backgroun2,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                children: [
                  Text(
                    getTranslated(context, "SHIPPING_DETAIL")!,
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      _launchMap(
                        widget.model!.latitude,
                        widget.model!.longitude,
                      );
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: backgroun2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                widget.model!.name != "" && widget.model!.name!.isNotEmpty ? capitalize(widget.model!.name!) : " ",
                style: const TextStyle(
                  color: black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            widget.model!.address == ""
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 3,
                    ),
                    child: Text(
                      widget.model!.address != "" ? capitalize(widget.model!.address!) : "",
                      style: const TextStyle(
                        color: lightBlack2,
                      ),
                    ),
                  ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.call,
                      size: 15,
                      color: primary,
                    ),
                    Text(
                      " ${widget.model!.mobile!}",
                      style: const TextStyle(
                        color: primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                launchCaller(
                  "tel:${widget.model!.mobile}",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  productItem(
    OrderItem orderItem,
    Order_Model model,
    int i,
  ) {
    List att = [], val = [];
    if (orderItem.attrName!.isNotEmpty) {
      att = orderItem.attrName!.split(',');
      val = orderItem.variantValues!.split(',');
    }

    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            10.0,
          ),
        ),
        side: BorderSide(
          color: backgroun2,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          10.0,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                  child: FadeInImage(
                    fadeInDuration: const Duration(
                      milliseconds: 150,
                    ),
                    image: NetworkImage(orderItem.image!),
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.fill,
                    placeholder: placeHolder(
                      90,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          orderItem.name ?? '',
                          style: const TextStyle(
                            color: black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 02,
                        ),
                        orderItem.attrName!.isNotEmpty
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          att[index].trim() + ":",
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: lightBlack2,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 5.0,
                                        ),
                                        child: Text(
                                          val[index],
                                          style: const TextStyle(
                                            color: lightBlack,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              )
                            : Container(),
                        Row(
                          children: [
                            Text(
                              "${getTranslated(context, "QUANTITY_LBL")!} :",
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                              ),
                              child: Text(
                                orderItem.qty!,
                                style: const TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 01,
                        ),
                        Row(
                          children: [
                            Text(
                              "${getTranslated(context, "PRICE_LBL")!} : ",
                              style: const TextStyle(
                                color: black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              CUR_CURRENCY + orderItem.price!,
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                                        style:
                                            TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, overflow: TextOverflow.ellipsis)),
                                  ]);
                            })),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateOrder(
    String? status,
    Uri api,
    String? id,
    bool item,
    int index,
  ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(
          () {
            _isProgress = true;
          },
        );

        var parameter = {
          resturantId: CUR_USERID,
          ORDERID: id,
          STATUS: status,
        };

        if (item) parameter[ORDERITEMID] = widget.model!.itemList![index].id;
        if (selectedDelBoy != null) {
          parameter["deliver_by"] = searchList[selectedDelBoy!].id;
        }
        if (cancelReason != null) {
          parameter["reason"] = cancelReason;
        }
        if (widget.model!.isSelfPickUp == "1") {
          parameter["owner_note"] = ownerNoteController.text;
          parameter["self_pickup_time"] = formatDate(selectedDate!).toString();
        }
        Response response = await post(
          item ? updateOrderStatusApi : updateOrderStatusApi,
          body: parameter,
          headers: await ApiUtils.getHeaders(),
        ).timeout(
          const Duration(
            seconds: timeOut,
          ),
        );

        var getdata = json.decode(response.body);
        bool? error = getdata["error"];
        String? msg = getdata["message"];
        setsnackbar(msg!, context);
        if (!error!) {
          if (item) {
          } else {
            widget.model!.activeStatus = status;
          }
          if (selectedDelBoy != null) {}
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
        }

        setState(
          () {
            _isProgress = false;
          },
        );
      } on TimeoutException catch (_) {
        setsnackbar(
          "somethingMSg",
          context,
        );
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
    }
  }

  launchCaller(String urlString) async {
    var url = urlString.trim();

    if (await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url));
    } else {
      setsnackbar(
        '${getTranslated(context, "Could not launch")!} $url',
        context,
      );
    }
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  dwnInvoice() {
    return Row(
      children: [
        widget.model!.invoiceHtml != ""
            ? Expanded(
                child: FutureBuilder<List<Directory>?>(
                  future: _externalStorageDirectories,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    return Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            10.0,
                          ),
                        ),
                        side: BorderSide(
                          color: backgroun2,
                          width: 1.0,
                        ),
                      ),
                      elevation: 0,
                      child: InkWell(
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsetsDirectional.only(start: width / 80.0, end: width / 80.0),
                          trailing: const Icon(
                            Icons.keyboard_arrow_right,
                            color: primary,
                          ),
                          leading: const Icon(
                            Icons.receipt,
                            color: primary,
                          ),
                          title: Text(
                            getTranslated(context, "Download Invoice")!,
                            style: const TextStyle(
                              color: black,
                            ),
                          ),
                        ),
                        onTap: () async {
                          bool hasPermission = await checkPermission();
                          setState(
                            () {
                              _isProgress = true;
                            },
                          );

                          String target = Platform.isAndroid && hasPermission
                              ? (await ExternalPath.getExternalStoragePublicDirectory(
                                  ExternalPath.DIRECTORY_DOWNLOAD,
                                ))
                              : (await getApplicationDocumentsDirectory()).path;

                          var targetFileName = 'Invoice_${widget.model!.id}';
                          var generatedPdfFile, filePath;
                          try {
                            generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(widget.model!.invoiceHtml!, target, targetFileName);
                            filePath = generatedPdfFile.path;

                            File fileDef = File(filePath);
                            await fileDef.create(recursive: true);
                            Uint8List bytes = await generatedPdfFile.readAsBytes();
                            await fileDef.writeAsBytes(bytes);
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isProgress = false;
                              });
                              setsnackbar(
                                getTranslated(context, "somethingMSg")!,
                                context,
                              );
                            }
                            return;
                          }

                          if (mounted) {
                            setState(() {
                              _isProgress = false;
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${getTranslated(context, "Invoice Path")!} : $targetFileName",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: black,
                                ),
                              ),
                              duration: const Duration(
                                seconds: 7,
                              ),
                              action: SnackBarAction(
                                label: getTranslated(
                                  context,
                                  "View",
                                )!,
                                textColor: fontColor,
                                onPressed: () async {
                                  await OpenFilex.open(
                                    filePath,
                                  );
                                },
                              ),
                              backgroundColor: white,
                              elevation: 1.0,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            : Container(),
        widget.model!.thermalInvoiceHtml != ""
            ? Expanded(
                child: FutureBuilder<List<Directory>?>(
                  future: _externalStorageDirectories,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    return Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            10.0,
                          ),
                        ),
                        side: BorderSide(
                          color: backgroun2,
                          width: 1.0,
                        ),
                      ),
                      elevation: 0,
                      child: InkWell(
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsetsDirectional.only(start: width / 80.0, end: width / 80.0),
                          trailing: const Icon(
                            Icons.keyboard_arrow_right,
                            color: primary,
                          ),
                          leading: const Icon(
                            Icons.receipt,
                            color: primary,
                          ),
                          title: Text(
                            getTranslated(context, "Thermal Printing")!,
                            style: const TextStyle(
                              color: black,
                            ),
                          ),
                        ),
                        onTap: () async {
                          bool hasPermission = await checkPermission();
                          setState(
                            () {
                              _isProgress = true;
                            },
                          );

                          String target = Platform.isAndroid && hasPermission
                              ? (await ExternalPath.getExternalStoragePublicDirectory(
                                  ExternalPath.DIRECTORY_DOWNLOAD,
                                ))
                              : (await getApplicationDocumentsDirectory()).path;

                          var targetFileName = 'Invoice_${widget.model!.id}';
                          var generatedPdfFile, filePath;
                          try {
                            generatedPdfFile =
                                await FlutterHtmlToPdf.convertFromHtmlContent(widget.model!.thermalInvoiceHtml!, target, targetFileName);
                            filePath = generatedPdfFile.path;

                            File fileDef = File(filePath);
                            await fileDef.create(recursive: true);
                            Uint8List bytes = await generatedPdfFile.readAsBytes();
                            await fileDef.writeAsBytes(bytes);
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isProgress = false;
                              });
                              setsnackbar(
                                getTranslated(context, "somethingMSg")!,
                                context,
                              );
                            }
                            return;
                          }

                          if (mounted) {
                            setState(() {
                              _isProgress = false;
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${getTranslated(context, "Invoice Path")!} : $targetFileName",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: black,
                                ),
                              ),
                              duration: const Duration(
                                seconds: 7,
                              ),
                              action: SnackBarAction(
                                label: getTranslated(
                                  context,
                                  "View",
                                )!,
                                textColor: fontColor,
                                onPressed: () async {
                                  await OpenFilex.open(
                                    filePath,
                                  );
                                },
                              ),
                              backgroundColor: white,
                              elevation: 1.0,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}
