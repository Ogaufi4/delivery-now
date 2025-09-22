import 'dart:async';
import 'package:project/Helper/color.dart';
import 'package:project/Helper/design.dart';
import 'package:project/Helper/dotted_border.dart';
import 'package:project/Helper/session.dart';
import 'package:project/Model/promoCodesModel.dart';
import 'package:project/Screen/manage_promocode.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../Helper/api_base_helper.dart';
import '../Helper/app_button.dart';
import '../Helper/constant.dart';
import '../Helper/string.dart';

class PromocodeList extends StatefulWidget {
  const PromocodeList({Key? key}) : super(key: key);

  @override
  _PromocodeListState createState() => _PromocodeListState();
}

class _PromocodeListState extends State<PromocodeList> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  String _searchText = "", _lastsearch = "";
  bool? isSearching;
  int scrollOffset = 0;
  ScrollController? scrollController;
  bool scrollLoadmore = true, scrollGettingData = false, scrollNodata = false;
  final TextEditingController _controller = TextEditingController();
  List<PromoCodesModel> promocodeList = [];
  Icon iconSearch = const Icon(
    Icons.search,
    color: primary,
    size: 25,
  );
  Widget? appBarTitle;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  List<PromoCodesModel> tempList = [];
  var inputStartFormat = DateFormat('yyyy-MM-dd');
  var outputStartFormat = DateFormat('dd,MMMM yyyy');
  var inputEndFormat = DateFormat('yyyy-MM-dd');
  var outputEndFormat = DateFormat('dd,MMMM yyyy');
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    scrollOffset = 0;
    Future.delayed(Duration.zero, getPromocode);

    Future.delayed(
      Duration.zero,
      () {
        appBarTitle = Text(
          getTranslated(context, "promoCode")!,
          style: const TextStyle(color: primary),
        );
      },
    );

    buttonController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );
    scrollController = ScrollController(
      keepScrollOffset: true,
    );
    scrollController!.addListener(
      _transactionscrollListener,
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

    _controller.addListener(
      () {
        if (_controller.text.isEmpty) {
          if (mounted) {
            setState(
              () {
                _searchText = "";
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

        if (_lastsearch != _searchText && (_searchText == '' || (_searchText.length > 2))) {
          _lastsearch = _searchText;
          scrollLoadmore = true;
          scrollOffset = 0;
          promocodeList = [];
          tempList.clear();
          getPromocode();
        }
      },
    );

    super.initState();
  }

  _transactionscrollListener() {
    if (scrollController!.offset >= scrollController!.position.maxScrollExtent && !scrollController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            scrollLoadmore = true;
            getPromocode();
          },
        );
      }
    }
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(
        () {
          scrollLoadmore = true;
          scrollGettingData = false;
          scrollNodata = false;
          scrollOffset = 0;
          if (scrollOffset == 0) {
            promocodeList = [];
          }
          _searchText = "";
          promocodeList.clear();
        },
      );
    }
    return getPromocode();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroun1,
      appBar: getAppbar(),
      floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundDark,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManagePromocode(),
              ),
            ).then((value) {
              if (value["status"] == false) {
                scrollLoadmore = true;
                scrollGettingData = false;
                scrollNodata = false;
                scrollOffset = 0;
                if (scrollOffset == 0) {
                  promocodeList = [];
                }
                getPromocode();
              }
            });
          }),
      body: _isNetworkAvail
          ? _showContent()
          : noInternet(
              context,
            ),
    );
  }

  void _handleSearchStart() {
    if (!mounted) return;
    setState(
      () {
        isSearching = true;
      },
    );
  }

  void _handleSearchEnd() {
    if (!mounted) return;
    setState(
      () {
        iconSearch = const Icon(
          Icons.search,
          color: primary,
          size: 25,
        );
        appBarTitle = Text(
          getTranslated(context, "promoCode")!,
          style: const TextStyle(
            color: primary,
          ),
        );
        isSearching = false;
        _controller.clear();
      },
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      ).then(
                        (value) {
                          setState(
                            () {},
                          );
                        },
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

  AppBar getAppbar() {
    return AppBar(
      title: appBarTitle,
      elevation: 5,
      titleSpacing: 0,
      iconTheme: const IconThemeData(
        color: primary,
      ),
      backgroundColor: white,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
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
          margin: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: shadow(),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              4,
            ),
            onTap: () {
              if (!mounted) return;
              setState(
                () {
                  if (iconSearch.icon == Icons.search) {
                    iconSearch = const Icon(
                      Icons.close,
                      color: primary,
                      size: 25,
                    );
                    appBarTitle = TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                        color: primary,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: primary,
                        ),
                        hintText: getTranslated(
                          context,
                          "Search",
                        ),
                        hintStyle: const TextStyle(
                          color: primary,
                        ),
                      ),
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(
                4.0,
              ),
              child: iconSearch,
            ),
          ),
        ),
      ],
    );
  }

  promocodeDeletDialog(String id) async {
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
                "${getTranslated(context, "sure")!}",
                style: Theme.of(this.context).textTheme.titleMedium!.copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTNO")!,
                    style: Theme.of(this.context).textTheme.titleSmall!.copyWith(color: lightBlack, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, "LOGOUTYES")!,
                    style: Theme.of(this.context).textTheme.titleSmall!.copyWith(color: fontColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    delPromocodeApi(id);
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  _showContent() {
    return scrollNodata
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              getNoItem(context),
            ],
          )
        : NotificationListener<ScrollNotification>(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                padding: const EdgeInsetsDirectional.only(
                  bottom: 5,
                  start: 10,
                  end: 10,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: promocodeList.length,
                itemBuilder: (context, index) {
                  try {
                    if (scrollLoadmore && index == (promocodeList.length - 1) && scrollController!.position.pixels <= 0) {
                      getPromocode();
                    }
                  } on Exception catch (_) {}

                  return (index == promocodeList.length && scrollGettingData)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : promocodeItem(index);
                },
              ),
            ),
          );
  }

  promocodeItem(int index) {
    PromoCodesModel model = promocodeList[index];
    var inputStartDate = inputStartFormat.parse(model.startDate!);
    var outputStartDate = outputStartFormat.format(inputStartDate);
    var inputEndDate = inputEndFormat.parse(model.endDate!);
    var outputEndDate = outputEndFormat.format(inputEndDate);

    return InkWell(
      borderRadius: BorderRadius.circular(
        4,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsetsDirectional.only(start: width / 80.0, top: height / 80.0, end: width / 80.0, bottom: height / 80.0),
            margin: EdgeInsetsDirectional.only(start: width / 40.0, end: width / 40.0),
            child: Row(
              children: [
                Container(
                    alignment: Alignment.center,
                    width: 52,
                    height: height / 5.15,
                    decoration: Design.boxDecorationContainerRoundHalf(
                      Theme.of(context).colorScheme.primary,
                      10,
                      10,
                      0,
                      0,
                    ),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(getTranslated(context, "discount")!,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal, fontSize: 14.0, letterSpacing: 6.3),
                          textAlign: TextAlign.center),
                    )),
                Expanded(
                  child: Container(
                    width: width,
                    height: height / 5.15,
                    decoration: Design.boxDecorationContainerRoundHalf(
                      white,
                      0,
                      0,
                      10,
                      10,
                    ),
                    padding: EdgeInsetsDirectional.only(start: width / 40.0, top: height / 80.0, bottom: height / 80.0, end: width / 40.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: FadeInImage(
                                    image: NetworkImage(model.image!),
                                    height: 40.0,
                                    width: 40.0,
                                    placeholder: placeHolder(40),
                                  )),
                              Container(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                                margin: EdgeInsetsDirectional.only(start: width / 60.0),
                                child: DottedBorder(
                                  color: Theme.of(context).colorScheme.primary,
                                  dashPattern: const [8, 4],
                                  padding: const EdgeInsets.all(5),
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.round,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(5.0),
                                  child: Text("${coupon} ${model.promoCode!}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / 80.0),
                          Text("${promocodeList[index].discount!}${percentSymbol} ${off} ${upTo} ${CUR_CURRENCY + model.maxDiscountAmt!}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal)),
                          const SizedBox(height: 5.0),
                          Text(promocodeList[index].message!,
                              style:
                                  const TextStyle(color: greayLightColor, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, fontSize: 10.0),
                              textAlign: TextAlign.left),
                          SizedBox(height: height / 80.0),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(getTranslated(context, "startDate")!,
                                          style: const TextStyle(
                                              color: greayLightColor, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, fontSize: 10.0),
                                          textAlign: TextAlign.left),
                                      Text(outputStartDate.toString(),
                                          style: const TextStyle(
                                              color: greayLightColor, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal, fontSize: 10.0),
                                          textAlign: TextAlign.left)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(getTranslated(context, "endDate")!,
                                          style: const TextStyle(
                                              color: greayLightColor, fontWeight: FontWeight.w500, fontStyle: FontStyle.normal, fontSize: 10.0),
                                          textAlign: TextAlign.left),
                                      Text(outputEndDate.toString(),
                                          style: const TextStyle(
                                              color: greayLightColor, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal, fontSize: 10.0),
                                          textAlign: TextAlign.left)
                                    ],
                                  ),
                                ),
                              ]),
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            bottom: 10,
            child: Container(alignment: Alignment.centerLeft, width: 21, height: 21, decoration: Design.circle(backgroun1)),
          ),
          Positioned(
            top: 10,
            bottom: 10,
            right: 0,
            child: Container(alignment: Alignment.centerLeft, width: 21, height: 21, decoration: Design.circle(backgroun1)),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
                onTap: () {
                  promocodeDeletDialog(model.id!);
                },
                child: Icon(Icons.delete, color: red)),
          )
        ],
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManagePromocode(
              id: promocodeList[index].id,
              start: promocodeList[index].startDate,
              end: promocodeList[index].endDate,
              discountTypeValue: promocodeList[index].discountType,
              repeatUsageValue: promocodeList[index].repeatUsage,
              statusValue: promocodeList[index].status,
              promoCodeValue: promocodeList[index].promoCode,
              messageValue: promocodeList[index].message,
              noOfUsersValue: promocodeList[index].noOfUsers,
              minimumOrderAmountValue: promocodeList[index].minOrderAmt,
              discountValue: promocodeList[index].discount,
              maxDiscountAmountValue: promocodeList[index].maxDiscountAmt,
              noOfRepeatUsageValue: promocodeList[index].noOfRepeatUsage,
              promoCodeImage: promocodeList[index].image,
              promocodeRelativePath: promocodeList[index].relativePath,
            ),
          ),
        ).then(
          (value) {
            print("value:${value["status"]}-----${value}-----${value["status"] == false}");
            if (value["status"] == false) {
              setState(
                () {
                  scrollLoadmore = true;
                  scrollGettingData = false;
                  scrollNodata = false;
                  scrollOffset = 0;
                  if (scrollOffset == 0) {
                    promocodeList = [];
                  }
                },
              );
              getPromocode();
            }
          },
        );
      },
    );
  }

  delPromocodeApi(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {
        resturantId: CUR_USERID!,
        "promocode_id": id,
      };
      apiBaseHelper.postAPICall(deletePromocodeApi, parameter, context).then(
        (getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            setsnackbar(msg!, context);
            scrollLoadmore = true;
            scrollGettingData = false;
            scrollNodata = false;
            scrollOffset = 0;
            if (scrollOffset == 0) {
              promocodeList = [];
            }
            _searchText = "";
            promocodeList.clear();
            getPromocode();
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> getPromocode() async {
    if (readOrder) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (scrollLoadmore) {
          if (mounted) {
            setState(
              () {
                scrollLoadmore = false;
                scrollGettingData = true;
                if (scrollOffset == 0) {
                  promocodeList = [];
                }
              },
            );
          }
          CUR_USERID = await getPrefrence(Id);
          CUR_USERNAME = await getPrefrence(Username);

          var parameter = {
            resturantId: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: scrollOffset.toString(),
            SEARCH: _searchText.trim(),
          };
          apiBaseHelper.postAPICall(getPromocodesApi, parameter, context).then(
            (getdata) async {
              bool error = getdata["error"];
              scrollGettingData = false;
              if (scrollOffset == 0) scrollNodata = error;
              if (!error) {
                tempList.clear();

                var data = getdata["data"];
                if (data.length != 0) {
                  tempList = (data as List)
                      .map(
                        (data) => PromoCodesModel.fromJson(data),
                      )
                      .toList();

                  promocodeList.addAll(tempList);
                  scrollLoadmore = true;
                  scrollOffset = scrollOffset + perPage;
                } else {
                  scrollLoadmore = false;
                }
              } else {
                scrollLoadmore = false;
              }
              if (mounted) {
                setState(
                  () {
                    scrollLoadmore = false;
                  },
                );
              }
            },
            onError: (error) {
              setsnackbar(error.toString(), context);
            },
          );
        }
      } else {
        if (mounted) {
          setState(
            () {
              _isNetworkAvail = false;
              scrollLoadmore = false;
            },
          );
        }
      }
      return;
    } else {
      setsnackbar(
        getTranslated(context, "You have not authorized permission for read order!!")!,
        context,
      );
    }
  }
}
