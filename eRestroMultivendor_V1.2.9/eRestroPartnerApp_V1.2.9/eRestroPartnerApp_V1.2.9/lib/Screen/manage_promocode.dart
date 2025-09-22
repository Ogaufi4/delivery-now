import 'dart:async';
import 'dart:convert';
import 'package:project/Helper/apiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import 'media.dart';
import 'package:intl/intl.dart';

class ManagePromocode extends StatefulWidget {
  final String? id,
      start,
      end,
      discountTypeValue,
      repeatUsageValue,
      statusValue,
      promoCodeValue,
      messageValue,
      noOfUsersValue,
      minimumOrderAmountValue,
      discountValue,
      maxDiscountAmountValue,
      noOfRepeatUsageValue,
      promoCodeImage,
      promocodeRelativePath;
  const ManagePromocode(
      {Key? key,
      this.id,
      this.start,
      this.end,
      this.discountTypeValue,
      this.repeatUsageValue,
      this.statusValue,
      this.promoCodeValue,
      this.messageValue,
      this.noOfUsersValue,
      this.minimumOrderAmountValue,
      this.discountValue,
      this.maxDiscountAmountValue,
      this.noOfRepeatUsageValue,
      this.promoCodeImage,
      this.promocodeRelativePath})
      : super(key: key);

  @override
  _ManagePromocodeState createState() => _ManagePromocodeState();
}

late String promocodeImage, promocodeImageUrl;

class _ManagePromocodeState extends State<ManagePromocode> with TickerProviderStateMixin {
//------------------------------------------------------------------------------
//========================= For Animation ======================================

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//------------------------------------------------------------------------------
//========================= InIt MEthod ========================================

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String? start, end;
  String? discountTypeValue;
  String? repeatUsageValue;
  String? statusValue;
  String? promoCodeValue;
  String? messageValue;
  String? noOfUsersValue;
  String? minimumOrderAmountValue;
  String? discountValue;
  String? maxDiscountAmountValue;
  String? noOfRepeatUsageValue;

  TextEditingController promocodeControlller = TextEditingController();
  TextEditingController messageControlller = TextEditingController();
  TextEditingController noOfUsersControlller = TextEditingController();
  TextEditingController minimumOrderAmountControlller = TextEditingController();
  TextEditingController discountControlller = TextEditingController();
  TextEditingController maxDiscountAmountControlller = TextEditingController();
  TextEditingController noOfrepeatUsageControlller = TextEditingController();

  FocusNode? promocodeFocus, messageFocus, noOfUsersFocus, minimumOrderAmountFocus, discountFocus, maxDiscountAmountFocus, noOfrepeatUsageFocus;

  bool _isNetworkAvail = true;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
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
    promocodeImage = '';
    promocodeImageUrl = '';
    print("widget.dat:${widget.id}");
    if (widget.id != null && widget.id != "") {
      start = widget.start;
      end = widget.end;
      discountTypeValue = widget.discountTypeValue;
      repeatUsageValue = (widget.repeatUsageValue == "Allowed") ? "1" : "0";
      statusValue = widget.statusValue;
      promoCodeValue = widget.promoCodeValue;
      messageValue = widget.messageValue;
      noOfUsersValue = widget.noOfUsersValue;
      minimumOrderAmountValue = widget.minimumOrderAmountValue;
      discountValue = widget.discountValue;
      maxDiscountAmountValue = widget.maxDiscountAmountValue;
      noOfRepeatUsageValue = widget.noOfRepeatUsageValue;
      promocodeControlller = TextEditingController(text: promoCodeValue);
      messageControlller = TextEditingController(text: messageValue);
      noOfUsersControlller = TextEditingController(text: noOfUsersValue);
      minimumOrderAmountControlller = TextEditingController(text: minimumOrderAmountValue);
      discountControlller = TextEditingController(text: discountValue);
      maxDiscountAmountControlller = TextEditingController(text: maxDiscountAmountValue);
      noOfrepeatUsageControlller = TextEditingController(text: noOfRepeatUsageValue);
      promocodeImageUrl = widget.promoCodeImage!;
      promocodeImage = widget.promocodeRelativePath!;
    }
    super.initState();
  }

  promocodeName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "promoCode")!} *"),
        promocodeField(),
      ],
    );
  }

  message() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "message")!} *"),
        messageField(),
      ],
    );
  }

  startDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "startDate")!} *"),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 5,
                right: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: lightBlack,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        start != null
                            ? Text(
                                start!,
                              )
                            : Text(
                                getTranslated(context, "startDate")!,
                              ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: primary,
                  )
                ],
              ),
            ),
            onTap: () {
              _startDate(context);
            },
          ),
        ),
      ],
    );
  }

  endDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "endDate")!} *"),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 5,
                right: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: lightBlack,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        end != null
                            ? Text(
                                end!,
                              )
                            : Text(
                                getTranslated(context, "endDate")!,
                              ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: primary,
                  )
                ],
              ),
            ),
            onTap: () {
              _endDate(context);
            },
          ),
        ),
      ],
    );
  }

  noOfUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "noOfUsers")!} *"),
        noOfUsersField(),
      ],
    );
  }

  minimumOrderAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "minimumOrderAmount")!} *"),
        minimumOrderAmountField(),
      ],
    );
  }

  discount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "discount")!} *"),
        discountField(),
      ],
    );
  }

  discountType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "discountType")!} *"),
        typeField("0"),
      ],
    );
  }

  dialog(String? type) async {
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
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, "select")!,
                          style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: fontColor),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: lightBlack),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              print("-----$type-----$repeatUsageValue-----$statusValue-----");
                              setState(
                                () {
                                  if (type == "0") {
                                    discountTypeValue = "percentage";
                                  } else if (type == "1") {
                                    repeatUsageValue = "1";
                                  } else {
                                    statusValue = "1";
                                  }
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      type == "0"
                                          ? getTranslated(context, "percentage")!
                                          : type == "1"
                                              ? getTranslated(context, "allow")!
                                              : getTranslated(context, "active")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              print("-----$type-----$repeatUsageValue-----$statusValue");
                              setState(
                                () {
                                  if (type == "0") {
                                    discountTypeValue = "amount";
                                  } else if (type == "1") {
                                    repeatUsageValue = "0";
                                  } else {
                                    statusValue = "0";
                                  }
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(type == "0"
                                        ? getTranslated(context, "amount")!
                                        : type == "1"
                                            ? getTranslated(context, "notAllow")!
                                            : getTranslated(context, "deActive")!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

  typeField(String? type) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: 5,
            right: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: lightBlack,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              type == "0"
                  ? Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          discountTypeValue != null
                              ? Text(
                                  discountTypeValue == 'percentage' ? getTranslated(context, "percentage")! : getTranslated(context, "amount")!,
                                )
                              : Text(
                                  getTranslated(context, "select")!,
                                ),
                        ],
                      ),
                    )
                  : type == "1"
                      ? Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              repeatUsageValue != null
                                  ? Text(
                                      repeatUsageValue == '1' ? getTranslated(context, "allow")! : getTranslated(context, "notAllow")!,
                                    )
                                  : Text(
                                      getTranslated(context, "select")!,
                                    ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              statusValue != null
                                  ? Text(
                                      statusValue == '1' ? getTranslated(context, "active")! : getTranslated(context, "deActive")!,
                                    )
                                  : Text(
                                      getTranslated(context, "select")!,
                                    ),
                            ],
                          ),
                        ),
              const Icon(
                Icons.arrow_drop_down,
                color: primary,
              )
            ],
          ),
        ),
        onTap: () {
          dialog(type == "0"
              ? "0"
              : type == "1"
                  ? "1"
                  : "2");
        },
      ),
    );
  }

  maxDiscountAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "maxDiscountAmount")!} *"),
        maxDiscountAmountField(),
      ],
    );
  }

  repeatUsage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "repeatUsage")!} *"),
        typeField("1"),
      ],
    );
  }

  status() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "status")!} *"),
        typeField("2"),
      ],
    );
  }

  noOfReapeatUsage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        titleText("${getTranslated(context, "noOfRepeatUsage")!}"),
        noOfRepeatUsageField(),
      ],
    );
  }

  titleText(String? title) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
        top: 15,
      ),
      child: Text(
        title!,
        style: const TextStyle(
          fontSize: 16,
          color: black,
        ),
      ),
    );
  }

  Future<void> _startDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(
        () {
          startDate = picked;
          start = DateFormat('yyyy-MM-dd').format(startDate);
        },
      );
    }
  }

  Future<void> _endDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(
        () {
          endDate = picked;
          end = DateFormat('yyyy-MM-dd').format(endDate);
        },
      );
    }
  }

  promocodeField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(promocodeFocus);
        },
        focusNode: promocodeFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: promocodeControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          promoCodeValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterPromocode")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  messageField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(messageFocus);
        },
        focusNode: messageFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: messageControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          messageValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterMessage")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  noOfUsersField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(noOfUsersFocus);
        },
        focusNode: noOfUsersFocus,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: noOfUsersControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          noOfUsersValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterNoOfUsers")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  minimumOrderAmountField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(minimumOrderAmountFocus);
        },
        focusNode: minimumOrderAmountFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: minimumOrderAmountControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          minimumOrderAmountValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterMinimumOrderAmount")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  discountField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(discountFocus);
        },
        focusNode: discountFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: discountControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          discountValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterDiscount")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  maxDiscountAmountField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(maxDiscountAmountFocus);
        },
        focusNode: maxDiscountAmountFocus,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: maxDiscountAmountControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          maxDiscountAmountValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterMaxDiscountAmount")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  noOfRepeatUsageField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(noOfrepeatUsageFocus);
        },
        focusNode: noOfrepeatUsageFocus,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: noOfrepeatUsageControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          noOfRepeatUsageValue = value;
        },
        validator: (val) => validateThisFieldRequered(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "enterNoOfRepeatUsage")!,
          hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
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

//------------------------------------------------------------------------------
//========================= Main Image =========================================

  mainImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Main Image * ")!,
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
                  builder: (context) => const Media(
                    from: "promocode",
                    type: "add",
                  ),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }

  selectedMainImageShow() {
    return promocodeImage == ''
        ? Container()
        : Image.network(
            promocodeImageUrl,
            width: 100,
            height: 100,
          );
  }

//------------------------------------------------------------------------------
//========================= Main Image =========================================

  videoUpload() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, "Video * ")!,
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
                  builder: (context) => const Media(
                    from: "video",
                    pos: 0,
                    type: "add",
                  ),
                ),
              ).then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }

  update() {
    setState(
      () {},
    );
  }


//=========================== Add Product Button ===============================

  resetProButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const ManagePromocode(),
              ),
            );
            setsnackbar(getTranslated(context, "Reset Successfully")!, context);
          },
          child: Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: lightBlack2,
            ),
            child: Center(
              child: Text(
                getTranslated(context, "Reset All")!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


//=========================== Add Product API Call =============================

  Future<void> addPromocodeAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", managePromocodeUrl);
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[resturantId] = CUR_USERID!;
        request.fields["promo_code"] = promoCodeValue!;
        request.fields["message"] = messageValue!;

        if (widget.id != null && widget.id != "") {
          request.fields["promocode_id"] = widget.id!;
        }
        request.fields["start_date"] = start!;
        request.fields["end_date"] = end!;
        request.fields["no_of_users"] = noOfUsersValue!;
        request.fields["minimum_order_amount"] = minimumOrderAmountValue!;
        request.fields["discount"] = discountValue!;
        request.fields["discount_type"] = discountTypeValue!;
        request.fields["max_discount_amount"] = maxDiscountAmountValue!;
        request.fields["repeat_usage"] = repeatUsageValue!;
        if (repeatUsageValue == "1") {
          request.fields["no_of_repeat_usage"] = noOfRepeatUsageValue!;
        }
        request.fields["status"] = statusValue!;
        if (promocodeImage != "") {
          request.fields["image"] = promocodeImage;
        }
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);

        bool error = getdata["error"];
        String msg = getdata['message'];
        print("response:${getdata}--${request.fields}");
        if (!error) {
          await buttonController!.reverse();
          setsnackbar(msg, context);
          Navigator.of(context).pop({"status": error});
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          await buttonController!.reverse();
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else if (mounted) {
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


//=========================== Body Part ========================================

  getBodyPart() {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            promocodeName(),
            message(),
            startDateField(),
            endDateField(),
            noOfUsers(),
            minimumOrderAmount(),
            discount(),
            discountType(),
            maxDiscountAmount(),
            repeatUsage(),
            status(),
            repeatUsageValue == "1" ? noOfReapeatUsage() : const SizedBox.shrink(),
            mainImage(),
            selectedMainImageShow(),
            AppBtn(
              title: (widget.id != null && widget.id != "") ? getTranslated(context, "updatePromocode")! : getTranslated(context, "addPromocode")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                validateAndSubmit();
              },
            ),
            resetProButton(),
            const SizedBox(
              width: 20,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      addPromocodeAPI();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (promoCodeValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseManagePromocode")!,
          context,
        );
        return false;
      } else if (messageValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseAddMessage")!,
          context,
        );
        return false;
      } else if (start == '') {
        setsnackbar(
          getTranslated(context, "pleaseAddStartDate")!,
          context,
        );
        return false;
      } else if (end == null) {
        setsnackbar(
          getTranslated(context, "pleaseAddEndDate")!,
          context,
        );
        return false;
      } else if (noOfUsersValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseAddNoOfUsers")!,
          context,
        );
        return false;
      } else if (minimumOrderAmountValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseAddMinimumOrderAmount")!,
          context,
        );
        return false;
      } else if (discountValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseAddDiscount")!,
          context,
        );
        return false;
      } else if (discountTypeValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseSelectDiscountType")!,
          context,
        );
        return false;
      } else if (repeatUsageValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseSelectRepeatUsage")!,
          context,
        );
        return false;
      } else if (statusValue == null) {
        setsnackbar(
          getTranslated(context, "pleaseSelectStatus")!,
          context,
        );
        return false;
      } else if (repeatUsageValue == "1") {
        if (noOfRepeatUsageValue == null) {
          setsnackbar(
            getTranslated(context, "pleaseAddNoOfRepeatUsage")!,
            context,
          );
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getAppBar(
        getTranslated(context, "promoCode")!,
        context,
      ),
      body: getBodyPart(),
    );
  }
}
