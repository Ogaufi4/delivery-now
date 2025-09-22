import 'dart:async';
import 'dart:convert';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../Helper/api_base_helper.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/sim_btn.dart';
import '../Helper/string.dart';
import '../Model/ProductModel/product.dart';
import 'add_product.dart';
import 'editProduct.dart';
import 'search.dart';

class ProductList extends StatefulWidget {
  final String? flag;

  const ProductList({Key? key, this.flag}) : super(key: key);
  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String? sortBy = 'p.id', orderBy = "DESC", flag = ' ';
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  List<dynamic>? filterList = [];
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  String? filter = "";

  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  final List<TextEditingController> _controller = [];
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  var items;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    flag = widget.flag;
    getProduct("0");

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
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }
    super.dispose();
  }

  getDesingButton(
    String title,
    IconData icon,
  ) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 25.0, //MediaQuery.of(context).size.width * .08,
        width: 120.0, //MediaQuery.of(context).size.width * .3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                );
              },
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: listType ? backgroun1 : white,
      appBar: getAppbar(),
      floatingActionButton: floatingBtn(),
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : productList.isEmpty
                  ? getNoItem(context)
                  : Stack(
                      children: <Widget>[
                        _showForm(),
                        showCircularProgress(
                          isProgress,
                          primary,
                        ),
                      ],
                    )
          : noInternet(context),
    );
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
              title: getTranslated(context, "NO_INTERNET")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      offset = 0;
                      total = 0;
                      flag = '';
                      getProduct("0");
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                          () {},
                        );
                      }
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

  Widget listItem(int index) {
    if (index < productList.length) {
      Product? model = productList[index];
      totalProduct = model.total;

      /* String stockType = "";
      if (model.stockType == "null") {
        stockType = "Not enabled";
      } else if (model.stockType == "1" || model.stockType == "0") {
        stockType = "Global";
      } else if (model.stockType == "2") {
        stockType = "Varient wise";
      } */

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      /* items = List<String>.generate(
          model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
          (i) => (i + 1).toString()); */

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      return Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          side: BorderSide(
            color: backgroun2,
            width: 0.4,
          ),
        ),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            ).then(
              (value) => () {
                setState(
                  () {
                    _isLoading = true;
                    isLoadingmore = true;
                    offset = 0;
                    total = 0;
                    productList.clear();
                  },
                );
                return getProduct("0");
              }(),
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                          tag: "$index${model.id}+ $index${model.name}",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: FadeInImage(
                              image: NetworkImage(model.image!),
                              height: 80.0,
                              width: 80.0,
                              placeholder: placeHolder(60),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  model.name!,
                                  style: const TextStyle(color: lightBlack),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "$CUR_CURRENCY $price ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      double.parse(model
                                                  .prVarientList![
                                                      model.selVarient!]
                                                  .disPrice!) !=
                                              0
                                          ? "$CUR_CURRENCY${model.prVarientList![model.selVarient!].price!}"
                                          : "",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 05,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProduct(
                                      model: model,
                                    ),
                                  ),
                                ).then(
                                  (value) => () {
                                    setState(
                                      () {
                                        _isLoading = true;
                                        isLoadingmore = true;
                                        offset = 0;
                                        total = 0;
                                        productList.clear();
                                      },
                                    );
                                    return getProduct("0");
                                  }(),
                                );
                              },
                              child: getDesingButton(
                                getTranslated(context, "Edit")!,
                                Icons.edit,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                productDeletDialog(
                                  model.name!,
                                  model.id!,
                                );
                              },
                              child: getDesingButton(
                                getTranslated(context, "delete")!,
                                Icons.delete,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 020,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              model.availability == "0"
                  ? Text(
                      getTranslated(context, "OutOfStock")!,
                      style: const TextStyle(
                        color: red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(),
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: width * 0.78,
                top: 30,
                child: Switch(
                  onChanged: (value) {
                    if (model.status != "1") {
                      updateProductStatus(model.id!, "1");
                    } else {
                      updateProductStatus(model.id!, "0");
                    }
                  },
                  value: model.status == "1" ? true : false,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> updateProductStatus(String id, String status) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          "product_id": id,
          "status": status,
        };
        Response response = await post(updateProductStatusAPI,
                headers: await ApiUtils.getHeaders(), body: parameter)
            .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            setsnackbar(msg, context);
            _isLoading = true;
            isLoadingmore = true;
            offset = 0;
            total = 0;
            productList.clear();
            getProduct("0");
          } else {
            if(getdata[statusCode]=="120"){
              reLogin(context);
            }
            setsnackbar(msg, context);
          }
        }
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, 'somethingMSg')!, context);

        setState(
          () {},
        );
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
    }
    return;
  }

//=============================== floating Button ==============================

  floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: black,
          child: const Icon(
            Icons.add,
            size: 32,
            color: white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<String>(
                builder: (context) => const AddProduct(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> getProduct(String top) async {
    if (readProduct) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        var parameter = {
          //CATID: widget.id ?? '',
          resturantId: CUR_USERID,
          SORT: sortBy,
          Order: orderBy,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          TOP_RETAED: top,
          FLAG: flag,
          'show_only_active_products': "false",
        };
        if (selId != "") {
          parameter[AttributeValueIds] = selId;
        }
        apiBaseHelper.postAPICall(getProductsApi, parameter, context).then(
          (getdata) async {
            bool error = getdata["error"];
            // String? msg = getdata["message"];
            if (!error) {
              total = int.parse(getdata["total"]);

              if (_isFirstLoad) {
                filterList = getdata["filters"];
                _isFirstLoad = false;
              }

              if ((offset) < total) {
                tempList.clear();

                var data = getdata["data"];
                tempList = (data as List)
                    .map(
                      (data) => Product.fromJson(data),
                    )
                    .toList();
                getAvailVarient();

                offset = offset + perPage;
              }
            } else {
              // setsnackbar(msg!, context);
              isLoadingmore = false;
            }
            if (mounted) {
              setState(
                () {
                  _isLoading = false;
                },
              );
            }
          },
          onError: (error) {
            setsnackbar(
              error.toString(),
              context,
            );
            if (mounted) {
              setState(
                () {
                  _isLoading = false;
                  isLoadingmore = false;
                },
              );
            }
          },
        );
      } else {
        if (mounted) {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
      Future.delayed(const Duration(microseconds: 500)).then(
        (_) async {
          setsnackbar(
            getTranslated(context,
                "You have not authorized permission for read Product!!")!,
            context,
          );
        },
      );
    }
    return;
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  getAppbar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: white,
      iconTheme: const IconThemeData(color: primary),
      title: Text(
        getTranslated(context, "Products")!,
        style: const TextStyle(
          color: primary,
        ),
      ),
      elevation: 5,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsetsDirectional.only(end: 4.0),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: primary,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              stockFilter();
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.filter_alt_outlined,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Search(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.search,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ),
        Container(
          width: 40,
          margin: const EdgeInsetsDirectional.only(top: 10, bottom: 10, end: 5),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton(
              padding: EdgeInsets.zero,
              onSelected: (dynamic value) {
                switch (value) {
                  case 0:
                    return filterDialog();
                  case 1:
                    return sortDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                /*PopupMenuItem(
                  value: 0,
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                    leading: const Icon(
                      Icons.tune,
                      color: fontColor,
                      size: 25,
                    ),
                    title: Text(
                      getTranslated(context, "Filter")!,
                    ),
                  ),
                ),*/
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
                    leading: const Icon(Icons.sort, color: fontColor, size: 20),
                    title: Text(
                      getTranslated(context, "Sort")!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget productItem(int index, bool pad) {
    if (index < productList.length) {
      Product model = productList[index];

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }
      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      _controller[index].text =
          model.prVarientList![model.selVarient!].cartCount!;
      /* items = List<String>.generate(
          model.totalAllow != "" ? int.parse(model.totalAllow!) : 10,
          (i) => (i + 1).toString()); */

      String stockType = "";
      if (model.stockType == "null") {
        stockType = "Not enabled";
      } else if (model.stockType == "1" || model.stockType == "0") {
        stockType = "Global";
      } else if (model.stockType == "2") {
        stockType = "Varient wise";
      }

      return Card(
        elevation: 0.2,
        margin: EdgeInsetsDirectional.only(bottom: 5, end: pad ? 5 : 0),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProduct(
                  model: model,
                ),
              ),
            ).then(
              (value) => () {
                setState(
                  () {
                    _isLoading = true;
                    isLoadingmore = true;
                    offset = 0;
                    total = 0;
                    productList.clear();
                  },
                );
                return getProduct("0");
              }(),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "$index${model.id} 55",
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(model.image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          // fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: model.availability == "0"
                          ? Text(
                              getTranslated(context, "OutOfStock")!,
                              style: const TextStyle(
                                color: red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, top: 5, bottom: 5),
                child: Text(
                  model.name!,
                  style: const TextStyle(color: lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    " $CUR_CURRENCY $price ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  double.parse(model
                              .prVarientList![model.selVarient!].disPrice!) !=
                          0
                      ? Flexible(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? "$CUR_CURRENCY${model.prVarientList![model.selVarient!].price!}"
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  InkWell(
                    onTap: () {
                      productDeletDialog(
                        model.name!,
                        model.id!,
                      );
                    },
                    child: const Card(
                      child: Icon(
                        Icons.delete,
                        color: primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  '${getTranslated(context, "StockType")!}: $stockType',
                ),
              ),
              model.stockType != "null"
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${getTranslated(context, "StockCount")!}: ${model.prVarientList![model.selVarient!].stock ?? ''}',
                        style: const TextStyle(
                          color: fontColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Container(),
              model.type == "variable_product"
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Product model = productList[index];
                            _chooseVarient(model);
                          },
                          child: Text(
                            getTranslated(context, "SelectVarient")!,
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void _chooseVarient(Product model) {
    bool? available, outOfStock;
    List<int?> selectedIndex = [];
    ChoiceChip choiceChip;
    int? oldSelVarient = 0;
    //selList--selected list
    //sinList---single attribute list for compare
    selectedIndex.clear();
    if (model.stockType == "0" || model.stockType == "1") {
      if (model.availability == "1") {
        available = true;
        outOfStock = false;
        oldSelVarient = model.selVarient;
      } else {
        available = false;
        outOfStock = true;
      }
    } else if (model.stockType == "") {
      available = true;
      outOfStock = false;
      oldSelVarient = model.selVarient;
    } else if (model.stockType == "2") {
      if (model.prVarientList![model.selVarient!].availability == "1") {
        available = true;
        outOfStock = false;
        oldSelVarient = model.selVarient;
      } else {
        available = false;
        outOfStock = true;
      }
    }

    List<String> selList =
        model.prVarientList![model.selVarient!].attribute_value_ids!.split(",");

    for (int i = 0; i < model.attributeList!.length; i++) {
      List<String> sinList = model.attributeList![i].id!.split(',');

      for (int j = 0; j < sinList.length; j++) {
        if (selList.contains(sinList[j])) {
          selectedIndex.insert(i, j);
        }
      }

      if (selectedIndex.length == i) selectedIndex.insert(i, null);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      getTranslated(context, "SelectVarient")!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(),
                  _title(model.name!),
                  available! || outOfStock!
                      ? _price(model.prVarientList![oldSelVarient!].disPrice!,
                          model.prVarientList![oldSelVarient!].price)
                      : Container(),
                  available! || outOfStock!
                      ? _offPrice(
                          model.prVarientList![oldSelVarient!].disPrice!,
                          model.prVarientList![oldSelVarient!].price)
                      : Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.attributeList!.length,
                    itemBuilder: (context, index) {
                      List<Widget> chips = [];
                      List<String> att =
                          model.attributeList![index].value!.split(',');
                      List<String> attId =
                          model.attributeList![index].id!.split(',');
                      List<String> attSType =
                          model.attributeList![index].sType!.split(',');

                      List<String> attSValue =
                          model.attributeList![index].sValue!.split(',');

                      int? varSelected;

                      List<String> wholeAtt = model.attrIds!.split(',');
                      for (int i = 0; i < att.length; i++) {
                        Widget itemLabel;
                        if (attSType[i] == "1") {
                          String clr = (attSValue[i].substring(1));

                          String color = "0xff$clr";

                          itemLabel = Container(
                            width: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                int.parse(
                                  color,
                                ),
                              ),
                            ),
                          );
                        } else if (attSType[i] == "2") {
                          itemLabel = ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              attSValue[i],
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) =>
                                  erroWidget(80),
                            ),
                          );
                        } else {
                          itemLabel = Text(
                            att[i],
                            style: TextStyle(
                                color: selectedIndex[index] == (i)
                                    ? fontColor
                                    : white),
                          );
                        }

                        if (selectedIndex[index] != null) {
                          if (wholeAtt.contains(attId[i])) {
                            choiceChip = ChoiceChip(
                              selected: selectedIndex.length > index
                                  ? selectedIndex[index] == i
                                  : false,
                              label: itemLabel,
                              labelPadding: const EdgeInsets.all(0),
                              selectedColor: fontColor.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    attSType[i] == "1" ? 100 : 10),
                                side: BorderSide(
                                    color: selectedIndex[index] == (i)
                                        ? fontColor
                                        : black,
                                    width: 1.5),
                              ),
                              onSelected: att.length == 1
                                  ? null
                                  : (bool selected) {
                                      if (selected) {
                                        if (mounted) {
                                          setState(
                                            () {
                                              available = false;
                                              selectedIndex[index] =
                                                  selected ? i : null;
                                              List<int> selectedId =
                                                  []; //list where user choosen item id is stored
                                              List<bool> check = [];
                                              for (int i = 0;
                                                  i <
                                                      model.attributeList!
                                                          .length;
                                                  i++) {
                                                List<String> attId = model
                                                    .attributeList![i].id!
                                                    .split(',');

                                                if (selectedIndex[i] != null) {
                                                  selectedId.add(
                                                    int.parse(
                                                      attId[selectedIndex[i]!],
                                                    ),
                                                  );
                                                }
                                              }
                                              check.clear();
                                              late List<String> sinId;
                                              findMatch:
                                              for (int i = 0;
                                                  i <
                                                      model.prVarientList!
                                                          .length;
                                                  i++) {
                                                sinId = model.prVarientList![i]
                                                    .attribute_value_ids!
                                                    .split(",");

                                                for (int j = 0;
                                                    j < selectedId.length;
                                                    j++) {
                                                  if (sinId.contains(
                                                      selectedId[j]
                                                          .toString())) {
                                                    check.add(true);

                                                    if (selectedId.length ==
                                                            sinId.length &&
                                                        check.length ==
                                                            selectedId.length) {
                                                      varSelected = i;
                                                      break findMatch;
                                                    }
                                                  } else {
                                                    check.clear();
                                                    break;
                                                  }
                                                }
                                              }

                                              if (selectedId.length ==
                                                      sinId.length &&
                                                  check.length ==
                                                      selectedId.length) {
                                                if (model.stockType == "0" ||
                                                    model.stockType == "1") {
                                                  if (model.availability ==
                                                      "1") {
                                                    available = true;
                                                    outOfStock = false;
                                                    oldSelVarient = varSelected;
                                                  } else {
                                                    available = false;
                                                    outOfStock = true;
                                                  }
                                                } else if (model.stockType ==
                                                    "null") {
                                                  available = true;
                                                  outOfStock = false;
                                                  oldSelVarient = varSelected;
                                                } else if (model.stockType ==
                                                    "2") {
                                                  if (model
                                                          .prVarientList![
                                                              varSelected!]
                                                          .availability ==
                                                      "1") {
                                                    available = true;
                                                    outOfStock = false;
                                                    oldSelVarient = varSelected;
                                                  } else {
                                                    available = false;
                                                    outOfStock = true;
                                                  }
                                                }
                                              } else {
                                                available = false;
                                                outOfStock = false;
                                              }
                                            },
                                          );
                                        }
                                      }
                                    },
                            );

                            chips.add(choiceChip);
                          }
                        }
                      }

                      String value = selectedIndex[index] != null &&
                              selectedIndex[index]! <= att.length
                          ? att[selectedIndex[index]!]
                          : ' Please Select';

                      return chips.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${model.attributeList![index].name!} : $value",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Wrap(
                                    children: chips.map<Widget>(
                                      (Widget chip) {
                                        return Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: chip,
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            )
                          : Container();
                    },
                  ),
                  available == false || outOfStock == true
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              outOfStock == true
                                  ? getTranslated(context, "OutOfStock")!
                                  : getTranslated(
                                      context, "Thisvarientnotavailable")!,
                              style: const TextStyle(color: red),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _price(String disPrice, String? price1) {
    double price = double.parse(disPrice);
    if (price == 0) price = double.parse(price1!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text("$CUR_CURRENCY $price",
          style: Theme.of(context).textTheme.titleLarge),
    );
  }

  _offPrice(String disPrice, String? price1) {
    double price = double.parse(disPrice);

    if (price != 0) {
      double off = (double.parse(price1!) - double.parse(disPrice)).toDouble();
      off = off * 100 / double.parse(price1);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Text(
              "$CUR_CURRENCY $price1",
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                letterSpacing: 0,
              ),
            ),
            Text(
              " | ${off.toStringAsFixed(2)}% ${getTranslated(context, "off")!}",
              style: const TextStyle(
                color: primary,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _title(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10,
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: lightBlack,
        ),
      ),
    );
  }

  /* void stockFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ButtonBarTheme(
          data: const ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: AlertDialog(
            elevation: 2.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 19.0, bottom: 16.0),
                    child: Text(
                      getTranslated(context, "StockFilter")!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(
                    color: lightBlack,
                  ),
                  TextButton(
                    child: Text(
                      getTranslated(context, "All")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      flag = '';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 1');
                    },
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "Soldout")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      flag = 'sold';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 1');
                    },
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "Lowinstock")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      flag = 'low';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 2');
                    },
                  ),
                  const Divider(color: white),
                ],
              ),
            ),
          ),
        );
      },
    );
  } */

  void stockFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 19.0,
                    bottom: 16.0,
                  ),
                  child: Text(
                    getTranslated(context, "StockFilter")!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(color: lightBlack),
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  overflowAlignment: OverflowBarAlignment.center,
                  spacing: 8.0,
                  children: [
                    TextButton(
                      child: Text(
                        getTranslated(context, "All")!,
                        style: const TextStyle(color: lightBlack),
                      ),
                      onPressed: () {
                        flag = '';
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Text(
                        getTranslated(context, "Soldout")!,
                        style: const TextStyle(color: lightBlack),
                      ),
                      onPressed: () {
                        flag = 'sold';
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 1');
                      },
                    ),
                    const Divider(color: lightBlack),
                    TextButton(
                      child: Text(
                        getTranslated(context, "Lowinstock")!,
                        style: const TextStyle(color: lightBlack),
                      ),
                      onPressed: () {
                        flag = 'low';
                        if (mounted) {
                          setState(() {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          });
                        }
                        getProduct("0");
                        Navigator.pop(context, 'option 2');
                      },
                    ),
                  ],
                ),
                const Divider(color: white),
              ],
            ),
          ),
        );
      },
    );
  }


  /* void sortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ButtonBarTheme(
          data: const ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: AlertDialog(
            elevation: 2.0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  5.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        top: 19.0, bottom: 16.0),
                    child: Text(
                      getTranslated(context, "SortBy")!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "TopRated")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      sortBy = '';
                      orderBy = 'DESC';
                      flag = '';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("1");
                      Navigator.pop(context, 'option 1');
                    },
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "NewestFirst")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      sortBy = 'p.date_added';
                      orderBy = 'DESC';
                      flag = '';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 1');
                    },
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "OldestFirst")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      sortBy = 'p.date_added';
                      orderBy = 'ASC';
                      flag = '';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 2');
                    },
                  ),
                  const Divider(color: lightBlack),
                  TextButton(
                    child: Text(
                      getTranslated(context, "LOWTOHIGH")!,
                      style: const TextStyle(color: lightBlack),
                    ),
                    onPressed: () {
                      sortBy = 'pv.price';
                      orderBy = 'ASC';
                      flag = '';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
                          },
                        );
                      }
                      getProduct("0");
                      Navigator.pop(context, 'option 3');
                    },
                  ),
                  const Divider(color: lightBlack),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                    child: TextButton(
                      child: Text(
                        getTranslated(context, "HIGHTOLOW")!,
                        style: const TextStyle(color: lightBlack),
                      ),
                      onPressed: () {
                        sortBy = 'pv.price';
                        orderBy = 'DESC';
                        flag = '';
                        if (mounted) {
                          setState(
                            () {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            },
                          );
                        }
                        getProduct("0");
                        Navigator.pop(
                          context,
                          'option 4',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } */

  void sortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 2.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          contentPadding: const EdgeInsets.all(0.0),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: 19.0,
                    bottom: 16.0,
                  ),
                  child: Text(
                    getTranslated(context, "SortBy")!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(color: lightBlack),
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    _sortButton(context, "TopRated", '', 'DESC', 'option 1'),
                    const Divider(color: lightBlack),
                    _sortButton(context, "NewestFirst", 'p.date_added', 'DESC', 'option 1'),
                    const Divider(color: lightBlack),
                    _sortButton(context, "OldestFirst", 'p.date_added', 'ASC', 'option 2'),
                    const Divider(color: lightBlack),
                    _sortButton(context, "LOWTOHIGH", 'pv.price', 'ASC', 'option 3'),
                    const Divider(color: lightBlack),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 5.0),
                      child: _sortButton(context, "HIGHTOLOW", 'pv.price', 'DESC', 'option 4'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortButton(BuildContext context, String translationKey, String sortByValue, String orderByValue, String option) {
    return TextButton(
      child: Text(
        getTranslated(context, translationKey)!,
        style: const TextStyle(color: lightBlack),
      ),
      onPressed: () {
        setState(() {
          _isLoading = true;
          total = 0;
          offset = 0;
          productList.clear();
          sortBy = sortByValue;
          orderBy = orderByValue;
          flag = '';
        });
        getProduct("0");
        Navigator.pop(context, option);
      },
    );
  }


  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;

              if (offset < total) getProduct("0");
            },
          );
        }
      }
    }
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(
        () {
          _isLoading = true;
          isLoadingmore = true;
          offset = 0;
          total = 0;
          productList.clear();
        },
      );
    }
    return getProduct("0");
  }

  _showForm() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: listType
          ? ListView.builder(
              controller: controller,
              itemCount: (offset < total)
                  ? productList.length + 1
                  : productList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index == productList.length && isLoadingmore)
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : listItem(index);
              },
            )
          : Container(
              height: height,
              margin: EdgeInsets.only(left: width / 20.0),
              child: GridView.count(
                physics: const AlwaysScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 0.98,
                children: List.generate(
                  (offset < total)
                      ? productList.length + 1
                      : productList.length,
                  (index) {
                    Product model = productList[index];

                    return (index == productList.length && isLoadingmore)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProduct(
                                    model: model,
                                  ),
                                ),
                              ).then(
                                (value) => () {
                                  setState(
                                    () {
                                      _isLoading = true;
                                      isLoadingmore = true;
                                      offset = 0;
                                      total = 0;
                                      productList.clear();
                                    },
                                  );
                                  return getProduct("0");
                                }(),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: height / 88.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: width / 3.0,
                                    height: height / 9.0,
                                    decoration:
                                        boxDecorationContainer(offWhite, 15.0),
                                    padding: const EdgeInsets.only(
                                        top: 14.0, bottom: 14.0),
                                    margin: EdgeInsets.only(
                                      top: height / 20.0,
                                      right: width / 20.0,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: height / 30.0,
                                      ),
                                      child: Text(
                                        model.name!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(right: width / 20.0),
                                    alignment: Alignment.topCenter,
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: white,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: ClipOval(
                                          child: Image.network(
                                            model.image!,
                                            width: 55,
                                            height: 55,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                  },
                ),
              ),
            ),
    );
  }

  productDeletDialog(String productName, String id) async {
    String pName = productName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Text(
                "${getTranslated(context, "sure")!} \"  $pName \" ${getTranslated(context, "PRODUCT")!}",
                style: Theme.of(this.context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTNO")!,
                    style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                        color: lightBlack, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                        color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    delProductApi(id);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  delProductApi(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        ProductId: id,
      };
      apiBaseHelper.postAPICall(getDeleteProductApi, parameter, context).then(
        (getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            Home.globalKey.currentState?.getStatics();
            setsnackbar(msg!, context);
            _isLoading = true;
            isLoadingmore = true;
            offset = 0;
            total = 0;
            productList.clear();
            getProduct("0");
          } else {
            setsnackbar(msg!, context);

            _isLoading = true;
            isLoadingmore = true;
            offset = 0;
            total = 0;
            productList.clear();
            getProduct("0");
          }
        },
        onError: (error) {},
      );
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            _isLoading = false;
          },
        );
      }
    }
    return null;
  }

  void filterDialog() {
    if (filterList!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (builder) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 30.0),
                    child: AppBar(
                      backgroundColor: lightWhite,
                      title: Text(
                        getTranslated(context, "Filter")!,
                        style: const TextStyle(
                          color: fontColor,
                        ),
                      ),
                      elevation: 5,
                      leading: Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.all(10),
                            decoration: shadow(),
                            child: Card(
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () => Navigator.of(context).pop(),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(end: 4.0),
                                  child: Icon(Icons.keyboard_arrow_left,
                                      color: primary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsetsDirectional.only(end: 10.0),
                          alignment: Alignment.center,
                          child: InkWell(
                            child: Text(
                              getTranslated(context, "ClearFilters")!,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: fontColor,
                              ),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(
                                  () {
                                    selectedId.clear();
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: lightWhite,
                      padding: const EdgeInsetsDirectional.only(
                          start: 7.0, end: 7.0, top: 7.0),
                      child: Card(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: lightWhite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 10.0),
                                  itemCount: filterList!.length,
                                  itemBuilder: (context, index) {
                                    attsubList = filterList![index]
                                            ['attribute_values']
                                        .split(',');

                                    attListId = filterList![index]
                                            ['attribute_values_id']
                                        .split(',');

                                    if (filter == "") {
                                      filter = filterList![0]["name"];
                                    }

                                    return InkWell(
                                      onTap: () {
                                        if (mounted) {
                                          setState(
                                            () {
                                              filter =
                                                  filterList![index]['name'];
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 20,
                                                top: 10.0,
                                                bottom: 10.0),
                                        decoration: BoxDecoration(
                                          color: filter ==
                                                  filterList![index]['name']
                                              ? white
                                              : lightWhite,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          filterList![index]['name'],
                                          style: TextStyle(
                                            color: filter ==
                                                    filterList![index]['name']
                                                ? fontColor
                                                : lightBlack,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsetsDirectional.only(top: 10.0),
                                scrollDirection: Axis.vertical,
                                itemCount: filterList!.length,
                                itemBuilder: (context, index) {
                                  if (filter == filterList![index]["name"]) {
                                    attsubList = filterList![index]
                                            ['attribute_values']
                                        .split(',');

                                    attListId = filterList![index]
                                            ['attribute_values_id']
                                        .split(',');
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: attListId!.length,
                                      itemBuilder: (context, i) {
                                        return CheckboxListTile(
                                          dense: true,
                                          title: Text(
                                            attsubList![i],
                                            style: const TextStyle(
                                              color: lightBlack,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          value: selectedId.contains(
                                            attListId![i],
                                          ),
                                          activeColor: primary,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          onChanged: (bool? val) {
                                            if (mounted) {
                                              setState(
                                                () {
                                                  if (val == true) {
                                                    selectedId.add(
                                                      attListId![i],
                                                    );
                                                  } else {
                                                    selectedId.remove(
                                                      attListId![i],
                                                    );
                                                  }
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: white,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 15.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                total.toString(),
                              ),
                              Text(
                                getTranslated(context, "Productsfound")!,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SimBtn(
                          size: 0.4,
                          title: getTranslated(context, "Apply")!,
                          onBtnSelected: () {
                            selId = selectedId.join(',');

                            if (mounted) {
                              setState(
                                () {
                                  _isLoading = true;
                                  total = 0;
                                  offset = 0;
                                  productList.clear();
                                },
                              );
                            }
                            getProduct("0");
                            Navigator.pop(
                              context,
                              'Product Filter',
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      );
    }
  }
}
