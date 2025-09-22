import '../../Helper/string.dart';

class Ad_ons {
  String? title,
      price,
      calories,
      shortDescription,
      id,
      userId,
      productId,
      productVariantId,
      addOnId,
      qty,
      dateCreated,
      description,
      status;
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
      title: json["title"],
      price: json["price"],
      calories: json["calories"],
      shortDescription: json["shortdescription"],
      id: json[Id],
      userId: json[UserId],
      productId: json[ProductId],
      productVariantId: json[ProductVariantId],
      addOnId: json["add_on_id"],
      qty: json["qty"],
      dateCreated: json[DateCreated],
      description: json["description"],
      status: json[Status],
    );
  }
}
