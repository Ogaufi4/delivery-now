import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/home.dart';
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
import '../Model/Attribute Models/AttributeValueModel/attribute_value.dart';
import '../Model/CategoryModel/category_model.dart';
import '../Model/ProductModel/variants.dart';
import '../Model/Tags/tags.dart';
import '../Model/TaxesModel/taxesmodel.dart';
import 'Widgets/FilterChips.dart';
import 'media.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

late String productImage, productImageUrl;
List<Product_Varient> variationList = [];

class _AddProductState extends State<AddProduct> with TickerProviderStateMixin {
//======================= Variable Declaration =================================

// temprary variable for test
  late Map<String, List<AttributeValueModel>> selectedAttributeValues = {};
// Variable For UI ...
  // for UI
  String? selectedCatName; // for UI
  int? selectedTaxID; // for UI

//on-off toggles
  bool isToggled = false;
  bool isCODallow = false;
  bool isProducttime = false;
  bool iscancelable = false;
  bool taxincludedInPrice = false;
  bool isSpicy = false;

// for Table UI
  List<String> adtitle = [];
  List<String> adprice = [];
  List<String> adshortdesc = [];
  List<String> adcalories = [];

//for remove extra add
  int attributeIndiacator = 0;
  List<Map<String, dynamic>> addOns = [];
// network variable
  bool _isNetworkAvail = true;
  String? data;
  bool suggessionisNoData = false;

//======================= Parameter For API Call=======================

  String? productName; //pro_input_name
  String? sortDescription; // short_description
  String? tags; // Tags
  String? highLights; //
  String? taxId; // Tax (pro_input_tax)
  String? taxName;
  String? indicatorValue; // indicator
  String? totalAllowQuantity; // total_allowed_quantity
  String? minOrderQuantity; // minimum_order_quantity
  String? caloriestext;
  String? quantityStepSize; // quantity_step_size
  String? taxincludedinPrice = "0"; //is_prices_inclusive_tax
  String? isCODAllow = "0"; //cod_allowed
  String? isProductTime = "0"; //availableTime
  String? isCancelable = "0"; //is_cancelable
  String? tillwhichstatus; //cancelable_till
  //File? mainProductImage;//pro_input_image
  File? videoOfProduct; // pro_input_video
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

  String? addOnPrice;
  String? addOnTitle;
  String? addOnCalorie;
  String? addOnShortDescription;
// for variable product
  List<List<AttributeValueModel>> finalAttList = [];
  List<List<AttributeValueModel>> tempAttList = [];
  String? variantsIds; //variants_ids
  String? variantPrice; // variant_price
  String? variantSpecialPrice; // variant_special_price
  String? variantImages; // variant_images

  //{if (variant_stock_level_type == product_level)}
  String? variantproductTotalStock; // total_stock_variant_type
  String stockStatus = '1'; // variant_status
  bool? _isStockSelected;
  bool tableflag = false;

  //  other
  bool simpleProductSaveSettings = false;
  bool variantProductProductLevelSaveSettings = false;
  bool variantProductVariableLevelSaveSettings = false;
  late StateSetter taxesState;

  // getting data
  List<TaxesModel> taxesList = [];
  List<TagsModel> tagsList = [];
  List<TagsModel> productTagsList = [];
  List<String> finalTagsList = [];
  TimeOfDay startTime = const TimeOfDay(hour: 09, minute: 00);
  TimeOfDay endTime = const TimeOfDay(hour: 09, minute: 00);
  List<AttributeModel> attributesList = [];
  List<AttributeValueModel> attributesValueList = [];
  List<CategoryModel> catagorylist = [];
  final List<TextEditingController> _attrController = [];
  final List<TextEditingController> _attrValController = [];
  List<bool> variationBoolList = [];
  List<int> attrId = [];
  List<int> attrValId = [];
  List<String> attrVal = [];

//======================= TextEditingController ================================

  TextEditingController productNameControlller = TextEditingController();
  TextEditingController tagsControlller = TextEditingController();
  TextEditingController highLightController = TextEditingController();
  TextEditingController totalAllowController = TextEditingController();
  TextEditingController minOrderQuantityControlller = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController quantityStepSizeControlller = TextEditingController();
  TextEditingController vidioTypeController = TextEditingController();
  TextEditingController simpleProductPriceController = TextEditingController();
  TextEditingController simpleProductSpecialPriceController = TextEditingController();
  TextEditingController simpleProductTotalStock = TextEditingController();
  TextEditingController variountProductTotalStock = TextEditingController();
  TextEditingController addOnPriceController = TextEditingController();
  TextEditingController addOnTitleController = TextEditingController();
  TextEditingController addOnDescriptionController = TextEditingController();
  TextEditingController addOnCalorieController = TextEditingController();

  final ValueNotifier<double?> optionsViewWidthNotifier = ValueNotifier(null);

//=================================== FocusNode ================================
  late int row = 1, col;
  FocusNode? productFocus,
      sortDescriptionFocus,
      tagFocus,
      highlightFocus,
      totalAllowFocus,
      minOrderFocus,
      caloriesFocus,
      quantityStepSizeFocus,
      vidioTypeFocus,
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

  bool showSuggestedAttributes = false;

  TextEditingController textEditingController = TextEditingController();

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

  @override
  void initState() {
    productImage = "";
    productImageUrl = "";
    getCategories();
    getTax();
    getAttributesValue();
    getAttributes();
    getTags();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    productImage = '';
    productImageUrl = '';

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
    var parameter = {};
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

//======================== getTags API =================================

  getTags() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http.post(getTagsApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          tagsList = (data as List).map((data) => TagsModel.fromJson(data)).toList();
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          print("msg$msg");
          setsnackbar(msg, context);
        }
        setState(
          () {},
        );
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

//======================== getAttributes API ===================================

  getAttributes() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http.post(getAttributesApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

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
            getTranslated(context, "You need to add Attributes")!,
            context,
          );
        }
        setState(
          () {},
        );
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
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
        setState(
          () {},
        );
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
        http.Response response = await http.post(getTaxesApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);

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
        } else {
          setsnackbar(msg, context);
        }
        setState(
          () {},
        );
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
            getTranslated(context, "( These highlights will show near product title )")!,
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
          addTagName(),
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
      children: [
        Text(
          "${getTranslated(context, "Tags")!}*",
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
      ),
    );
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
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8),
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
                              height: attributesList.isNotEmpty ? MediaQuery.of(context).size.height * 0.3 : 0,
                              child: SingleChildScrollView(
                                child: Material(
                                  child: StickyHeaderBuilder(
                                    builder: (BuildContext context, double stuckAmount) {
                                      return Container();
                                    },
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: List<int>.generate(attributesList.length, (i) => i).map(
                                        (item) {
                                          return InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  _attrController[pos].text = attributesList[item].name!;
                                                  attributeIndiacator = pos + 1;
                                                  if (!attrId.contains(int.parse(attributesList[item].id!))) {
                                                    attrId.add(int.parse(attributesList[item].id!));
                                                    Navigator.pop(context);
                                                  } else {
                                                    setsnackbar(
                                                      getTranslated(context, "Already inserted..")!,
                                                      context,
                                                    );
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              );
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                attributesList[item].name ?? '',
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.grey[400], border: Border.all(color: black)),
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
            width: width,
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
            children: [
              const Icon(
                Icons.fiber_manual_record_rounded,
                size: 20,
                color: primary,
              ),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: width * 0.60,
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
                        ? Text(tillwhichstatus == 'pending'
                            ? getTranslated(context, "PENDING")!
                            : tillwhichstatus == 'confirmed'
                                ? getTranslated(context, "Confirmed")!
                                : tillwhichstatus == 'preparing'
                                    ? getTranslated(context, "Preparing")!
                                    : getTranslated(context, "Out For Delivery")!)
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
                                  tillwhichstatus = 'pending';
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
                                      getTranslated(context, "PENDING")!,
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
                                  tillwhichstatus = 'confirmed';
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
                                      getTranslated(context, "Confirmed")!,
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
                                  tillwhichstatus = 'preparing';
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
                                      getTranslated(context, "Preparing")!,
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
                                  tillwhichstatus = 'out_for_delivery';
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
                                      getTranslated(context, "Out For Delivery")!,
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
                    type: "add",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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
                    type: "add",
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
              mainAxisAlignment: MainAxisAlignment.start,
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
                              child: SizedBox(
                                child: Text(
                                  getTranslated(context, "Attributes")!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                        _attrValController.add(
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
                                child: Text(getTranslated(context, "Save Attribute")!),
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
                                  child: Text(variationList[i].attr_name!.split(',')[j]),
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

                                    for (int i = 0; i < variationList.length; i++) {
                                      row = row - 1;
                                    }
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
                    setState(() {
                      variationBoolList[pos] = value ?? false;
                    });
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
                                    )),
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

//=========================== Similar Fields =================================

  getTextFields(String heading, FocusNode? focusnode, TextEditingController? controller, int index) {
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
              keyboardType: TextInputType.text,
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
                                  simpleproductStockStatus = '0';
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
          productTypeDialog();
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
                              getTranslated(
                                context,
                                "Product Level (Stock Will Be Managed Generally)",
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
            ],
          ),
        ),
        onTap: () {},
      ),
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
                builder: (context) => const AddProduct(),
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

//=========================== Add Product API Call =============================

  Future<void> addProductAPI(List<String> attributesValuesIds) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", addProductsApi);
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[resturantId] = CUR_USERID!;
        request.fields[ProInputName] = productName!;
        request.fields[ShortDescription] = sortDescription!;
        var adonString = json.encode(addOns);
        request.fields[productAddOns] = adonString;

        if (tags != null) {
          request.fields[Tags] = finalTagsList.join(",").toString();
        }
        if (highLights != null) {
          request.fields[highlights] = highLights!;
        }
        if (caloriestext != null) {
          request.fields[calories] = caloriestext!;
        }
        if (taxId != null) request.fields[ProInputTax] = taxId!;
        if (indicatorValue != null) {
          request.fields[Indicator] = indicatorValue!;
        }
        if (isProductTime == "1") {
          request.fields[availableTime] = isProductTime!;
          request.fields[startTimeLb] = "${startTime.hour}:${startTime.minute}:00";
          request.fields[endTimeLb] = "${endTime.hour}:${endTime.minute}:00";
        } else {
          request.fields[availableTime] = isProductTime!;
        }
        request.fields[TotalAllowedQuantity] = totalAllowQuantity!;
        request.fields[MinimumOrderQuantity] = minOrderQuantity!;

        request.fields[IsPricesInclusiveTax] = taxincludedinPrice!;
        request.fields[CodAllowed] = isCODAllow!;
        request.fields[IsSpicy] = isSpicyValue!;
        request.fields[IsCancelable] = isCancelable!;
        if (productImage != "") {
          request.fields[ProInputImage] = productImage;
        }
        if (tillwhichstatus != null) {
          request.fields[CancelableTill] = tillwhichstatus!;
        }
        request.fields[productCategoryId] = selectedCatID!;
        request.fields[ProductType] = productType!;
        request.fields[VariantStockLevelType] = variantStockLevelType!;
        request.fields[AttributeValues] = attributesValuesIds.join(",");
        //simple product
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
            if (val == '') {
              val = variationList[i].id!.replaceAll(',', ' ');
              price = variationList[i].price!;
              sprice = variationList[i].disPrice ?? ' ';
            } else {
              val = "$val,${variationList[i].id!.replaceAll(',', ' ')}";
              price = "$price,${variationList[i].price!}";
              sprice = "$sprice,${variationList[i].disPrice ?? ' '}";
            }
          }
          request.fields[VariantsIds] = val;
          request.fields[VariantPrice] = price;
          request.fields[VariantSpecialPrice] = sprice;

          if (variantStockLevelType == 'product_level') {
            request.fields[TotalStockVariantType] = variountProductTotalStock.text;
            request.fields[VariantStatus] = stockStatus;
          }
        }
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);

        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          await buttonController!.reverse();
          if (msg == "Product Added Successfully") {
            Home.globalKey.currentState?.getStatics();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const AddProduct(),
              ),
            );
          }
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
            getTextFields(
              getTranslated(context, "Title")!,
              addOnTitleFocus,
              addOnTitleController,
              1,
            ),
            getTextFields(
              getTranslated(context, "PRICE_LBL")!,
              addOnPriceFocus,
              addOnPriceController,
              2,
            ),
            getTextFields(
              getTranslated(context, "Calories")!,
              addOnCaloriesFocus,
              addOnCalorieController,
              3,
            ),
            getaddOnShortDescription(),
            adOnSaveButton(),
          ],
        ),
      ),
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
              keyboardType: TextInputType.number,
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
              title: getTranslated(context, "Add Product")!,
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
      } else if (productImage == '') {
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
          return true;
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
        getTranslated(context, "Add New Product")!,
        context,
      ),
      body: getBodyPart(),
    );
  }
}
