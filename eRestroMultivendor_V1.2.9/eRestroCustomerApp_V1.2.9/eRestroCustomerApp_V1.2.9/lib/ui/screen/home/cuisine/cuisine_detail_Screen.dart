import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/cubit/address/cityDeliverableCubit.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/home/cuisine/cuisineDetailCubit.dart';
import 'package:project/data/model/search_model.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/widgets/restaurantContainer.dart';
import 'package:project/ui/widgets/simmer/restaurantNearBySimmer.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/ui/styles/color.dart';
import 'package:project/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:project/utils/internetConnectivity.dart';

class CuisineDetailScreen extends StatefulWidget {
  final String? categoryId, name;
  const CuisineDetailScreen({Key? key, this.categoryId, this.name}) : super(key: key);

  @override
  CuisineDetailScreenState createState() => CuisineDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<CuisineDetailCubit>(
              create: (_) => CuisineDetailCubit(),
              child: CuisineDetailScreen(categoryId: arguments['categoryId'] as String, name: arguments['name'] as String),
            ));
  }
}

class CuisineDetailScreenState extends State<CuisineDetailScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? cuisineLength = "";
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
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
      fetchCuisineDetailApi();
    });
    super.initState();
  }

  fetchCuisineDetailApi() {
    context.read<CuisineDetailCubit>().fetchCuisineDetail(
        perPage,
        widget.categoryId!,
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        context.read<CityDeliverableCubit>().getCityId());
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<CuisineDetailCubit>().hasMoreData()) {
        context.read<CuisineDetailCubit>().fetchMoreCuisineDetailData(
            perPage,
            widget.categoryId!,
            context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
            context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
            context.read<AuthCubit>().getId(),
            context.read<CityDeliverableCubit>().getCityId());
      }
    }
  }

  Widget cuisineDetail() {
    return BlocConsumer<CuisineDetailCubit, CuisineDetailState>(
        bloc: context.read<CuisineDetailCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineDetailProgress || state is CuisineDetailInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is CuisineDetailFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(UiUtils.getTranslatedLabel(context, cuisineTitleLabel),
                    textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 28)),
                const SizedBox(height: 5.0),
                Text(UiUtils.getTranslatedLabel(context, cuisineSubTitleLabel),
                    textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: lightFont, fontSize: 14)),
              ]),
            );
          }
          final cuisineDetailList = (state as CuisineDetailSuccess).cuisineDetailList;
          cuisineLength = cuisineDetailList.length.toString();
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.1,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cuisineDetailList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && cuisineDetailList.isEmpty && index == (cuisineDetailList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : RestaurantContainer(restaurant: cuisineDetailList[index].partnerDetails![0], height: height!, width: width!);
                  }));
        });
  }

  Widget searchData() {
    return Container(
        height: height! / 25.2,
        margin: EdgeInsetsDirectional.only(top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: searchList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0, end: width! / 20.0, bottom: height! / 99.0),
                  margin: EdgeInsetsDirectional.only(end: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(searchList[index].title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8.0),
                      SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 10, height: 10),
                    ],
                  ));
            }));
  }

  Future<void> refreshList() async {
    fetchCuisineDetailApi();
  }

  @override
  void dispose() {
    searchController.dispose();
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
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
          : Scaffold(
              appBar: DesignConfig.appBar(context, width, widget.name!, const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: cuisineDetail()),
              ),
            ),
    );
  }
}
