import 'dart:async';
import 'package:project/Screen/editProduct.dart';
import 'package:flutter/material.dart';
import '../Helper/api_base_helper.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import '../Model/ProductModel/product.dart';

class Search extends StatefulWidget {
  final Function? updateHome;
  const Search({Key? key, this.updateHome}) : super(key: key);
  @override
  _StateSearch createState() => _StateSearch();
}

class _StateSearch extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  final bool _isProgress = false;
  List<Product> productList = [];
  final List<TextEditingController> _controllerList = [];
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  String _searchText = "", _lastsearch = "";
  int notificationoffset = 0;
  ScrollController? notificationcontroller;
  bool notificationisloadmore = true, notificationisgettingdata = false, notificationisnodata = false;

  late AnimationController _animationController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
    productList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);

    _controller.addListener(
      () {
        if (_controller.text.isEmpty) {
          if (mounted) {
            setState(
              () {
                _searchText = "";
                productList.clear();
              },
            );
          }
        } else {
          if (mounted) {
            setState(
              () {
                _searchText = _controller.text;
              },
            );
          }
        }

        if (_lastsearch != _searchText && (_searchText.length > 2)) {
          _lastsearch = _searchText;
          notificationisloadmore = true;
          notificationoffset = 0;
          getProduct();
        }
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
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
  }

  _transactionscrollListener() {
    if (notificationcontroller!.offset >= notificationcontroller!.position.maxScrollExtent && !notificationcontroller!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            getProduct();
          },
        );
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    notificationcontroller!.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++) {
      _controllerList[i].dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: 4.0,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: primary,
                  ),
                ),
              ),
            ),
          );
        }),
        backgroundColor: white,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(
              0,
              15.0,
              0,
              15.0,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: primary,
              size: 17,
            ),
            hintText: getTranslated(context, "SEARCH")!,
            hintStyle: TextStyle(
              color: primary.withValues(alpha: 0.5),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: white),
            ),
          ),
        ),
        titleSpacing: 0,
      ),
      body: _isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showContent(),
                showCircularProgress(
                  _isProgress,
                  primary,
                ),
              ],
            )
          : noInternet(context),
    );
  }

  Widget listItem(int index) {
    Product model = productList[index];

    if (_controllerList.length < index + 1) {
      _controllerList.add(
        TextEditingController(),
      );
    }

    _controllerList[index].text = model.prVarientList![model.selVarient!].cartCount!;

    double price = double.parse(model.prVarientList![model.selVarient!].disPrice!);
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
                () {},
              );
              return getProduct();
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                model.name!,
                                style: const TextStyle(
                                  color: lightBlack,
                                ),
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
                                    double.parse(
                                              model.prVarientList![model.selVarient!].disPrice!,
                                            ) !=
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
                                    () {},
                                  );
                                  return getProduct();
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
                onChanged: (value) {},
                value: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  getDesingButton(
    String title,
    IconData icon,
  ) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 25.0,
        width: 120.0,
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
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
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

  updateSearch() {
    if (mounted) {
      setState(
        () {},
      );
    }
  }

  void getAvailVarient(List<Product> tempList) {
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

  Future getProduct() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          if (mounted) {
            setState(
              () {
                notificationisloadmore = false;
                notificationisgettingdata = true;
                if (notificationoffset == 0) {
                  productList = [];
                }
              },
            );
          }
          CUR_USERID = await getPrefrence(Id);
          var parameter = {
            resturantId: CUR_USERID,
            SEARCH: _searchText.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };
          apiBaseHelper.postAPICall(getProductsApi, parameter, context).then(
            (getdata) async {
              bool error = getdata["error"];

              notificationisgettingdata = false;
              if (notificationoffset == 0) notificationisnodata = error;
              if (!error) {
                if (mounted) {
                  Future.delayed(
                    Duration.zero,
                    () => setState(
                      () {
                        List mainlist = getdata['data'];

                        if (mainlist.isNotEmpty) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(
                            mainlist.map((data) => Product.fromJson(data)).toList(),
                          );
                          allitems.addAll(items);

                          for (Product item in items) {
                            productList.where((i) => i.id == item.id).map(
                              (obj) {
                                allitems.remove(item);
                                return obj;
                              },
                            ).toList();
                          }
                          getAvailVarient(allitems);
                          notificationisloadmore = true;
                          notificationoffset = notificationoffset + perPage;
                        } else {
                          notificationisloadmore = false;
                        }
                      },
                    ),
                  );
                }
              } else {
                notificationisloadmore = false;
                if (mounted) {
                  setState(
                    () {},
                  );
                }
              }
            },
            onError: (error) {
              setsnackbar(
                error.toString(),
                context,
              );
            },
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, 'somethingMSg')!,
          context,
        );
        if (mounted) {
          setState(
            () {
              notificationisloadmore = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
          },
        );
      }
    }
  }

  _showContent() {
    return notificationisnodata
        ? getNoItem(context)
        : NotificationListener<ScrollNotification>(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 5,
                      start: 10,
                      end: 10,
                      top: 12,
                    ),
                    controller: notificationcontroller,
                    physics: const BouncingScrollPhysics(),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      Product? item;
                      try {
                        item = productList.isEmpty ? null : productList[index];
                        if (notificationisloadmore && index == (productList.length - 1) && notificationcontroller!.position.pixels <= 0) {
                          getProduct();
                        }
                      } on Exception catch (_) {}

                      return item == null ? Container() : listItem(index);
                    },
                  ),
                ),
                notificationisgettingdata
                    ? const Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: 5,
                          bottom: 5,
                        ),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            ),
          );
  }

  productDeletDialog(
    String productName,
    String id,
  ) async {
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
                style: Theme.of(this.context).textTheme.titleMedium!.copyWith(
                      color: fontColor,
                    ),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      getTranslated(context, "LOGOUTNO")!,
                      style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                            color: lightBlack,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                          color: fontColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    delProductApi(id);

                    setState(
                      () {
                        _searchText = "";
                        getProduct();
                      },
                    );
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
            setsnackbar(msg!, context);
          } else {
            setsnackbar(msg!, context);
          }
        },
        onError: (error) {},
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
    return null;
  }
}
