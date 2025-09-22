import 'package:project/Helper/String.dart';
import 'package:intl/intl.dart';

class Order_Model {
  String? id,
      name,
      mobile,
      latitude,
      longitude,
      delCharge,
      walBal,
      promo,
      promoDis,
      payMethod,
      total,
      subTotal,
      payable,
      address,
      taxAmt,
      taxPer,
      orderDate,
      dateTime,
      isCancleable,
      isReturnable,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      activeStatus,
      otp,
      riderId,
      invoice,
      delDate,
      delTime,
      cname,
      type,
      cdate,
      amount,
      cashReceived,
      message,
      balance,
      delTip;

  List<OrderItem>? itemList = [];
  List<String?>? listStatus = [];
  List<String?>? listDate = [];

  Order_Model(
      {this.id,
      this.name,
      this.mobile,
      this.delCharge,
      this.walBal,
      this.promo,
      this.promoDis,
      this.payMethod,
      this.total,
      this.subTotal,
      this.payable,
      this.address,
      this.taxPer,
      this.taxAmt,
      this.orderDate,
      this.dateTime,
      this.itemList,
      this.listStatus,
      this.listDate,
      this.isReturnable,
      this.isCancleable,
      this.isAlrCancelled,
      this.isAlrReturned,
      this.rtnReqSubmitted,
      this.activeStatus,
      this.otp,
      this.invoice,
      this.latitude,
      this.longitude,
      this.delDate,
      this.delTime,
      this.riderId,
      this.cname,
      this.type,
      this.cdate,
      this.amount,
      this.cashReceived,
      this.message,
      this.balance,
      this.delTip});

  factory Order_Model.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderItem> itemList = [];
    var order = parsedJson[ORDER_ITEMS] == null ? [] : parsedJson[ORDER_ITEMS] as List;
    if (order.isEmpty) {
      order = [];
    } else {
      itemList = order.map((data) => OrderItem.fromJson(data)).toList();
    }
    String date = parsedJson[DATE_ADDED] ?? "";

    date = date.isNotEmpty ? DateFormat('dd-MM-yyyy').format(DateTime.parse(date)) : date;
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allSttus = parsedJson[STATUS] ?? [];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }

    return Order_Model(
      id: parsedJson[ID] ?? "",
      name: parsedJson[USERNAME] ?? "",
      mobile: parsedJson[MOBILE] ?? "",
      delCharge: parsedJson[DEL_CHARGE] ?? "",
      walBal: parsedJson[WAL_BAL] ?? "",
      promo: parsedJson[PROMOCODE] ?? "",
      promoDis: parsedJson[PROMO_DIS] ?? "",
      payMethod: parsedJson[PAYMENT_METHOD] ?? "",
      total: parsedJson[FINAL_TOTAL] ?? "",
      subTotal: parsedJson[TOTAL] ?? "",
      payable: parsedJson[TOTAL_PAYABLE] ?? "",
      address: parsedJson[ADDRESS] ?? "",
      taxAmt: parsedJson[TOTAL_TAX_AMT] ?? "",
      taxPer: parsedJson[TOTAL_TAX_PER] ?? "",
      dateTime: parsedJson[DATE_ADDED] ?? "",
      isCancleable: parsedJson[ISCANCLEABLE] ?? "",
      isReturnable: parsedJson[ISRETURNABLE] ?? "",
      isAlrCancelled: parsedJson[ISALRCANCLE] ?? "",
      isAlrReturned: parsedJson[ISALRRETURN] ?? "",
      rtnReqSubmitted: parsedJson[ISRTNREQSUBMITTED] ?? "",
      orderDate: date,
      itemList: itemList,
      listStatus: lStatus,
      listDate: lDate,
      activeStatus: parsedJson[ACTIVE_STATUS] ?? "",
      otp: parsedJson[OTP] ?? "",
      latitude: parsedJson[LATITUDE] ?? "",
      longitude: parsedJson[LONGITUDE] ?? "",
      delDate: parsedJson[DEL_DATE] ?? "",
      delTime: parsedJson[DEL_TIME] != "" ? parsedJson[DEL_TIME] : '',
      riderId: parsedJson[RIDER_ID] ?? "",
      cname: parsedJson[NAME] ?? "",
      type: parsedJson[TYPE] ?? "",
      cdate: parsedJson[DATE_DEL] ?? "",
      amount: parsedJson[AMOUNT] ?? "",
      cashReceived: parsedJson[CASH_RECEIVED] ?? "",
      message: parsedJson[MESSAGE] ?? "",
      balance: parsedJson[RIDER_BALANCE] ?? "",
      delTip: parsedJson[DELIVERY_TIP] ?? "",
    );
  }
}

class OrderItem {
  String? id,
      name,
      qty,
      price,
      subTotal,
      status,
      image,
      varientId,
      isCancle,
      isReturn,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      varient_values,
      attr_name,
      productId,
      curSelected,
      delTip;
  List<Ad_ons>? addOns = [];
  List<String?>? listStatus = [];
  List<String?>? listDate = [];
  List<ParterDetails>? partDetails = [];

  OrderItem(
      {this.qty,
      this.id,
      this.name,
      this.price,
      this.subTotal,
      this.status,
      this.image,
      this.varientId,
      this.listDate,
      this.listStatus,
      this.isCancle,
      this.isReturn,
      this.isAlrReturned,
      this.isAlrCancelled,
      this.rtnReqSubmitted,
      this.attr_name,
      this.productId,
      this.varient_values,
      this.curSelected,
      this.partDetails,
      this.delTip,
      this.addOns});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String?> lStatus = [];
    List<String?> lDate = [];
    List<Ad_ons> itemList = [];
    if (json[STATUS] != null) {
      var allSttus = json[STATUS];
      for (var curStatus in allSttus) {
        lStatus.add(curStatus[0]);
        lDate.add(curStatus[1]);
      }
    }
    if (json['add_ons'] != null) {
      itemList = <Ad_ons>[];
      json['add_ons'].forEach((v) {
        itemList.add(Ad_ons.fromJson(v));
      });
    }

    List<ParterDetails> partDetails = [];
    var part = json[PART_DETAILS] == null ? [] : json[PART_DETAILS] as List;
    if (part.isEmpty) {
      part = [];
    } else {
      partDetails = part.map((data) => ParterDetails.fromJson(data)).toList();
    }

    return OrderItem(
      id: json[ID] ?? "",
      qty: json[QUANTITY] ?? "",
      name: json[NAME] ?? "",
      image: json[IMAGE] ?? "",
      price: json[PRICE] ?? "",
      subTotal: json[SUB_TOTAL] ?? "",
      varientId: json[PRODUCT_VARIENT_ID] ?? "",
      listStatus: lStatus,
      status: json[ACTIVE_STATUS],
      curSelected: json[ACTIVE_STATUS],
      listDate: lDate,
      isCancle: json[ISCANCLEABLE] ?? "",
      isReturn: json[ISRETURNABLE] ?? "",
      isAlrCancelled: json[ISALRCANCLE] ?? "",
      isAlrReturned: json[ISALRRETURN] ?? "",
      rtnReqSubmitted: json[ISRTNREQSUBMITTED] ?? "",
      attr_name: json[ATTR_NAME] ?? "",
      productId: json[PRODUCT_ID] ?? "",
      varient_values: json[VARIENT_VALUE] ?? "",
      partDetails: partDetails,
      delTip: json[DELIEVRY_TIP] ?? "",
      addOns: itemList,
    );
  }
}

class ParterDetails {
  String? par_id, par_name, ow_name, email, mobile, desc, latitude, longitude, address;

  ParterDetails({this.par_id, this.par_name, this.ow_name, this.email, this.mobile, this.desc, this.latitude, this.longitude, this.address});

  factory ParterDetails.fromJson(Map<String, dynamic> json) {
    return ParterDetails(
      par_id: json[PART_ID] ?? "",
      par_name: json[PART_NAME] ?? "",
      ow_name: json[OWN_NAME] ?? "",
      email: json[EMAIL] ?? "",
      mobile: json[MOBILE] ?? "",
      desc: json[DESC] ?? "",
      latitude: json[LATITUDE] ?? "",
      longitude: json[LONGITUDE] ?? "",
      address: json[PART_ADDRESS] ?? "",
    );
  }
}

class Ad_ons {
  String? title, price, calories, shortDescription, id, userId, productId, productVariantId, addOnId, qty, dateCreated, description, status;
  bool isSelected = false;
  Ad_ons({
    this.title,
    this.price,
    this.calories,
    this.shortDescription,
    this.id,
    this.userId,
    this.productId,
    this.productVariantId,
    this.addOnId,
    this.qty,
    this.dateCreated,
    this.description,
    this.status,
  });
  factory Ad_ons.fromJson(Map<String, dynamic> json) {
    return Ad_ons(
      title: json[TITLE],
      price: json[PRICE],
      calories: json[CALORIES],
      shortDescription: json[SHORTDESCRIPTION],
      id: json[ID],
      userId: json[USER_ID],
      productId: json[PRODUCT_ID],
      productVariantId: json[PRODUCT_VARIENT_ID],
      addOnId: json[ADD_ON_ID],
      qty: json[QTY],
      dateCreated: json[DATE_CREATED],
      description: json[DESC],
      status: json[STATUS],
    );
  }
}
