import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/transaction/transactionCubit.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:project/ui/widgets/noDataContainer.dart';
import 'package:project/ui/widgets/transactionContainer.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:project/utils/internetConnectivity.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  TransactionScreenState createState() => TransactionScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<TransactionCubit>(
              create: (_) => TransactionCubit(),
              child: const TransactionScreen(),
            ));
  }
}

class TransactionScreenState extends State<TransactionScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), transactionKey);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TransactionCubit>().hasMoreData()) {
        context.read<TransactionCubit>().fetchMoreTransactionData(perPage, context.read<AuthCubit>().getId(), transactionKey);
      }
    }
  }

  Widget noTransactionData(){
    return NoDataContainer(
                image: "transaction",
                title: UiUtils.getTranslatedLabel(context, noTransactionFoundLabel),
                subTitle: UiUtils.getTranslatedLabel(context, noTransactionFoundSubTitleLabel),
                width: width!,
                height: height!);
  }

  Widget transaction() {
    return BlocConsumer<TransactionCubit, TransactionState>(
        bloc: context.read<TransactionCubit>(),
        listener: (context, state) {
          if (state is TransactionFailure) {
            if(state.errorStatusCode.toString() == "102"){
              reLogin(context);
            }
          }
        },
        builder: (context, state) {
          if (state is TransactionProgress || state is TransactionInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is TransactionFailure) {
            return noTransactionData();
          }
          final transactionList = (state as TransactionSuccess).transactionList;
          final hasMore = state.hasMore;
          return transactionList.isEmpty?noTransactionData():SizedBox(
              height: height! / 1.1,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transactionList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (transactionList.length - 1)
                        ? const Center(child: CircularProgressIndicator())
                        : TransactionContainer(transactionModel: transactionList[index], height: height, width: width, index: index);
                  }));
        });
  }

  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> refreshList() async {
    context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), transactionKey);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, transactionLabel), const PreferredSize(preferredSize: Size.zero,child:SizedBox())),
              body: Container(
                padding: EdgeInsetsDirectional.only(top: height!/ 80.0),
                width: width,
                child: RefreshIndicator(
                    onRefresh: refreshList,
                    color: Theme.of(context).colorScheme.primary,
                    child: transaction()),
              ),
            ),
    );
  }
}
