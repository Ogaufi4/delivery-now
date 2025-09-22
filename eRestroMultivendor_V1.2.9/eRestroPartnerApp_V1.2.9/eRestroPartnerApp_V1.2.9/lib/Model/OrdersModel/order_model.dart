import 'package:intl/intl.dart';
import '../../Helper/string.dart';
import 'order_items_model.dart';

class Order_Model {
  String? id,
      userId,
      riderId,
      addressId,
      delCharge,
      mobile,
      isDeliveryChargeReturnable,
      walBal,
      payable,
      isCredited,
      promo,
      promoDis,
      discount,
      total,
      payMethod,
      latitude,
      longitude,
      address,
      delTime,
      delDate,
      dateTime,
      otp,
      notes,
      deliveryTip,
      countryCode,
      name,
      riderMobile,
      riderName,
      riderImage,
      riderRating,
      riderNoOfRatings,
      totalTaxPercent,
      totalTaxAmount,
      invoiceHtml,
      thermalInvoiceHtml,
      activeStatus,
      orderDate,
      subTotal,isSelfPickUp;
  List<OrderItem>? itemList;
  List<String?>? listStatus = [];
  List<String?>? listDate = [];

  Order_Model(
      {this.id,
      this.userId,
      this.riderId,
      this.addressId,
      this.delCharge,
      this.mobile,
      this.isDeliveryChargeReturnable,
      this.walBal,
      this.payable,
      this.promo,
      this.promoDis,
      this.discount,
      this.total,
      this.isCredited,
      this.payMethod,
      this.latitude,
      this.longitude,
      this.address,
      this.delTime,
      this.delDate,
      this.dateTime,
      this.otp,
      this.notes,
      this.deliveryTip,
      this.countryCode,
      this.name,
      this.riderMobile,
      this.riderName,
      this.riderImage,
      this.riderRating,
      this.riderNoOfRatings,
      this.totalTaxPercent,
      this.totalTaxAmount,
      this.invoiceHtml,
      this.thermalInvoiceHtml,
      this.subTotal,
      this.itemList,
      this.listStatus,
      this.listDate,
      this.activeStatus,
      this.orderDate,
      this.isSelfPickUp});

  factory Order_Model.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderItem> itemList = [];
    var order = (parsedJson[OrderItemss] as List?);

    itemList = order!.map((data) => OrderItem.fromJson(data)).toList();
    String date = parsedJson[DateAdded];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));

    List<String?> lStatus = [];

    return Order_Model(
      id: parsedJson[Id],
      userId: parsedJson[UserId],
      riderId: parsedJson[RiderId],
      addressId: parsedJson[AddressId],
      delCharge: parsedJson[DeliveryCharge],
      isCredited: parsedJson[IsCredited],
      mobile: parsedJson[Mobile],
      isDeliveryChargeReturnable: parsedJson[IsDeliveryChargeReturnable],
      walBal: parsedJson[WalletBalance],
      payable: parsedJson[TotalPayable],
      promo: parsedJson[PromoCode],
      promoDis: parsedJson[PromoDiscount],
      discount: parsedJson[Discount],
      total: parsedJson[FinalTotal],
      payMethod: parsedJson[PaymentMethod],
      latitude: parsedJson[Latitude],
      longitude: parsedJson[Longitude],
      address: parsedJson[Address],
      delTime: parsedJson[DeliveryTime] != "" ? parsedJson[DeliveryTime] : '',
      delDate: parsedJson[DeliveryDate] != ""
          ? DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(parsedJson[DeliveryDate]))
          : '',
      dateTime: parsedJson[DateAdded],
      otp: parsedJson[Otp],
      notes: parsedJson[Notes],
      deliveryTip: parsedJson[DeliveryTip],
      countryCode: parsedJson[COUNTRY_CODE],
      name: parsedJson[Username],
      riderMobile: parsedJson[RiderMobile],
      riderName: parsedJson[RiderName],
      riderImage: parsedJson[RiderImage],
      riderRating: parsedJson[RiderRating],
      riderNoOfRatings: parsedJson[RiderNoOfRatings],
      totalTaxPercent: parsedJson[TotalTaxPercent],
      totalTaxAmount: parsedJson[TotalTaxAmount],
      invoiceHtml: parsedJson[InvoiceHtml],
      thermalInvoiceHtml: parsedJson[ThermalInvoiceHtml],
      subTotal: parsedJson[Total],
      activeStatus: parsedJson[ActiveStatus],
      orderDate: date,
      itemList: itemList,
      listStatus: lStatus,
      isSelfPickUp: parsedJson['is_self_pick_up']
    );
  }
}
