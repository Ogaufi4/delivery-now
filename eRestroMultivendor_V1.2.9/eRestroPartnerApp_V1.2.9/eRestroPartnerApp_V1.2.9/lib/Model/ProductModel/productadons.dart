class ProductAdons {
  String? productId, title, description, price, calories;

  ProductAdons({
    this.productId,
    this.title,
    this.description,
    this.price,
    this.calories,
  });

  factory ProductAdons.fromJson(Map<String, dynamic> json) {
    return ProductAdons(
      productId: json["product_id"],
      title: json["title"],
      description: json["description"],
      price: json["price"],
      calories: json["calories"],
    );
  }
}
