import 'dart:async';
import 'dart:convert';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Helper/app_button.dart';
import 'package:project/Helper/session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/string.dart';
import '../Model/TransactionModel/Transaction_Model.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  List<TransactionModel> tranList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ScrollController controller = ScrollController();
  List<TransactionModel> tempList = [];

  @override
  void initState() {
    getTransaction();
    controller.addListener(
      _scrollListener,
    );

    buttonController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
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

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(
        getTranslated(
          context,
          "My Transactions",
        )!,
        context,
      ),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : showContent()
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
              title: getTranslated(
                context,
                'TRY_AGAIN_INT_LBL',
              ),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      getTransaction();
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> getTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          UserId: CUR_USERID,
        };
        Response response = await post(
          getTransactionsApi,
          headers: await ApiUtils.getHeaders(),
          body: parameter,
        ).timeout(
          const Duration(
            seconds: timeOut,
          ),
        );
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];

          if (!error) {
            total = int.parse(
              getdata["total"],
            );

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map(
                    (data) => TransactionModel.fromJson(data),
                  )
                  .toList();

              tranList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            if (getdata[statusCode] == "120") {
              reLogin(context);
            }
            isLoadingmore = false;
          }
        }
        if (mounted) {
          setState(
            () {
              _isLoading = false;
            },
          );
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, 'somethingMSg')!,
          context,
        );

        setState(
          () {
            _isLoading = false;
            isLoadingmore = false;
          },
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

  showContent() {
    return tranList.isEmpty
        ? getNoItem(context)
        : ListView.builder(
            shrinkWrap: true,
            controller: controller,
            itemCount: (offset < total) ? tranList.length + 1 : tranList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return (index == tranList.length && isLoadingmore)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primary,
                      ),
                    )
                  : listItem(index);
            },
          );
  }

  listItem(int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(
        5.0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "${getTranslated(context, "AMT_LBL")!} : ${tranList[index].amount!}",
                      style: const TextStyle(
                        color: fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    tranList[index].dateCreated!,
                  ),
                ],
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Text("${getTranslated(context, 'ORDER_ID_LBL')!} : ${tranList[index].orderId!}"),
                    ),
                  ],
                ),
              ),
              tranList[index].type != null && tranList[index].type!.isNotEmpty
                  ? Text(
                      "${getTranslated(context, "PAYMENT_MTHD")!} : ${tranList[index].type!}",
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: tranList[index].message != null && tranList[index].message!.isNotEmpty
                    ? Text(
                        "${getTranslated(context, "Message")!} : ${tranList[index].message!}",
                      )
                    : Container(),
              ),
              tranList[index].txnId != null && tranList[index].txnId!.isNotEmpty
                  ? Text(
                      "${getTranslated(
                        context,
                        'Tax ID',
                      )!} : ${tranList[index].txnId!}",
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent && !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;

              if (offset < total) getTransaction();
            },
          );
        }
      }
    }
  }
}
