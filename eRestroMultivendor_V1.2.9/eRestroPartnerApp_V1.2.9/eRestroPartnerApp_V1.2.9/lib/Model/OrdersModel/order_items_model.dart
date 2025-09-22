import 'package:project/Model/Ad-Ons/ad_ons.dart';
import 'package:intl/intl.dart';

import '../../Helper/string.dart';

class OrderItem {
  String? id,
      userId,
      oRDERID,
      ResturantId,
      productName,
      variantName,
      productVariantId,
      qty,
      price,
      discountedPrice,
      taxAmount,
      discount,
      taxPercent,
      subTotal,
      dateAdded,
      productId,
      isCancle,
      isReturn,
      image,
      name,
      type,
      orderCounter,
      varaintIds,
      variantValues,
      attrName,
      imageSm,
      imageMd;
  List<Ad_ons>? addOns = [];
  List<String?>? listStatus = [];
  List<String?>? listDate = [];
  // List<Ad_ons>? addOns;

  OrderItem(
      {this.id,
      this.userId,
      this.oRDERID,
      this.ResturantId,
      this.productName,
      this.variantName,
      this.productVariantId,
      this.qty,
      this.price,
      this.addOns,
      this.discountedPrice,
      this.taxAmount,
      this.discount,
      this.subTotal,
      this.taxPercent,
      this.dateAdded,
      this.productId,
      this.isCancle,
      this.isReturn,
      this.image,
      this.name,
      this.type,
      this.orderCounter,
      this.varaintIds,
      this.variantValues,
      this.attrName,
      this.imageSm,
      this.imageMd});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    //List<String?> lStatus = [];
    //List<String?> lDate = [];
    String date = json[DateAdded];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    List<Ad_ons> itemList = [];
    // var order = (json["add_ons"] as List?);

    // itemList = order!.map((data) => Ad_ons.fromJson(data)).toList();

    if (json['add_ons'] != null) {
      itemList = <Ad_ons>[];
      json['add_ons'].forEach((v) {
        itemList.add(Ad_ons.fromJson(v));
      });
    }

    return OrderItem(
      id: json[Id],
      userId: json[UserId],
      oRDERID: json[ORDERID],
      ResturantId: json[resturantId],
      productName: json[ProductName],
      variantName: json[VariantName],
      productVariantId: json[ProductVariantId],
      qty: json[Quantity],
      price: json[Price],
      discountedPrice: json[DiscountedPrice],
      taxPercent: json["tax_percent"],
      taxAmount: json[TaxAmount],
      discount: json[Discount],
      subTotal: json[SubTotal],
      dateAdded: date,
      productId: json[ProductId],
      isCancle: json[IsCancelable],
      isReturn: json[IsReturnable],
      image: json[IMage],
      name: json[Name],
      type: json[Type],
      orderCounter: json[OrderCounter],
      varaintIds: json[VaraintIds],
      variantValues: json[VariantValues],
      attrName: json[AttrName],
      imageSm: json[ImageSm],
      imageMd: json[ImageMd],
      addOns: itemList,
    );
  }
}
