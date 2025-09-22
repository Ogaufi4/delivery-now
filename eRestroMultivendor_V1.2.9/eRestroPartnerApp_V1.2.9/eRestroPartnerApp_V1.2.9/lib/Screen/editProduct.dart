import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/home.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sticky_headers/sticky_headers.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/sim_btn.dart';
import '../Helper/string.dart';
import '../Model/Attribute Models/AttributeModel/attributes_model.dart';
import '../Model/Attribute Models/AttributeSetModel/attribute_set_model.dart';
import '../Model/Attribute Models/AttributeValueModel/attribute_value.dart';
import '../Model/CategoryModel/category_model.dart';
import '../Model/ProductModel/product.dart';
import '../Model/ProductModel/variants.dart';
import '../Model/Tags/tags.dart';
import '../Model/TaxesModel/taxesmodel.dart';
import 'Widgets/FilterChips.dart';
import 'media.dart';

// ignore: must_be_immutable
class EditProduct extends StatefulWidget {
  Product? model;

  EditProduct({
    Key? key,
    this.model,
  }) : super(key: key);
  @override
  _EditProductState createState() => _EditProductState();
}

late String productImageRelativePath, productImage, productImageUrl;
List<Product_Varient> variationList = [];

class _EditProductState extends State<EditProduct> with TickerProviderStateMixin {
//======================= Variable Declaration =================================

// temprary variable for test
  late Map<String, List<AttributeValueModel>> selectedAttributeValues = {};
//Variable For UI ...

  // for UI
  String? selectedCatName; // for UI
  int? selectedTaxID; // for UI
  var mainImageProductImage;

// for Table UI
  List<String> adtitle = [];
  List<String> adprice = [];
  List<String> adshortdesc = [];
  List<String> adcalories = [];
  bool tableflag = false;
//on-off toggles
  bool isToggled = false;
  bool isCODallow = false;
  bool isProducttime = false;
  bool iscancelable = false;
  bool taxincludedInPrice = false;
  bool isSpicy = false;

  String? addOnPrice;
  String? addOnTitle;
  String? addOnCalorie;
  String? addOnShortDescription;
//for remove extra add
  int attributeIndiacator = 0;

// network variable
  bool _isNetworkAvail = true;
  bool _isLoading = true;
  String? data;
  bool suggessionisNoData = false;

//============================= Parameter For API Call=============================

  String? oldVariantId = "";
  String? caloriestext;
  String? productName; //pro_input_name
  String? sortDescription; // short_description
  String? tags; // Tags
  String? highLights; //
  String? taxId; // Tax (pro_input_tax)
  String? taxName;
  String? indicatorValue; // indicator
  String? totalAllowQuantity; // total_allowed_quantity
  String? minOrderQuantity; // minimum_order_quantity
  String? quantityStepSize; // quantity_step_size
  String? taxincludedinPrice = "0"; //is_prices_inclusive_tax
  String? isCODAllow = "0"; //cod_allowed
  String? isProductTime = "0"; //availableTime
  String? isCancelable = "0"; //is_cancelable
  String? tillwhichstatus; //cancelable_till
  String? selectedTypeOfVideo; // video_type
  String? selectedCatID; //category_id
  //attribute_values
  String? productType; //product_type
  String? variantStockLevelType = "product_level"; //variant_stock_level_type // defualt is product level  if not pass
  int curSelPos = 0;
  String? isSpicyValue = "0"; //is_spicy

// for simple product   if(product_type == simple_product)

  String? simpleproductStockStatus = "1"; //simple_product_stock_status
  String? simpleproductPrice; //simple_price
  String? simpleproductSpecialPrice; //simple_special_price
  String? simpleproductTotalStock; // product_total_stock
  String? variantStockStatus = "0"; //variant_stock_status //fix according to riddhi mam =0 for simple product // not give any option for selection

// for variable product
  List<List<AttributeValueModel>> finalAttList = [];
  List<List<AttributeValueModel>> tempAttList = [];
  String? variantsIds; //variants_ids
  String? variantPrice; // variant_price
  String? variantSpecialPrice; // variant_special_price
  String? variantImages; // variant_images

  //{if (variant_stock_level_type == product_level)}
  String? variantproductSKU; //sku_variant_type
  String? variantproductTotalStock; // total_stock_variant_type
  String stockStatus = '1'; // variant_status

  //{if(variant_stock_level_type == variable_level)}
  String? variantSku; // variant_sku
  String? variantTotalStock; // variant_total_stock
  String? variantLevelStockStatus; //variant_level_stock_status
  bool? _isStockSelected;

  //  other
  bool simpleProductSaveSettings = false;
  bool variantProductProductLevelSaveSettings = false;
  bool variantProductVariableLevelSaveSettings = false;
  late StateSetter taxesState;

  // getting data
  List<TaxesModel> taxesList = [];
  List<AttributeSetModel> attributeSetList = [];
  List<AttributeModel> attributesList = [];

  List<AttributeValueModel> attributesValueList = [];

  List<CategoryModel> catagorylist = [];
  final List<TextEditingController> _attrController = [];
  List<bool> variationBoolList = [];
  List<int> attrId = [];
  List<int> attrValId = [];
  List<String> attrVal = [];
  List<TagsModel> tagsList = [];
  List<TagsModel> productTags = [];
  List<TagsModel> productTagsList = [];
  List<String> finalTagsList = [];
  List<Map<String, dynamic>> addOns = [];
  TimeOfDay startTime = const TimeOfDay(hour: 09, minute: 00);
  TimeOfDay endTime = const TimeOfDay(hour: 09, minute: 00);

  //======================= TextEditingController ==============================

  TextEditingController caloriesController = TextEditingController();
  TextEditingController productNameControlller = TextEditingController();
  TextEditingController sortDescriptionControlller = TextEditingController();
  TextEditingController tagsControlller = TextEditingController();
  TextEditingController totalAllowController = TextEditingController();
  TextEditingController highLightController = TextEditingController();
  TextEditingController minOrderQuantityControlller = TextEditingController();
  TextEditingController quantityStepSizeControlller = TextEditingController();
  TextEditingController simpleProductPriceController = TextEditingController();
  TextEditingController simpleProductSpecialPriceController = TextEditingController();
  TextEditingController simpleProductTotalStock = TextEditingController();
  TextEditingController variountProductTotalStock = TextEditingController();
  TextEditingController addOnPriceController = TextEditingController();
  TextEditingController addOnTitleController = TextEditingController();
  TextEditingController addOnDescriptionController = TextEditingController();
  TextEditingController addOnCalorieController = TextEditingController();

  //=================================== FocusNode ==============================
  late int row = 1, col;
  FocusNode? productFocus,
      sortDescriptionFocus,
      tagFocus,
      totalAllowFocus,
      minOrderFocus,
      highlightFocus,
      quantityStepSizeFocus,
      caloriesFocus,
      simpleProductPriceFocus,
      simpleProductSpecialPriceFocus,
      simpleProductTotalStockFocus,
      variountProductTotalStockFocus,
      rawKeyboardListenerFocus,
      tempFocusNode,
      attributeFocus,
      addOnPriceFocus,
      addOnTitleFocus,
      addOnCaloriesFocus,
      addOnShortDescriptionFocus = FocusNode();

//========================= For Form Validation ================================

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

//======================= Delete this  ================================

  List<String> selectedAttribute = [];

  List<String> suggestedAttribute = [];

//========================= For Animation ======================================

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

//========================= InIt MEthod ========================================
  List<String> resultAttr = [];
  List<String> resultID = [];
  late int max;
  final ValueNotifier<double?> optionsViewWidthNotifier = ValueNotifier(null);

  @override
  void initState() {
    print(widget.model);
    productImage = "";
    productImageUrl = "";
    productImageRelativePath = "";

    getCategories();
    getCurrentProductTags();
    getTax();
    getAttributesValue();
    getAttributes();
    allgetTags();
    Future.delayed(
      const Duration(seconds: 2),
      () {
        initializaAllvariables();
      },
    );
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
    super.initState();
  }

  Future<void> getCategories() async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      SellerId: CUR_USERID,
    };
    apiBaseHelper.postAPICall(getCategoriesApi, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          catagorylist.clear();
          var data = getdata["data"];
          catagorylist = (data as List).map((data) => CategoryModel.fromJson(data)).toList();
        } else {
          setsnackbar(msg!, context);
        }
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
  }

  void initializaAllvariables() {
    // pro_input_name

    productNameControlller.text = widget.model!.name!;
    productName = productNameControlller.text;
    // short_description
    (widget.model!.shortDescription == null) ? "" : sortDescriptionControlller.text = widget.model!.shortDescription!;
    sortDescription = sortDescriptionControlller.text;

    // product_category_id
    selectedCatName = widget.model!.catName;
    selectedCatID = widget.model!.categoryId;

    //total allowed quantity
    if (widget.model!.totalAllow != null) {
      totalAllowQuantity = widget.model!.totalAllow;
      totalAllowController.text = widget.model!.totalAllow!;
    }

    // Minimum Order Quantity
    if (widget.model!.minimumOrderQuantity != null) {
      minOrderQuantity = widget.model!.minimumOrderQuantity;
      minOrderQuantityControlller.text = widget.model!.minimumOrderQuantity!;
    }
    if (widget.model!.minimumOrderQuantity == null) {
      minOrderQuantity = "1";
      minOrderQuantityControlller.text = "1";
    }

    if (widget.model!.availableTime != null) {
      isProducttime = widget.model!.availableTime == "1" ? true : false;
      isProductTime = widget.model!.availableTime;
      startTime = TimeOfDay(hour: int.parse(widget.model!.startTime!.substring(0, 2)), minute: int.parse(widget.model!.startTime!.substring(3, 5)));
      endTime = TimeOfDay(hour: int.parse(widget.model!.endTime!.substring(0, 2)), minute: int.parse(widget.model!.endTime!.substring(3, 5)));
    }

    //is_cancelable
    if (widget.model!.isCancelable != null) {
      isCancelable = widget.model!.isCancelable;
      iscancelable = widget.model!.isCancelable == "1" ? true : false;
      if (iscancelable) {
        if (widget.model!.cancelableTill != "" && widget.model!.cancelableTill != null) {
          tillwhichstatus = widget.model!.cancelableTill;
        }
      }
    }
    //cod_allowed
    if (widget.model!.isCODAllow != null) {
      isCODAllow = widget.model!.isCODAllow;
      isCODallow = widget.model!.isCODAllow == "1" ? true : false;
    }
    //is_spicy
    if (widget.model!.isSpicy != null) {
      isSpicyValue = widget.model!.isSpicy;
      isSpicy = widget.model!.isSpicy == "1" ? true : false;
    }
    //taxincludedinPrice
    if (widget.model!.taxincludedInPrice != null) {
      taxincludedinPrice = widget.model!.taxincludedInPrice;
      taxincludedInPrice = widget.model!.taxincludedInPrice == "1" ? true : false;
    }
    // indicator
    if (widget.model!.indicator != null) {
      indicatorValue = widget.model!.indicator;
    }
    //Image
    if (widget.model!.image != null && widget.model!.image != "") {
      productImage = widget.model!.image!;
      productImageUrl = widget.model!.image!;
      productImageRelativePath = widget.model!.relativePath!;
    }
    //tax_id
    if (widget.model!.taxId != null) {
      taxId = widget.model!.taxId;
      selectedTaxID = int.parse(widget.model!.taxId!);
    }

    // Type Of Product
    if (widget.model!.type != null) {
      productType = widget.model!.type;
    }
    // calories
    if (widget.model!.calories != "" && widget.model!.calories != null) {
      caloriestext = widget.model!.calories;
      caloriesController.text = widget.model!.calories!;
    }

    //highLights
    if (widget.model!.highlights != null) {
      if (widget.model!.highlights!.isNotEmpty) {
        highLights = widget.model!.highlights!.join(",");
        highLightController.text = widget.model!.highlights!.join(",");
      }
    }

//========================= Add-Ons Product =====================================
    if (widget.model!.prAdons != null) {
      for (int i = 0; i < widget.model!.prAdons!.length; i++) {
        String? temptTitle = widget.model!.prAdons![i].title;
        String? tempShortDescription = widget.model!.prAdons![i].description;
        String? tempPrice = widget.model!.prAdons![i].price;
        String? tempCalorie = widget.model!.prAdons![i].calories;
        Map<String, dynamic> singleAddon = {
          "title": temptTitle,
          "description": tempShortDescription,
          "price": tempPrice,
          "calories": tempCalorie,
          "status": "1"
        };
        addOns.add(singleAddon);
        adtitle.add(temptTitle ?? "");
        adprice.add(tempPrice ?? "");
        adshortdesc.add(tempShortDescription ?? "");
        adcalories.add(tempCalorie ?? "");
      }
      tableflag = true;
    }

//========================= Simple Product =====================================

    if (productType == "simple_product") {
      if (widget.model!.stock != null) {
        simpleproductTotalStock = widget.model!.stock;
        simpleProductTotalStock.text = widget.model!.stock!;
      }
      // simple product price
      if (widget.model!.prVarientList![widget.model!.selVarient!].price != null) {
        simpleProductPriceController.text = widget.model!.prVarientList![widget.model!.selVarient!].price!;
        simpleproductPrice = widget.model!.prVarientList![widget.model!.selVarient!].price!;
      }
      // simple product special price
      if (widget.model!.prVarientList![widget.model!.selVarient!].disPrice != null) {
        simpleProductSpecialPriceController.text = widget.model!.prVarientList![widget.model!.selVarient!].disPrice!;
        simpleproductSpecialPrice = widget.model!.prVarientList![widget.model!.selVarient!].disPrice!;
      }
      //Enable Stock Management
      if (widget.model!.prVarientList![widget.model!.selVarient!].sku != null &&
          widget.model!.prVarientList![widget.model!.selVarient!].stock != null &&
          widget.model!.prVarientList![widget.model!.selVarient!].stockType != null) {
        _isStockSelected = true;
      }

      // simple Product In Stock Status
      if (widget.model!.prVarientList![widget.model!.selVarient!].stockType != null) {
        simpleproductStockStatus = widget.model!.prVarientList![widget.model!.selVarient!].stockType;
      }
      // for save setting
      simpleProductSaveSettings = true;
      // for variant

      if (widget.model!.attributeList!.isEmpty.toString() == "false") {
        var index = widget.model!.attributeList!.length;
        for (int i = 0; i < index; i++) {
          var oldListOfAttributeValueID = widget.model!.attributeList![i].id.toString().split(',');
          //old variant id
          oldVariantId = () {
            if (oldVariantId == "") {
              return widget.model!.attributeList![i].id;
            } else {
              return "${oldVariantId!},${widget.model!.attributeList![i].id!}";
            }
          }();
          String? oldattributename = widget.model!.attributeList![i].name;
          _attrController.add(TextEditingController(text: oldattributename));
          variationBoolList.add(true);
          // for get the value of element
          final attributes = attributesList.where((element) => element.name == oldattributename).toList();
          String? attributeID;
          for (var element in attributes) {
            attributeID = element.id;
          }
          List<AttributeValueModel> tempagain = [];
          for (var element in oldListOfAttributeValueID) {
            final tempvar = attributesValueList.where((e) => e.id == element).toList();
            if (tempvar.isNotEmpty) {
              tempagain.add(
                tempvar[0],
              );
            }
          }
          if (attributeID != null) {
            selectedAttributeValues[attributeID] = tempagain;
          }
        }

        attributeIndiacator = _attrController.length;
      }
    }

    //========================= Variant Product ==================================

    if (productType == "variable_product") {
      List<String> colCount = [];
      // logic for stock is enable or not .
      if (widget.model!.stockType == "null") {
        // product level but stock management dissable
        //complete
        _isStockSelected = false;
      }
      if (widget.model!.stockType == "") {
        variantProductProductLevelSaveSettings = true;
        _isStockSelected = false;
        // For variant
        if (widget.model!.attributeList!.isEmpty.toString() == "false") {
          var index = widget.model!.attributeList!.length;
          for (int i = 0; i < index; i++) {
            var oldListOfAttributeValueID = widget.model!.attributeList![i].id.toString().split(',');
            //old variant id
            oldVariantId = () {
              if (oldVariantId == "") {
                return widget.model!.attributeList![i].id;
              } else {
                return "${oldVariantId!},${widget.model!.attributeList![i].id!}";
              }
            }();
            String? oldattributename = widget.model!.attributeList![i].name;
            _attrController.add(TextEditingController(text: oldattributename));
            variationBoolList.add(true);
            // for get the value of element
            final attributes = attributesList.where((element) => element.name == oldattributename).toList();
            String? attributeID;
            for (var element in attributes) {
              attributeID = element.id;
            }
            List<AttributeValueModel> tempagain = [];
            for (var element in oldListOfAttributeValueID) {
              final tempvar = attributesValueList.where((e) => e.id == element).toList();
              if (tempvar.isNotEmpty) {
                tempagain.add(tempvar[0]);
              }
            }
            if (attributeID != null) {
              selectedAttributeValues[attributeID] = tempagain;
            }
          }
          attributeIndiacator = _attrController.length;
          if (widget.model!.prVarientList!.isEmpty.toString() == "false") {
            var index = widget.model!.prVarientList!.length;
            for (int i = 0; i < index; i++) {
              //old variant id
              oldVariantId = () {
                if (oldVariantId == "") {
                  return widget.model!.prVarientList![i].id;
                } else {
                  return "${oldVariantId!},${widget.model!.prVarientList![i].id!}";
                }
              }();
            }
          }
        }
        for (int i = 0; i < widget.model!.prVarientList!.length; i++) {
          variationList.add(widget.model!.prVarientList![i]);
          colCount = variationList[i].attr_name!.split(',');
        }
        col = colCount.length;
        row = widget.model!.prVarientList!.length;
      }
      if (widget.model!.stockType == "1") {
        // enable and product level
        // paniding
        _isStockSelected = true;
        variantStockLevelType = 'product_level';
        variantProductProductLevelSaveSettings = true;

        if (widget.model!.prVarientList![0].stock != "") {
          variountProductTotalStock.text = widget.model!.prVarientList![0].stock!;
          variantproductTotalStock = widget.model!.prVarientList![0].stock!;
        }
        if (widget.model!.stockType != "") {
          stockStatus = widget.model!.stockType!;
        }
        // For variant =========================================================

        if (widget.model!.attributeList!.isEmpty.toString() == "false") {
          var index = widget.model!.attributeList!.length;
          for (int i = 0; i < index; i++) {
            var oldListOfAttributeValueID = widget.model!.attributeList![i].id.toString().split(',');
            //old variant id
            oldVariantId = () {
              if (oldVariantId == "") {
                return widget.model!.attributeList![i].id;
              } else {
                return "${oldVariantId!},${widget.model!.attributeList![i].id!}";
              }
            }();
            String? oldattributename = widget.model!.attributeList![i].name;
            _attrController.add(TextEditingController(text: oldattributename));
            variationBoolList.add(true);
            // for get the value of element
            final attributes = attributesList.where((element) => element.name == oldattributename).toList();
            String? attributeID;
            for (var element in attributes) {
              attributeID = element.id;
            }
            List<AttributeValueModel> tempagain = [];
            for (var element in oldListOfAttributeValueID) {
              final tempvar = attributesValueList.where((e) => e.id == element).toList();
              if (tempvar.isNotEmpty) {
                tempagain.add(tempvar[0]);
              }
            }
            if (attributeID != null) {
              selectedAttributeValues[attributeID] = tempagain;
            }
          }
          attributeIndiacator = _attrController.length;
          if (widget.model!.prVarientList!.isEmpty.toString() == "false") {
            var index = widget.model!.prVarientList!.length;
            for (int i = 0; i < index; i++) {
              //old variant id
              oldVariantId = () {
                if (oldVariantId == "") {
                  return widget.model!.prVarientList![i].id;
                } else {
                  return "${oldVariantId!},${widget.model!.prVarientList![i].id!}";
                }
              }();
            }
          }
        }
        variationList.clear();
        for (int i = 0; i < widget.model!.prVarientList!.length; i++) {
          variationList.add(widget.model!.prVarientList![i]);
          colCount = variationList[i].attr_name!.split(',');
        }

        col = colCount.length;
        row = widget.model!.prVarientList!.length;
      }
      if (widget.model!.stockType == "2") {
        // enable and variable level
        // complete
        _isStockSelected = true;
        variantStockLevelType = 'variable_level';
        variantProductVariableLevelSaveSettings = true;

        // For Atttribute Value

        if (widget.model!.attributeList!.isEmpty.toString() == "false") {
          var index = widget.model!.attributeList!.length;
          for (int i = 0; i < index; i++) {
            var oldListOfAttributeValueID = widget.model!.attributeList![i].id.toString().split(',');
            //old variant id
            oldVariantId = () {
              if (oldVariantId == "") {
                return widget.model!.attributeList![i].id;
              } else {
                return "${oldVariantId!},${widget.model!.attributeList![i].id!}";
              }
            }();
            String? oldattributename = widget.model!.attributeList![i].name;
            _attrController.add(TextEditingController(text: oldattributename));
            variationBoolList.add(true);
            // for get the value of element
            final attributes = attributesList.where((element) => element.name == oldattributename).toList();
            String? attributeID;
            for (var element in attributes) {
              attributeID = element.id;
            }
            List<AttributeValueModel> tempagain = [];
            for (var element in oldListOfAttributeValueID) {
              List<AttributeValueModel> tempvar = attributesValueList.where((e) => e.id == element).toList();
              if (tempvar.isNotEmpty) {
                tempagain.add(tempvar[0]);
              }
            }
            if (attributeID != null) {
              selectedAttributeValues[attributeID] = tempagain;
            }
          }
          attributeIndiacator = _attrController.length;
          if (widget.model!.prVarientList!.isEmpty.toString() == "false") {
            var index = widget.model!.prVarientList!.length;
            for (int i = 0; i < index; i++) {
              //old variant id
              oldVariantId = () {
                if (oldVariantId == "") {
                  return widget.model!.prVarientList![i].id;
                } else {
                  return "${oldVariantId!},${widget.model!.prVarientList![i].id!}";
                }
              }();
            }
          }
        }
        variationList.clear();
        for (int i = 0; i < widget.model!.prVarientList!.length; i++) {
          variationList.add(widget.model!.prVarientList![i]);
          colCount = variationList[i].attr_name!.split(',');
        }

        int i = 0;
        // ignore: unused_local_variable
        for (var element in variationList) {
          i = i + 1;
        }
        col = colCount.length;
        row = widget.model!.prVarientList!.length;
      }
    }

//========================= Loading Indiacator =================================

    setState(
      () {
        _isLoading = false;
      },
    );
  }

//======================== getCurrentProductTags API ===========================

  getCurrentProductTags() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          "product_id": widget.model!.id,
        };
        http.Response response =
            await http.post(getProductTagsAPI, body: parameter, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        print(" getProductTagsAPI response : ${response.body.toString()}");

        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          productTags = (data as List)
              .map(
                (data) => TagsModel.fromJson(data),
              )
              .toList();
          tagsList = productTags;
          productTagsList = tagsList;
          productTagsList.forEach((element) {
            finalTagsList.add(element.id!);
          });

          setState(
            () {},
          );
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    }
  }

//======================== getAttributes API ===================================

  getAttributes() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http.post(getAttributesApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        print("getAttributesApi response : ${response.body.toString()}");

        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          attributesList = (data as List)
              .map(
                (data) => AttributeModel.fromJson(data),
              )
              .toList();
          for (var element in attributesList) {
            selectedAttributeValues[element.id!] = [];
          }

          setState(
            () {},
          );
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          setsnackbar(
            getTranslated(
              context,
              "You need to add Attributes",
            )!,
            context,
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    }
  }

//============================= getTags API =================================

  allgetTags() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http.post(getTagsApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        print(" getTagsApiresponse : ${response.body.toString()}");

        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          tagsList = (data as List).map((data) => TagsModel.fromJson(data)).toList();
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          print("data${getdata[statusCode]}");
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
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

//======================== getAttributrValuesApi API ===========================

  getAttributesValue() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response =
            await http.post(getAttributrValuesApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        print(" getAttributrValuesApi  response : ${response.body.toString()}");
        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          attributesValueList = (data as List)
              .map(
                (data) => AttributeValueModel.fromJson(data),
              )
              .toList();
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          setsnackbar(
            getTranslated(context, "You need to Add Attribute Values")!,
            context,
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    }
  }

//======================== getTax API ==========================================

  getTax() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http.post(getTaxesApi, headers: await ApiUtils.getHeaders()).timeout(
              const Duration(seconds: timeOut),
            );
        var getdata = json.decode(response.body);
        print(" getTaxesApi response : ${response.body.toString()}");
        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          taxesList = (data as List).map((data) => TaxesModel.fromJson(data)).toList();
          for (int i = 0; i < taxesList.length; i++) {
            if (TAXGLOBAL != null || TAXGLOBAL != "" || TAXGLOBAL!.isNotEmpty) {
              if (taxesList[i].id.toString() == TAXGLOBAL.toString()) {
                taxName = taxesList[i].title;
                taxId = taxesList[i].id;
              }
            }
          }
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
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

//================================= ProductName ================================

  addProductName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        productText(),
        productTextField(),
      ],
    );
  }

  productText() {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
        top: 15,
      ),
      child: Text(
        "${getTranslated(context, "Name")!} *",
        style: const TextStyle(
          fontSize: 16,
          color: black,
        ),
      ),
    );
  }

  productTextField() {
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(productFocus);
        },
        focusNode: productFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: productNameControlller,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          productName = value;
        },
        validator: (val) => validateProduct(val, context),
        decoration: InputDecoration(
          hintText: getTranslated(context, "PRODUCTHINT_TXT")!,
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

//=========================== ShortDescription =================================

  shortDescription() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated(context, "ShortDescription")!,
            style: const TextStyle(
              fontSize: 16,
              color: black,
            ),
          ),
          const SizedBox(
            height: 05,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: lightBlack,
                width: 1,
              ),
            ),
            width: width,
            height: height * 0.12,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
              ),
              child: TextFormField(
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(sortDescriptionFocus);
                },
                focusNode: sortDescriptionFocus,
                controller: sortDescriptionControlller,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                validator: (val) => sortdescriptionvalidate(val, context),
                onChanged: (value) {
                  sortDescription = value;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  hintText: getTranslated(context, "Add Sort Detail of Product ...!")!,
                ),
                minLines: null,
                maxLines: null,
                expands: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

//================================= Tags Add ===================================

  tagsAdd() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          tagsText(),
          Padding(padding: const EdgeInsets.all(4.0), child: addTagName()),
          productTagsList.isNotEmpty
              ? Wrap(
                  children: List.generate(
                      productTagsList.length,
                      (index) => Padding(
                            padding: EdgeInsetsDirectional.only(end: 8.0),
                            child: Chip(
                                label: Text(productTagsList[index].title!),
                                onDeleted: () {
                                  setState(() {
                                    productTagsList.removeAt(index);
                                    finalTagsList.removeAt(index);
                                  });
                                }),
                          )))
              : Container()
        ],
      ),
    );
  }

  tagsText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getTranslated(context, "Tags")!,
          style: const TextStyle(
            fontSize: 16,
            color: black,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            getTranslated(
              context,
              "(These tags help you in search result)",
            )!,
            style: const TextStyle(
              color: Colors.grey,
            ),
            softWrap: false,
          ),
        ),
      ],
    );
  }

  addTagName() {
    return SizedBox(
      width: width,
      child: Autocomplete<TagsModel>(
        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
          return OrientationBuilder(builder: (context, orientation) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              optionsViewWidthNotifier.value = (context.findRenderObject() as RenderBox).size.width;
            });
            tagsControlller = textEditingController;
            return TextFormField(
              decoration: InputDecoration(
                hintText: getTranslated(context, "searchForTags")!,
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
              ),
              controller: tagsControlller,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          });
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<TagsModel>.empty();
          }
          return tagsList.where((TagsModel option) {
            return option.title!.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (TagsModel selection) {
          productTagsList.add(selection);
          finalTagsList.add(selection.id!);
          setState(() {});
          tagsControlller.clear();
          debugPrint(' ${selection.title}');
        },
        displayStringForOption: (employee) => employee.title!,
      ),
    );
  }

//============================== Tax Selection =================================

  taxSelection() {
    print("selectedTaxID : $selectedTaxID");
    print("taxesList : ${taxesList.length}");

    taxesList
        .where(
          (element) => element.id == selectedTaxID!.toString(),
        )
        .toList();
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${getTranslated(context, "Select Tax")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
            ),
            Text(
              taxName.toString(),
            ),
          ],
        ));
  }

  taxesDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Tax")!,
                          style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: fontColor),
                        ),
                        Text(
                          getTranslated(context, "0%")!,
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
                        children: getTaxtList(),
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

  List<Widget> getTaxtList() {
    return taxesList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setState(
                    () {
                      selectedTaxID = index;
                      taxId = taxesList[selectedTaxID!].id;
                      Navigator.of(context).pop();
                    },
                  );
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(
                    20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        taxesList[index].title!,
                      ),
                      Text(
                        "${taxesList[index].percentage!}%",
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

//========================= Indicator Selection ================================

  indicatorField() {
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    indicatorValue != null
                        ? Text(
                            indicatorValue == '0'
                                ? getTranslated(context, "None")!
                                : indicatorValue == '1'
                                    ? getTranslated(context, "Veg")!
                                    : getTranslated(context, "Non-Veg")!,
                          )
                        : Text(
                            getTranslated(context, "Select Indicator")!,
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
          indicatorDialog();
        },
      ),
    );
  }

  attributeDialog(int pos) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20.0,
                          20.0,
                          20.0,
                          8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, "Select Attribute")!,
                              style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: fontColor),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: lightBlack),
                      suggessionisNoData
                          ? getNoItem(context)
                          : SizedBox(
                              width: double.maxFinite,
                              height: attributeSetList.isNotEmpty ? MediaQuery.of(context).size.height * 0.3 : 0,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: attributeSetList.length,
                                  itemBuilder: (context, index) {
                                    List<AttributeModel> attrList = [];

                                    AttributeSetModel item = attributeSetList[index];

                                    for (int i = 0; i < attributesList.length; i++) {
                                      if (item.id == attributesList[i].attributeSetId) {
                                        attrList.add(attributesList[i]);
                                      }
                                    }
                                    return Material(
                                      child: StickyHeaderBuilder(
                                        builder: (BuildContext context, double stuckAmount) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: primary,
                                              borderRadius: BorderRadius.circular(
                                                5,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 2,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              attributeSetList[index].name ?? '',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          );
                                        },
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: List<int>.generate(attrList.length, (i) => i).map(
                                            (item) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(
                                                    () {
                                                      _attrController[pos].text = attrList[item].name!;
                                                      attributeIndiacator = pos + 1;
                                                      if (!attrId.contains(
                                                        int.parse(attrList[item].id!),
                                                      )) {
                                                        attrId.add(int.parse(attrList[item].id!));
                                                        Navigator.pop(context);
                                                      } else {
                                                        setsnackbar(
                                                          getTranslated(context, "Already inserted..")!,
                                                          context,
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  width: double.maxFinite,
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    attrList[item].name ?? '',
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  indicatorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Indicator")!,
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
                              setState(
                                () {
                                  indicatorValue = '0';
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
                                      getTranslated(context, "None")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  indicatorValue = '1';
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
                                      getTranslated(context, "Veg")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  indicatorValue = '2';
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
                                      getTranslated(context, "Non-Veg")!,
                                    ),
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

//================================ Calories ====================================

  getCalories() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: SizedBox(
                  width: width * 0.4,
                  child: Text(
                    "${getTranslated(context, "Calories")!} :",
                    style: const TextStyle(
                      fontSize: 16,
                      color: black,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: SizedBox(
                  width: width * 0.4,
                  child: Text(
                    getTranslated(context, "(1 kilocalorie (kcal) = 1000 calories (cal))")!,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: width * 0.5,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(caloriesFocus);
              },
              keyboardType: TextInputType.text,
              controller: caloriesController,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: caloriesFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
              onChanged: (String? value) {
                caloriestext = value;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  maxHeight: 20,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  caloriesText() {
    return Row(
      children: [
        Text(
          getTranslated(context, "Calories")!,
          style: const TextStyle(
            fontSize: 16,
            color: black,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            getTranslated(context, "(1 kilocalorie (kcal) = 1000 calories (cal))")!,
            style: const TextStyle(
              color: Colors.grey,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

//========================= TotalAllow Quantity ================================

  totalAllowedQuantity() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              bottom: 8,
            ),
            child: SizedBox(
              width: width * 0.4,
              child: Text(
                "${getTranslated(context, "Total Allowed Quantity")!} :",
                style: const TextStyle(
                  fontSize: 16,
                  color: black,
                ),
                maxLines: 2,
              ),
            ),
          ),
          Container(
            width: width * 0.5,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(totalAllowFocus);
              },
              keyboardType: TextInputType.number,
              controller: totalAllowController,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: totalAllowFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                totalAllowQuantity = value;
              },
              validator: (val) => validateThisFieldRequered(val, context),
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//========================= Minimum Order Quantity =============================

  minimumOrderQuantity() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              bottom: 8,
            ),
            child: SizedBox(
              width: width * 0.4,
              child: Text(
                "${getTranslated(context, "Minimum Order Quantity")!} :",
                style: const TextStyle(
                  fontSize: 16,
                  color: black,
                ),
                maxLines: 2,
              ),
            ),
          ),
          Container(
            width: width * 0.5,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(minOrderFocus);
              },
              keyboardType: TextInputType.number,
              controller: minOrderQuantityControlller,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: minOrderFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                minOrderQuantity = value;
              },
              validator: (val) => validateThisFieldRequered(val, context),
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//========================= select Category Header =============================

  selectCategory() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${getTranslated(context, "selected category")!} :",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[400],
                    border: Border.all(color: black),
                  ),
                  width: 200,
                  height: 20,
                  child: Center(
                    child: selectedCatName == null
                        ? Text(
                            getTranslated(context, "Not Selected Yet ...")!,
                          )
                        : Text(selectedCatName!),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: lightWhite,
              border: Border.all(color: black),
            ),
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.only(bottom: 5, start: 10, end: 10),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catagorylist.length,
                    itemBuilder: (context, index) {
                      CategoryModel? item;

                      item = catagorylist.isEmpty ? null : catagorylist[index];

                      return item == null ? Container() : getCategorys(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getCategorys(int index) {
    CategoryModel model = catagorylist[index];
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            selectedCatName = model.name;
            selectedCatID = model.id;
            setState(
              () {},
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.fiber_manual_record_rounded,
                size: 20,
                color: primary,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: width * 0.6,
                child: Text(
                  model.name!,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

//============================= Is COD allowed =================================

  _isCODAllow() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                getTranslated(context, "Is COD allowed ?")!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  isCODallow = value;
                  if (value) {
                    isCODAllow = "1";
                  } else {
                    isCODAllow = "0";
                  }
                },
              );
            },
            value: isCODallow,
          ),
        ],
      ),
    );
  }

  _isSpicy() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                getTranslated(context, "spicy")!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  isSpicy = value;
                  if (value) {
                    isSpicyValue = "1";
                  } else {
                    isSpicyValue = "0";
                  }
                },
              );
            },
            value: isSpicy,
          ),
        ],
      ),
    );
  }

  _isProductTime() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                getTranslated(context, "productAvailableTitle")!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  isProducttime = value;
                  if (value) {
                    isProductTime = "1";
                  } else {
                    isProductTime = "0";
                  }
                },
              );
            },
            value: isProducttime,
          ),
        ],
      ),
    );
  }

//=========================== Tax included in prices ===========================

  taxIncludedInPrice() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                getTranslated(context, "Tax included in prices ?")!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  taxincludedInPrice = value;
                  if (value) {
                    taxincludedinPrice = "1";
                  } else {
                    taxincludedinPrice = "0";
                  }
                },
              );
            },
            value: taxincludedInPrice,
          ),
        ],
      ),
    );
  }

//============================= Is Cancelable ==================================

  _isCancelable() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 15.0,
        right: 15.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                getTranslated(context, "Is Cancelable ?")!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Switch(
            onChanged: (value) {
              setState(
                () {
                  iscancelable = value;
                  if (value) {
                    isCancelable = "1";
                  } else {
                    isCancelable = "0";
                  }
                },
              );
            },
            value: iscancelable,
          )
        ],
      ),
    );
  }

//============================= Till which status ==============================

  tillWhichStatus() {
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tillwhichstatus != null
                        ? Text(
                            tillwhichstatus == 'received'
                                ? getTranslated(context, "RECEIVED_LBL")!
                                : tillwhichstatus == 'processed'
                                    ? getTranslated(context, "PROCESSED_LBL")!
                                    : getTranslated(context, "SHIPED_LBL")!,
                          )
                        : Text(
                            getTranslated(context, "Till which status ?")!,
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
          tillWhichStatusDialog();
        },
      ),
    );
  }

  tillWhichStatusDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  tillwhichstatus = 'received';
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
                                      getTranslated(context, "RECEIVED_LBL")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  tillwhichstatus = 'processed';
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
                                      getTranslated(context, "PROCESSED_LBL")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  tillwhichstatus = 'shipped';
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
                                      getTranslated(context, "SHIPED_LBL")!,
                                    ),
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
                    from: "main",
                    type: "edit",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  mainImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      File image = File(result.files.single.path!);
      setState(
        () {
          mainImageProductImage = image;
        },
      );
    } else {}
  }

  selectedMainImageShow() {
    return productImage == ''
        ? Container()
        : Image.network(
            productImageUrl,
            width: 100,
            height: 100,
          );
  }

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
                    type: "edit",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

//========================= Additional Info ====================================

  additionalInfo() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: lightBlack,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: curSelPos == 0
                      ? TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primary,
                          disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                        )
                      : null,
                  onPressed: () {
                    setState(
                      () {
                        curSelPos = 0;
                      },
                    );
                  },
                  child: Text(
                    getTranslated(context, "General Information")!,
                  ),
                ),
                TextButton(
                  style: curSelPos == 1
                      ? TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primary,
                          disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                        )
                      : null,
                  onPressed: () {
                    setState(
                      () {
                        curSelPos = 1;
                      },
                    );
                  },
                  child: Text(
                    getTranslated(context, "Attributes")!,
                  ),
                ),
                productType == 'variable_product'
                    ? TextButton(
                        style: curSelPos == 2
                            ? TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: primary,
                                disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                              )
                            : null,
                        onPressed: () {
                          setState(
                            () {
                              curSelPos = 2;
                            },
                          );
                        },
                        child: Text(
                          getTranslated(context, "Variations")!,
                        ),
                      )
                    : Container(),
              ],
            ),

            //general section
            curSelPos == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${getTranslated(context, "Type Of Product")!} :"),
                      ),
                      typeSelectionField(),
                      // For Simple Product
                      productType == 'simple_product' ? simpleProductPrice() : Container(),
                      productType == 'simple_product' ? simpleProductSpecialPrice() : Container(),
                      CheckboxListTile(
                        title: Text(
                          getTranslated(context, "Enable Stock Management")!,
                        ),
                        value: _isStockSelected ?? false,
                        onChanged: (bool? value) {
                          setState(
                            () {
                              _isStockSelected = value!;
                            },
                          );
                        },
                      ),
                      _isStockSelected != null && _isStockSelected == true && productType == 'simple_product' ? simpleProductSKU() : Container(),

                      productType == 'simple_product'
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: SimBtn(
                                title: getTranslated(context, "Save Settings")!,
                                size: MediaQuery.of(context).size.width * 0.5,
                                onBtnSelected: () {
                                  if (simpleProductPriceController.text.isEmpty) {
                                    setsnackbar(
                                      getTranslated(context, "Please enter product price")!,
                                      context,
                                    );
                                  } else if (simpleProductSpecialPriceController.text.isEmpty) {
                                    setState(
                                      () {
                                        simpleProductSaveSettings = true;
                                        setsnackbar(
                                          getTranslated(context, "Setting saved successfully")!,
                                          context,
                                        );
                                      },
                                    );
                                  } else if (int.parse(simpleproductPrice!) < int.parse(simpleproductSpecialPrice!)) {
                                    setsnackbar(
                                      getTranslated(context, "Special price must be less than original price")!,
                                      context,
                                    );
                                  } else {
                                    setState(
                                      () {
                                        simpleProductSaveSettings = true;
                                        setsnackbar(
                                          getTranslated(context, "Setting saved successfully")!,
                                          context,
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),

                      // For Variant Product

                      _isStockSelected != null && _isStockSelected == true && productType == 'variable_product'
                          ? variableProductStockManagementType()
                          : Container(),

                      productType == 'variable_product' &&
                              variantStockLevelType == "product_level" &&
                              _isStockSelected != null &&
                              _isStockSelected == true
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                variantProductTotalstock(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    getTranslated(context, "Stock Status :")!,
                                  ),
                                ),
                                productStockStatusSelect()
                              ],
                            )
                          : Container(),

                      productType == 'variable_product' && variantStockLevelType == "product_level"
                          ? SimBtn(
                              title: getTranslated(context, "Save Settings")!,
                              size: MediaQuery.of(context).size.width * 0.5,
                              onBtnSelected: () {
                                if (_isStockSelected != null &&
                                    _isStockSelected == true &&
                                    (variountProductTotalStock.text.isEmpty || stockStatus.isEmpty)) {
                                  setsnackbar(
                                    getTranslated(context, "Please enter all details")!,
                                    context,
                                  );
                                } else {
                                  setState(
                                    () {
                                      variantProductProductLevelSaveSettings = true;
                                      setsnackbar(
                                        getTranslated(context, "Setting saved successfully")!,
                                        context,
                                      );
                                    },
                                  );
                                }
                              },
                            )
                          : Container(),
                      //setting button
                      productType == 'variable_product' && variantStockLevelType == "variable_level"
                          ? SimBtn(
                              title: getTranslated(context, "Save Settings")!,
                              size: MediaQuery.of(context).size.width * 0.5,
                              onBtnSelected: () {
                                setState(
                                  () {
                                    variantProductVariableLevelSaveSettings = true;
                                    setsnackbar(
                                      getTranslated(context, "Setting saved successfully")!,
                                      context,
                                    );
                                  },
                                );
                              },
                            )
                          : Container(),
                    ],
                  )
                : Container(),
            //attribute section
            curSelPos == 1 && (simpleProductSaveSettings || variantProductVariableLevelSaveSettings || variantProductProductLevelSaveSettings)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getTranslated(context, "Attributes")!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  if (attributeIndiacator == _attrController.length) {
                                    setState(
                                      () {
                                        _attrController.add(
                                          TextEditingController(),
                                        );
                                        variationBoolList.add(false);
                                      },
                                    );
                                  } else {
                                    setsnackbar(
                                      getTranslated(context, "fill the box then add another")!,
                                      context,
                                    );
                                  }
                                },
                                child: Text(
                                  getTranslated(context, "Add Attribute")!,
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  tempAttList.clear();
                                  List<String> attributeIds = [];
                                  for (var i = 0; i < variationBoolList.length; i++) {
                                    if (variationBoolList[i]) {
                                      final attributes = attributesList.where((element) => element.name == _attrController[i].text).toList();
                                      if (attributes.isNotEmpty) {
                                        attributeIds.add(attributes.first.id!);
                                      }
                                    }
                                  }
                                  setState(
                                    () {
                                      resultAttr = [];
                                      resultID = [];
                                      variationList = [];
                                      finalAttList = [];
                                      for (var key in attributeIds) {
                                        tempAttList.add(selectedAttributeValues[key]!);
                                      }
                                      for (int i = 0; i < tempAttList.length; i++) {
                                        finalAttList.add(tempAttList[i]);
                                      }
                                      if (finalAttList.isNotEmpty) {
                                        max = finalAttList.length - 1;

                                        getCombination([], [], 0);
                                        row = 1;
                                        col = max + 1;
                                        for (int i = 0; i < col; i++) {
                                          int singleRow = finalAttList[i].length;
                                          row = row * singleRow;
                                        }
                                      }
                                      setsnackbar(
                                        getTranslated(context, "Attributes saved successfully")!,
                                        context,
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  getTranslated(context, "Save Attribute")!,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      productType == 'variable_product'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getTranslated(
                                  context,
                                  "Note : select checkbox if the attribute is to be used for variation",
                                )!,
                              ),
                            )
                          : Container(),
                      for (int i = 0; i < _attrController.length; i++) addAttribute(i)
                    ],
                  )
                : Container(),
//variation section
            curSelPos == 2 && variationList.isNotEmpty
                ? ListView.builder(
                    itemCount: row,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return ExpansionTile(
                        title: Row(
                          children: [
                            for (int j = 0; j < col; j++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    variationList[i].attr_name!.split(',')[j],
                                  ),
                                ),
                              ),
                            InkWell(
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.close,
                                ),
                              ),
                              onTap: () {
                                setState(
                                  () {
                                    variationList.removeAt(i);
                                    row = variationList.length;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        children: <Widget>[
                          Column(
                            children: _buildExpandableContent(i),
                          ),
                        ],
                      );
                    },
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  getCombination(List<String> att, List<String> attId, int i) {
    for (int j = 0, l = finalAttList[i].length; j < l; j++) {
      List<String> a = [];
      List<String> aId = [];
      if (att.isNotEmpty) {
        a.addAll(att);
        aId.addAll(attId);
      }
      a.add(finalAttList[i][j].value!);
      aId.add(finalAttList[i][j].id!);
      if (i == max) {
        resultAttr.addAll(a);
        resultID.addAll(aId);
        Product_Varient model = Product_Varient(attr_name: a.join(","), id: aId.join(","));
        variationList.add(model);
      } else {
        getCombination(a, aId, i + 1);
      }
    }
  }

  _buildExpandableContent(int pos) {
    List<Widget> columnContent = [];

    columnContent.add(
      variantProductPrice(pos),
    );
    columnContent.add(
      variantProductSpecialPrice(pos),
    );

    columnContent.add(
      productType == 'variable_product' && variantStockLevelType == "variable_level" && _isStockSelected != null && _isStockSelected == true
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                variantVariableTotalstock(pos),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslated(context, "Stock Status :")!,
                  ),
                ),
                variantStockStatusSelect(pos)
              ],
            )
          : Container(),
    );

    return columnContent;
  }

// ========== variant Product Price add In side the variant price add ==========

  Widget variantProductPrice(int pos) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "PRICE_LBL")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.4,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: variationList[pos].price != null ? variationList[pos].price! : '',
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                variationList[pos].price = value;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget variantProductSpecialPrice(int pos) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "Special Price")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.4,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: variationList[pos].disPrice != null ? variationList[pos].disPrice! : '',
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                variationList[pos].disPrice = value;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  addValAttribute(List<AttributeValueModel> selected, List<AttributeValueModel> searchRange, String attributeId) {
    showModalBottomSheet<List<AttributeValueModel>>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      enableDrag: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height: 240,
          width: MediaQuery.of(context).size.width,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated(context, "Select Attribute Value")!,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 2, mainAxisSpacing: 5.0, crossAxisSpacing: 5.0),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return filterChipWidget(
                      chipName: searchRange[index],
                      selectedList: selected,
                      update: update,
                    );
                  },
                  childCount: searchRange.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  update() {
    setState(
      () {},
    );
  }

  addAttribute(int pos) {
    final result = attributesList.where((element) => element.name == _attrController[pos].text).toList();
    final attributeId = result.isEmpty ? "" : result.first.id;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, "Select Attribute")!,
                ),
                Checkbox(
                  value: variationBoolList[pos],
                  onChanged: (bool? value) {
                    setState(
                      () {
                        variationBoolList[pos] = value ?? false;
                      },
                    );
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: TextFormField(
              textAlign: TextAlign.center,
              readOnly: true,
              onTap: () {
                attributeDialog(pos);
              },
              controller: _attrController[pos],
              keyboardType: TextInputType.text,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                hintText: getTranslated(context, "Select Attributes")!,
                hintStyle: Theme.of(context).textTheme.bodySmall,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {
                final attributeValues = attributesValueList.where((element) => element.attributeId == attributeId).toList();

                addValAttribute(selectedAttributeValues[attributeId]!, attributeValues, attributeId!);
              },
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  color: lightWhite,
                ),
                constraints: const BoxConstraints(
                  minHeight: 50,
                ),
                child: (selectedAttributeValues[attributeId!] ?? []).isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            getTranslated(context, "Add attribute value")!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: selectedAttributeValues[attributeId]!
                            .map(
                              (value) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: primary,
                                    border: Border.all(
                                      color: black,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      value.value!,
                                      style: const TextStyle(
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  productStockStatusSelect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    stockStatus != ""
                        ? Text(
                            stockStatus == '1' ? getTranslated(context, "In Stock")! : getTranslated(context, "Out Of Stock")!,
                          )
                        : Text(
                            getTranslated(context, "Select Stock Status")!,
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
          variantStockStatusDialog("product", 0);
        },
      ),
    );
  }

  variantStockStatusSelect(int pos) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    Text(
                      variationList[pos].stockStatus == '1' ? getTranslated(context, "In Stock")! : getTranslated(context, "Out Of Stock")!,
                    )
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
          variantStockStatusDialog("variable", pos);
        },
      ),
    );
  }

  variantStockStatusDialog(String from, int pos) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Type")!,
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
                              setState(
                                () {
                                  if (from == 'variable') {
                                    variationList[pos].stockStatus = "1";
                                  } else {
                                    stockStatus = '1';
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
                                      getTranslated(context, "In Stock")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  if (from == 'variable') {
                                    variationList[pos].stockStatus = "0";
                                  } else {
                                    stockStatus = '0';
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
                                      getTranslated(context, "Out Of Stock")!,
                                    ),
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

  variantVariableTotalstock(int pos) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "Total Stock")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.4,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: variationList[pos].stock != null ? variationList[pos].stock! : '',
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: variountProductTotalStockFocus,
              textInputAction: TextInputAction.next,
              onChanged: (String? value) {
                variationList[pos].stock = value;
                variountProductTotalStock.text = value!;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  variantProductTotalstock() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "Total Stock")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.4,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(variountProductTotalStockFocus);
              },
              keyboardType: TextInputType.number,
              controller: variountProductTotalStock,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: variountProductTotalStockFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                variantproductTotalStock = value;
                variountProductTotalStock.text = value!;
                print("value:${variountProductTotalStock.text}");
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//=========================== Simple Product Fields ============================

  simpleProductPrice() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "PRICE_LBL")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.3,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(simpleProductPriceFocus);
              },
              keyboardType: TextInputType.number,
              controller: simpleProductPriceController,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: simpleProductPriceFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                simpleproductPrice = value;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  simpleProductSpecialPrice() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "Special Price")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.3,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(simpleProductSpecialPriceFocus);
              },
              keyboardType: TextInputType.number,
              controller: simpleProductSpecialPriceController,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: simpleProductSpecialPriceFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                simpleproductSpecialPrice = value;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget simpleProductSKU() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        simpleProductTotalstock(),
        simpleProductStockStatusSelect(),
      ],
    );
  }

  simpleProductStockStatusSelect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    simpleproductStockStatus != null
                        ? Text(
                            simpleproductStockStatus == '1' ? getTranslated(context, "In Stock")! : getTranslated(context, "Out Of Stock")!,
                          )
                        : Text(
                            getTranslated(context, "Select Stock Status")!,
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
          stockStatusDialog();
        },
      ),
    );
  }

  stockStatusDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Type")!,
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
                              setState(
                                () {
                                  simpleproductStockStatus = '1';
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20.0,
                                  20.0,
                                  20.0,
                                  20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getTranslated(context, "In Stock")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  simpleproductStockStatus = '0';
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20.0,
                                  20.0,
                                  20.0,
                                  20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getTranslated(context, "Out Of Stock")!,
                                    ),
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

  Widget simpleProductTotalstock() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "${getTranslated(context, "Total Stock")!} :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.3,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(simpleProductTotalStockFocus);
              },
              keyboardType: TextInputType.number,
              controller: simpleProductTotalStock,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: simpleProductTotalStockFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (String? value) {
                simpleproductTotalStock = value;
                simpleProductTotalStock.text = value!;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  typeSelectionField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    productType != null
                        ? Text(
                            productType == 'simple_product' ? getTranslated(context, "Simple Product")! : getTranslated(context, "Variable Product")!,
                          )
                        : Text(
                            getTranslated(context, "Select Type")!,
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
          FocusScope.of(context).requestFocus(FocusNode());

          setsnackbar("You can't Change Product Type", context);
        },
      ),
    );
  }

  productTypeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Type")!,
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
                              setState(
                                () {
                                  variantProductVariableLevelSaveSettings = false;
                                  variantProductProductLevelSaveSettings = false;
                                  simpleProductSaveSettings = false;
                                  productType = 'simple_product';
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
                                      getTranslated(context, "Simple Product")!,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  //reset
                                  simpleProductPriceController.text = '';
                                  simpleProductSpecialPriceController.text = '';
                                  _isStockSelected = false;

                                  //set
                                  variantProductVariableLevelSaveSettings = false;
                                  variantProductProductLevelSaveSettings = false;
                                  simpleProductSaveSettings = false;
                                  productType = 'variable_product';
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
                                      getTranslated(context, "Variable Product")!,
                                    ),
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

//=========================== Variable Product Fields ==========================

// Choose Stock Management Type:

  variableProductStockManagementType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${getTranslated(context, "Choose Stock Management Type")!} :",
        ),
        variableProductStockManagementTypeSelection(),
      ],
    );
  }

  variableProductStockManagementTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                    variantStockLevelType != null
                        ? Expanded(
                            child: Text(
                              variantStockLevelType == 'product_level'
                                  ? getTranslated(
                                      context,
                                      "Product Level (Stock Will Be Managed Generally)",
                                    )!
                                  : getTranslated(
                                      context,
                                      "Variable Level (Stock Will Be Managed Variant Wise)",
                                    )!,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          )
                        : Expanded(
                            child: Text(
                              getTranslated(context, "Select Stock Status")!,
                            ),
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
          variountProductStockManagementTypeDialog();
        },
      ),
    );
  }

  variountProductStockManagementTypeDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            taxesState = setStater;
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
                          getTranslated(context, "Select Stock Type")!,
                          style: const TextStyle(color: fontColor),
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
                              setState(
                                () {
                                  variantStockLevelType = 'product_level';
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20.0,
                                  20.0,
                                  20.0,
                                  20.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getTranslated(
                                          context,
                                          "Product Level (Stock Will Be Managed Generally)",
                                        )!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  variantStockLevelType = 'variable_level';
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
                                    Expanded(
                                      child: Text(
                                        getTranslated(
                                          context,
                                          "Variable Level (Stock Will Be Managed Variant Wise)",
                                        )!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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

//=========================== Add Product Button ===============================

  resetProButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {},
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

  Future<void> addProductAPI(List<String> attributesValuesIds) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", editProductApi);
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[resturantId] = CUR_USERID!;
        request.fields[editProductId] = widget.model!.id!;

        request.fields[EditVariantId] = oldVariantId!;
        request.fields[ProInputName] = productName!;
        request.fields[ShortDescription] = sortDescription!;
        if (tags != null) {
          request.fields[Tags] = finalTagsList.join(",").toString();
        }
        if (taxId != null) {
          request.fields[ProInputTax] = taxId!;
        }
        if (indicatorValue != null) {
          request.fields[Indicator] = indicatorValue!;
        }
        if (totalAllowQuantity != null && totalAllowQuantity != "") {
          request.fields[TotalAllowedQuantity] = totalAllowQuantity!;
        }
        request.fields[MinimumOrderQuantity] = minOrderQuantity!;

        request.fields[IsPricesInclusiveTax] = taxincludedinPrice!;
        request.fields[CodAllowed] = isCODAllow!;
        request.fields[IsSpicy] = isSpicyValue!;
        request.fields[IsCancelable] = isCancelable!;
        request.fields[ProInputImage] = productImageRelativePath;
        print("image:${productImageRelativePath}");
        if (tillwhichstatus != null) {
          request.fields[CancelableTill] = tillwhichstatus!;
        }
        if (isProductTime == "1") {
          request.fields[availableTime] = isProductTime!;
          request.fields[startTimeLb] = "${startTime.hour}:${startTime.minute}:00";
          request.fields[endTimeLb] = "${endTime.hour}:${endTime.minute}:00";
        } else {
          request.fields[availableTime] = isProductTime!;
        }
        if (selectedTypeOfVideo != null) {
          request.fields[VideoType] = selectedTypeOfVideo!;
        }
        request.fields[CategoryId] = selectedCatID!;
        if (highLights != null && highLights != "") {
          request.fields["highlights"] = highLights!;
        }
        request.fields[ProductType] = productType!;
        if (caloriestext != null && caloriestext != "") {
          request.fields["calories"] = caloriestext!;
        }
        request.fields[VariantStockLevelType] = variantStockLevelType!;
        request.fields[AttributeValues] = attributesValuesIds.join(",");
        if (productType == 'simple_product') {
          String? status;
          if (_isStockSelected == null) {
            status = null;
          } else {
            status = simpleproductStockStatus;
          }
          request.fields[SimpleProductStockStatus] = status ?? 'null';
          request.fields[SimplePrice] = simpleProductPriceController.text;
          request.fields[SimpleSpecialPrice] = simpleProductSpecialPriceController.text;
          if (_isStockSelected != null && _isStockSelected == true) {
            request.fields[ProductTotalStock] = simpleproductTotalStock!;
            request.fields[VariantStockStatus] = "0";
          }
        } else if (productType == 'variable_product') {
          String val = '', price = '', sprice = '';
          for (int i = 0; i < variationList.length; i++) {
            String testing = "";
            if (variationList[i].attribute_value_ids.toString() != "null") {
              testing = variationList[i].attribute_value_ids!.replaceAll(',', ' ');
            } else {
              testing = variationList[i].id!.replaceAll(',', ' ');
            }
            if (testing != "") {
              if (val == "") {
                if (!val.contains(testing)) {
                  val = testing;
                  price = variationList[i].price!;
                  sprice = variationList[i].disPrice ?? ' ';
                }
              } else {
                val = "$val,$testing";
                price = "$price,${variationList[i].price!}";
                sprice = "$sprice,${variationList[i].disPrice ?? ' '}";
              }
            }
          }

          request.fields[VariantsIds] = val;
          request.fields[VariantPrice] = price;
          request.fields[VariantSpecialPrice] = sprice;

          if (variantStockLevelType == 'product_level') {
            request.fields[TotalStockVariantType] = variountProductTotalStock.text;
            request.fields[VariantStatus] = stockStatus;
          } else if (variantStockLevelType == 'variable_level') {
            String sku = '', totalStock = '', stkStatus = '';
            for (int i = 0; i < variationList.length; i++) {
              if (sku == '') {
                sku = variationList[i].sku!;
                totalStock = variationList[i].stock!;
                stkStatus = variationList[i].stockStatus!;
              } else {
                sku = "$sku,${variationList[i].sku!}";
                totalStock = "$totalStock,${variationList[i].stock!}";
                stkStatus = "$stkStatus,${variationList[i].stockStatus!}";
              }
            }
            request.fields[VariantSku] = sku;
            request.fields[VariantTotalStock] = totalStock;
            request.fields[VariantLevelStockStatus] = stkStatus;
          }
        }
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        print("getdata:${request.fields}");
        if (!error) {
          await buttonController!.reverse();
          setsnackbar(msg, context);
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

  gethighLights() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          highLightText(),
          addHighLightName(),
        ],
      ),
    );
  }

  highLightText() {
    return Row(
      children: [
        Text(
          getTranslated(context, "Highlights")!,
          style: const TextStyle(
            fontSize: 16,
            color: black,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            getTranslated(
              context,
              "( These highlights will show near product title )",
            )!,
            style: const TextStyle(
              color: Colors.grey,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  addHighLightName() {
    return SizedBox(
      width: width,
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(highlightFocus);
        },
        focusNode: highlightFocus,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        controller: highLightController,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        onChanged: (value) {
          highLights = value;
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, "Type in some highlights for example Spicy,Sweet,Must Try etc")!,
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

  Future pickTime(
    BuildContext context,
    bool morning,
  ) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: () {
        if (morning) {
          return startTime;
        } else {
          return endTime;
        }
      }(),
    );

    if (newTime == null) return;
    if (morning) {
      setState(() => startTime = newTime);
    } else {
      setState(() => endTime = newTime);
    }
  }

  productShowTime() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
              left: 8.0,
            ),
            child: Text(
              "${getTranslated(context, "startTime")!} *",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              pickTime(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: white,
            ),
            child: Text(
              "${() {
                return startTime.hour.toString().padLeft(2, '0');
              }()} : ${() {
                return startTime.minute.toString().padLeft(2, '0');
              }()}",
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 8.0,
              left: 8.0,
            ),
            child: Text(
              "${getTranslated(context, "endTime")!} *",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              pickTime(
                context,
                false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: white,
            ),
            child: Text(
              "${() {
                return endTime.hour.toString().padLeft(2, '0');
              }()} : ${() {
                return endTime.minute.toString().padLeft(2, '0');
              }()}",
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

//=========================== Body Part ========================================

  getBodyPart() {
    return SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            addProductName(),
            shortDescription(),
            gethighLights(),
            taxSelection(),
            indicatorField(),
            totalAllowedQuantity(),
            minimumOrderQuantity(),
            getCalories(),
            selectCategory(),
            _isCODAllow(),
            _isSpicy(),
            taxIncludedInPrice(),
            _isCancelable(),
            isCancelable == "1" ? tillWhichStatus() : Container(),
            _isProductTime(),
            isProductTime == "1" ? productShowTime() : Container(),
            mainImage(),
            selectedMainImageShow(),
            tagsAdd(),
            adons(),
            showadons(),
            additionalInfo(),
            AppBtn(
              title: getTranslated(context, "Update Product")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                validateAndSubmit();
              },
            ),
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
    List<String> attributeIds = [];
    List<String> attributesValuesIds = [];

    for (var i = 0; i < variationBoolList.length; i++) {
      if (variationBoolList[i]) {
        final attributes = attributesList.where((element) => element.name == _attrController[i].text).toList();
        if (attributes.isNotEmpty) {
          attributeIds.add(attributes.first.id!);
        }
      }
    }
    for (var key in attributeIds) {
      for (var element in selectedAttributeValues[key]!) {
        attributesValuesIds.add(element.id!);
      }
    }
    if (validateAndSave()) {
      _playAnimation();
      addProductAPI(attributesValuesIds);
    }
  }

  bool validateAndSave() {
    print("startTime:$startTime-----endTime:$endTime-----");
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (productType == null) {
        setsnackbar(
          getTranslated(context, "Please select product type")!,
          context,
        );
        return false;
      } else if (finalTagsList.isEmpty) {
        setsnackbar(
          getTranslated(context, "pleaseAddTags")!,
          context,
        );
        return false;
      } else if (productImage == '' && mainImageProductImage == "") {
        setsnackbar(
          getTranslated(context, "Please Add product image")!,
          context,
        );
        return false;
      } else if (selectedCatID == null) {
        setsnackbar(
          getTranslated(context, "Please select category")!,
          context,
        );
        return false;
      } else if (isProductTime == "1" && startTime == const TimeOfDay(hour: 00, minute: 00) && endTime == const TimeOfDay(hour: 00, minute: 00)) {
        setsnackbar(
          getTranslated(context, "pleaseAddStartTimeAndEndTimeOfProduct")!,
          context,
        );
        return false;
      } else if (productType == 'simple_product') {
        if (simpleProductPriceController.text.isEmpty) {
          setsnackbar(
            getTranslated(context, "Please enter product price")!,
            context,
          );
          return false;
        } else if (simpleProductPriceController.text.isNotEmpty &&
            simpleProductSpecialPriceController.text.isNotEmpty &&
            double.parse(simpleProductSpecialPriceController.text) > double.parse(simpleProductPriceController.text)) {
          setsnackbar(
            getTranslated(context, "Special price can not greater than price")!,
            context,
          );
          return false;
        } else if (_isStockSelected != null && _isStockSelected == true) {
          if (simpleproductTotalStock == null) {
            setsnackbar(
              getTranslated(context, "Please enter stock details")!,
              context,
            );
            return false;
          }
          return true;
        }
        return true;
      } else if (productType == 'variable_product') {
        for (int i = 0; i < variationList.length; i++) {
          if (variationList[i].price == null || variationList[i].price!.isEmpty) {
            setsnackbar(
              getTranslated(context, "Please enter price details")!,
              context,
            );
            return false;
          }
        }
        if (_isStockSelected != null && _isStockSelected == true) {
          if (variantStockLevelType == "product_level" && variantproductTotalStock == null) {
            setsnackbar(
              getTranslated(context, "Please enter stock details")!,
              context,
            );
            return false;
          }

          if (variantStockLevelType == "variable_level") {
            for (int i = 0; i < variationList.length; i++) {
              if (variationList[i].sku == null ||
                  variationList[i].sku!.isEmpty ||
                  variationList[i].stock == null ||
                  variationList[i].stock!.isEmpty) {
                setsnackbar(
                  getTranslated(context, "Please enter stock details")!,
                  context,
                );
                return false;
              }
            }

            return true;
          }
          return true;
        }
      }

      return true;
    }
    return false;
  }

//================================ show add -ons ====================================

  showadons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: tableflag
          ? Table(
              border: TableBorder.all(color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Center(
                      child: Text(
                        getTranslated(context, "Title")!,
                      ),
                    ),
                    Center(
                      child: Text(
                        getTranslated(context, "PRICE_LBL")!,
                      ),
                    ),
                    Center(
                      child: Text(
                        getTranslated(context, "Calories")!,
                      ),
                    ),
                    Center(
                      child: Text(
                        getTranslated(context, "ShortDescription")!,
                      ),
                    ),
                  ],
                ),
                for (int i = 0; i < addOns.length; i++)
                  TableRow(
                    children: [
                      Center(
                        child: Text(
                          adtitle[i],
                        ),
                      ),
                      Center(
                        child: Text(
                          adprice[i],
                        ),
                      ),
                      Center(
                        child: Text(
                          adshortdesc[i],
                        ),
                      ),
                      Center(
                        child: Text(
                          adcalories[i],
                        ),
                      ),
                    ],
                  )
              ],
            )
          : Container(),
    );
  }

//================================ add -ons ====================================

  adons() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: lightBlack,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslated(context, "Product Add Ons")!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            getTextFields(
              getTranslated(context, "Title")!,
              addOnTitleFocus,
              addOnTitleController,
              1,
              TextInputType.text,
            ),
            getTextFields(
              getTranslated(context, "PRICE_LBL")!,
              addOnPriceFocus,
              addOnPriceController,
              2,
              TextInputType.number,
            ),
            getTextFields(
              getTranslated(context, "Calories")!,
              addOnCaloriesFocus,
              addOnCalorieController,
              3,
              TextInputType.number,
            ),
            getaddOnShortDescription(),
            adOnSaveButton(),
          ],
        ),
      ),
    );
  }

  adOnSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(5),
          ),
          width: 140,
          height: 40,
          child: Center(
            child: Text(
              getTranslated(context, "Save Add Ons")!,
              style: const TextStyle(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        onTap: () {
          if (addOnTitle == null) {
            setsnackbar(
              getTranslated(context, "please add title Field")!,
              context,
            );
          } else if (addOnPrice == null) {
            setsnackbar(
              getTranslated(context, "please add Price Field")!,
              context,
            );
          } else if (addOnCalorie == null) {
            setsnackbar(
              getTranslated(context, "please add Calorie Field")!,
              context,
            );
            return;
          } else if (addOnShortDescription == null) {
            setsnackbar(
              getTranslated(context, "please add Short Description Field")!,
              context,
            );
            return;
          } else {
            Map<String, dynamic> singleAddon = {
              "title": addOnTitle,
              "description": addOnShortDescription,
              "price": addOnPrice,
              "calories": addOnCalorie,
              "status": "1"
            };
            addOns.add(singleAddon);
            adtitle.add(addOnTitle ?? "");
            adprice.add(addOnPrice ?? "");
            adshortdesc.add(addOnShortDescription ?? "");
            adcalories.add(addOnCalorie ?? "");
            addOnTitleController.text = "";
            addOnDescriptionController.text = "";
            addOnCalorieController.text = "";
            addOnPriceController.text = "";
            addOnTitle = null;
            addOnPrice = null;
            addOnCalorie = null;
            addOnShortDescription = null;
            setsnackbar(
              getTranslated(context, "Add Ons Saved Successfully!")!,
              context,
            );
            tableflag = true;
            setState(
              () {},
            );
          }
        },
      ),
    );
  }

//=========================== Similar Fields =================================

  getTextFields(String heading, FocusNode? focusnode, TextEditingController? controller, int index, TextInputType? keybord) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.4,
            child: Text(
              "$heading :",
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
              maxLines: 2,
            ),
          ),
          Container(
            width: width * 0.3,
            height: 40,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(focusnode);
              },
              keyboardType: keybord,
              controller: controller,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: focusnode,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
              onChanged: (String? value) {
                if (index == 1) {
                  addOnTitle = value;
                } else if (index == 2) {
                  addOnPrice = value;
                } else if (index == 3) {
                  addOnCalorie = value;
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//=========================== Add on shortDescription ====================================

  getaddOnShortDescription() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: width * 0.4,
                child: Text(
                  "${getTranslated(context, "ShortDescription")!} :",
                  style: const TextStyle(
                    fontSize: 16,
                    color: black,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: width * 0.87,
            height: 80,
            padding: const EdgeInsets.only(),
            child: TextFormField(
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(addOnShortDescriptionFocus);
              },
              keyboardType: TextInputType.text,
              controller: addOnDescriptionController,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
              focusNode: addOnShortDescriptionFocus,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
              onChanged: (String? value) {
                addOnShortDescription = value;
              },
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: lightWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: fontColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: lightWhite),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getAppBar(
        getTranslated(context, "Edit Product")!,
        context,
      ),
      body: _isLoading ? shimmer() : getBodyPart(),
    );
  }
}
