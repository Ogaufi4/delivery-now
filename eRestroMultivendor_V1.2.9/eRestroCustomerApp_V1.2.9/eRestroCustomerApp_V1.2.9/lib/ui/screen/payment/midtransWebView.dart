import 'dart:async';
import 'dart:convert';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/cart/getCartCubit.dart';
import 'package:project/ui/screen/cart/cart_screen.dart';
import 'package:project/ui/screen/order/thank_you_for_order.dart';
import 'package:project/ui/styles/color.dart';
import 'package:project/ui/styles/design.dart';
import 'package:project/utils/api.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/string.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MidTrashWebview extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const MidTrashWebview({Key? key, this.url, this.from, this.msg, this.amt, this.orderId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MidTrashWebviewState();
  }
}

class MidTrashWebviewState extends State<MidTrashWebview> {
  String message = '';
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime? currentBackPressTime;

  late final WebViewController _controller;
  double? width, height;

  @override
  void initState() {
    webViewInitiliased();
    super.initState();
  }

  webViewInitiliased() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) async {
            setState(
              () {
                isloading = true;
              },
            );
            debugPrint('Page started loading: $url');
            String urlLink = url;
            String splitUrl = urlLink.split("${baseUrl}midtrans_payment_process?").toString();
            var mapConvertData =
                "${splitUrl.toString().replaceAll(" ", "").replaceAll(",", "").replaceAll("&", ",").replaceAll("=", ":").toString().replaceAll("[", "{").replaceAll("]", "}").replaceAll("{", "{\"").replaceAll("}", "\"}").replaceAll(":", "\":\"").replaceAll(",", "\",\"")}";
            final resultData = jsonDecode(mapConvertData);
            print("resultData:${resultData["status_code"]}");

            if (widget.from == "wallet") {
              if (resultData["status_code"] == "200" || resultData["status_code"] == "201") {
                String msg = await midtransWebhook(
                  widget.orderId!,
                );
                if (msg == 'Order id is not matched with transaction order id.') {
                  msg = 'Transaction Failed...!';
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg.toString(), context, false, type: "2");
                  Navigator.pop(context);
                } else {
                  msg = "Transaction Success..!";
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg.toString(), context, false, type: "1");
                  Navigator.pop(context);
                }
              }
            } else {
              print(
                  "statusCode:${resultData["status_code"]}--${resultData["status_code"] == "200" || resultData["status_code"] == "201"}--${resultData["status_code"] == "200" && resultData["status_code"] == "201"}");
              if (resultData["status_code"] == "200" || resultData["status_code"] == "201") {
                try {
                  var parameter = {
                    orderIdKey: resultData["order_id"],
                  };
                  await post(Uri.parse(Api.getMidtransTransactionStatusUrl), body: parameter, headers: Api.getHeaders())
                      .timeout(const Duration(seconds: 50))
                      .then(
                    (result) async {
                      var getdata = json.decode(result.body);
                      print("getdata:$getdata");
                      bool error = getdata['error'];
                      String? msg = getdata['message'];
                      var data = getdata['data'];
                      if (!error) {
                        String statuscode = data['status_code'];
                        print("getdata--:$statuscode");
                        if (statuscode == '404') {
                          deleteOrder(resultData["order_id"]);
                          if (mounted) {
                            setState(() {});
                          }
                        }

                        if (statuscode == '200' || statuscode == '201') {
                          String transactionStatus = data['transaction_status'];
                          print("getdata---:$transactionStatus");
                          String transactionId = data['transaction_id'];
                          if (transactionStatus == 'capture' || transactionStatus == 'settlement' || transactionStatus == 'pending') {
                            Map<String, dynamic> result = await updateOrderStatus(orderId: resultData["order_id"], status: pendingKey);
                            if (!result['error']) {
                              await addTransaction(
                                transactionId,
                                resultData["order_id"],
                                successKey,
                                "midtransMessage",
                                true,
                              );
                            } else {
                              UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), result['message'].toString(), context, false,
                                  type: "2");
                            }
                            if (mounted) {}
                          } else {
                            deleteOrder(resultData["order_id"]);
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        }
                      } else {
                        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg.toString(), context, false, type: "2");
                      }
                    },
                    onError: (error) {
                      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), error.toString(), context, false, type: "2");
                    },
                  );
                } on TimeoutException catch (_) {
                  UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
                }
              }
            }
            print(
                "url--:${splitUrl.toString().replaceAll(" ", "").replaceAll(",", "").replaceAll("&", ",").replaceAll("=", ":")}--${resultData["order_id"]}");
          },
          onPageFinished: (String url) {
            print("url::$url");
            if (url.contains("${baseUrl}midtrans_payment_process?")) {
              setState(
                () {
                  isloading = true;
                },
              );
            } else {
              setState(
                () {
                  isloading = false;
                },
              );
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                        ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('app/v1/api/midtrans_payment_process')) {
              if (mounted) {
                setState(
                  () {
                    isloading = true;
                  },
                );
              }
              String responseurl = request.url;
              if (responseurl.contains('Failed') || responseurl.contains('failed')) {
                if (mounted) {
                  setState(
                    () {
                      isloading = false;
                    },
                  );
                } else if (responseurl.contains('capture') || responseurl.contains('completed') || responseurl.toLowerCase().contains('success')) {
                  print("success web");
                }
              }

              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {},
      )
      ..loadRequest(Uri.parse(widget.url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  String convertUrl(String urldata) {
    String url = urldata;
    String splitUrl = url.split("${baseUrl}midtrans_payment_process?").toString();
    var mapConvertData =
        "${splitUrl.toString().replaceAll(" ", "").replaceAll(",", "").replaceAll("&", ",").replaceAll("=", ":").toString().replaceAll("[", "{").replaceAll("]", "}").replaceAll("{", "{\"").replaceAll("}", "\"}").replaceAll(":", "\":\"").replaceAll(",", "\",\"")}";
    return mapConvertData;
  }

  Future<Map<String, dynamic>> updateOrderStatus({required String status, required String orderId}) async {
    var parameter = {orderIdKey: orderId, statusKey: status};
    var response = await post(Uri.parse(Api.updateOrderStatusUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));
    print('order update status result****$response');
    var result = json.decode(response.body);
    print('order update status result****$result**$parameter');
    return {'error': result['error'], 'message': result['message']};
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      var parameter = {
        orderIdKey: orderId,
      };

      Response response = await post(Uri.parse(Api.deleteOrderUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));
      var getdata = json.decode(response.body);
      print('getdata*****delete order****$getdata');
      bool error = getdata['error'];
      if (!error) {}

      if (mounted) {
        setState(() {});
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");

      setState(() {});
    }
  }

  //call midtrans p[ayment success api
  static Future<String> midtranswWebHook({
    required Map<String, dynamic> apiParameter,
  }) async {
    try {
      Response response =
          await post(Uri.parse(Api.midtransWalletTransactionUrl), body: apiParameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));
      var result = json.decode(response.body.toString());
      return result['message'];
    } catch (e) {
      throw e;
    }
  }

  Future<String> midtransWebhook(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      var parameter = {
        orderIdKey: orderId,
      };

      String msg = await midtranswWebHook(
        apiParameter: parameter,
      );
      return msg;
    } catch (e) {
      return '';
    }
  }

  double total() {
    if (isUseWallet == true) {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryCharge + deliveryTip - promoAmt - walletBalanceUsed);
    } else {
      return (context.read<GetCartCubit>().getCartModel().overallAmount! + deliveryCharge + deliveryTip - promoAmt + walletBalanceUsed);
    }
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status, String? msg, bool redirect) async {
    print("stripe");
    try {
      var parameter = {
        userIdKey: context.read<AuthCubit>().getId(),
        orderIdKey: orderID,
        typeKey: paymentMethod,
        txnIdKey: tranId,
        amountKey: total().toStringAsFixed(2),
        statusKey: status,
        messageKey: msg
      };
      Response response =
          await post(Uri.parse(Api.addTransactionUrl), body: parameter, headers: Api.getHeaders()).timeout(const Duration(seconds: 50));

      var getdata = json.decode(response.body);
      print("data:$getdata-----$parameter");

      bool error = getdata["error"];

      if (!error) {
        if (redirect) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThankYouForOrderScreen(orderId: orderID.toString())),
          );
          context.read<GetCartCubit>().clearCartModel();
        }
      } else {
        if (getdata["status_code"].toString() == "102") {
          reLogin(context);
        }
        if (!mounted) return;
        UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), msg!, context, false, type: "2");
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, paymentLabel), StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        leading: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              DateTime now = DateTime.now();
              if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
                currentBackPressTime = now;
              }
              Navigator.of(context).pop();
            },
            child: Padding(
                padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                child: SvgPicture.asset(
                  DesignConfig.setSvgPath("back_icon"),
                  width: 32,
                  height: 32,
                  fit: BoxFit.scaleDown,
                ))),
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shadowColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(StringsRes.appName,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: PopScope(
        canPop: currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2) ? false : true,
        onPopInvokedWithResult: (value, dynamic) => onWillPop(value),
        child: Stack(
          children: <Widget>[
            WebViewWidget(controller: _controller),
            message.trim().isEmpty
                ? Container()
                : Center(
                    child: Container(
                      color: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'ubuntu',
                          color: white,
                        ),
                      ),
                    ),
                  ),
            isloading
                ? Center(
                    child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop(bool value) {
    DateTime now = DateTime.now();
    if (value) {
      return Future.value(true);
    } else {
      if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;

        return Future.value(false);
      }
      Navigator.pop(context, 'true');
      return Future.value(true);
    }
  }
}
