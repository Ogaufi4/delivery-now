import 'package:project/Model/ProductModel/productadons.dart';

import '../../Helper/string.dart';

import 'attribute.dart';
import 'filter_model.dart';
import 'variants.dart';

class Product {
  String? id,
      name,
      image,
      catName,
      availableTime,
      startTime,
      endTime,
      type,
      restaurantrating,
      restaurantNoOfRating,
      attrIds,
      tax,
      relativePath,
      taxId,
      calories,
      categoryId,
      invoiceHtml,
      shortDescription,
      status,
      stock;
  List<String>? highlights;
  List<Product_Varient>? prVarientList;
  List<ProductAdons>? prAdons;
  List<Attribute>? attributeList;
  List<String>? selectedId = [];
  List<String>? tagList = [];
  String? isFav,
      isCancelable,
      isPurchased,
      taxincludedInPrice,
      isCODAllow,
      availability,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      totalAllow,
      minimumOrderQuantity,
      quantityStepSize,
      cancelableTill,
      isSpicy;

  bool? isFavLoading = false, isFromProd = false;
  int? offset, totalItem, selVarient;

  List<Product>? subList;
  List<Filter>? filterList;

  Product(
      {this.id,
      this.name,
      this.image,
      this.catName,
      this.availableTime,
      this.startTime,
      this.endTime,
      this.type,
      this.prVarientList,
      this.prAdons,
      this.relativePath,
      this.attributeList,
      this.isFav,
      this.status,
      this.isCancelable,
      this.highlights,
      this.invoiceHtml,
      this.isCODAllow,
      this.isPurchased,
      this.availability,
      this.restaurantNoOfRating,
      this.attrIds,
      this.selectedId,
      this.restaurantrating,
      this.isFavLoading,
      this.indicator,
      this.tax,
      this.taxId,
      this.shortDescription,
      this.total,
      this.categoryId,
      this.subList,
      this.filterList,
      this.stockType,
      this.isFromProd,
      this.cancleTill,
      this.totalItem,
      this.offset,
      this.totalAllow,
      this.minimumOrderQuantity,
      this.quantityStepSize,
      this.banner,
      this.selVarient,
      this.calories,
      this.tagList,
      this.taxincludedInPrice,
      this.stock,
      this.cancelableTill,
      this.isSpicy});

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[Variants] as List)
        .map((data) => Product_Varient.fromJson(data))
        .toList();
    List<ProductAdons> adonsList = (json["product_add_ons"] as List)
        .map((data) => ProductAdons.fromJson(data))
        .toList();

    List<Attribute> attList = (json[Attributes] as List)
        .map((data) => Attribute.fromJson(data))
        .toList();

    var flist = (json[FILTERS] as List?);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty) {
      filterList = [];
    } else {
      filterList = flist.map((data) => Filter.fromJson(data)).toList();
    }

    List<String> selected = [];
    List<String> highLights = List<String>.from(json["highlights"]);

    return Product(
        id: json[Id],
        name: json[Name],
        image: json[IMage],
        catName: json[CategoryName],
        availableTime: json["available_time"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        restaurantrating: json[restaurantRating],
        restaurantNoOfRating: json["no_of_ratings"],
        stock: json[Stock],
        type: json[Type],
        isFav: json[IsFavorite].toString(),
        isCancelable: json[IsCancelable],
        availability: json[Availability].toString(),
        isPurchased: json[IsPurchased].toString(),
        prVarientList: varientList,
        prAdons: adonsList,
        attributeList: attList,
        filterList: filterList,
        isFavLoading: false,
        selVarient: 0,
        invoiceHtml: json["invoice_html"],
        attrIds: json[AttrValueIds],
        indicator: json[Indicator].toString(),
        stockType: json[StockType].toString(),
        tax: json[TaxPercentage],
        total: json[Total],
        categoryId: json["category_id"],
        status: json["status"],
        selectedId: selected,
        totalAllow: json[TotalAllowedQuantity],
        cancleTill: json[CancelableTill],
        shortDescription: json[ShortDescription],
        minimumOrderQuantity: json[MinimumOrderQuantity],
        quantityStepSize: json[QuantityStepSize],
        isCODAllow: json[codAllowed],
        taxincludedInPrice: json[IsPricesInclusiveTax],
        taxId: json[TaxId],
        calories: json["calories"],
        relativePath: json["relative_path"],
        highlights: highLights,
        cancelableTill: json[CancelableTill],
        isSpicy: json[IsSpicy]);
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    return Product(
      id: parsedJson[Id],
      name: parsedJson[Name],
      image: parsedJson[Images],
      banner: parsedJson[BANNER],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      tax: parsedJson[TAX],
      subList: createSubList(parsedJson["children"]),
    );
  }

  static List<Product>? createSubList(List? parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => Product.fromCat(data)).toList();
  }
}
