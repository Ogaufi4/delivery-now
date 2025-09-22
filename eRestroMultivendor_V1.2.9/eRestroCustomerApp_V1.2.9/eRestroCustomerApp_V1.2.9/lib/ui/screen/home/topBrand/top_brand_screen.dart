import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/app/routes.dart';
import 'package:project/cubit/address/cityDeliverableCubit.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/home/restaurants/topRestaurantCubit.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/widgets/topBrandContainer.dart';
import 'package:project/ui/widgets/simmer/topBrandSimmer.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/utils/internetConnectivity.dart';

class TopBrandScreen extends StatefulWidget {
  const TopBrandScreen({Key? key}) : super(key: key);

  @override
  TopBrandScreenState createState() => TopBrandScreenState();
}

class TopBrandScreenState extends State<TopBrandScreen> {
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  ScrollController topRestaurantController = ScrollController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
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
    topRestaurantController.addListener(topRestaurantScrollListener);
    topRestaurantApi();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  topRestaurantApi() {
    context.read<TopRestaurantCubit>().fetchTopRestaurant(
        perPage,
        "1",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
        context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
        context.read<AuthCubit>().getId(),
        "");
  }

  topRestaurantScrollListener() {
    if (topRestaurantController.position.maxScrollExtent == topRestaurantController.offset) {
      if (context.read<TopRestaurantCubit>().hasMoreData()) {
        context.read<TopRestaurantCubit>().fetchMoreTopRestaurantData(
            perPage,
            "1",
            context.read<CityDeliverableCubit>().getCityId(),
            context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
            context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
            context.read<AuthCubit>().getId(),
            "");
      }
    }
  }

  Widget topBrand() {
    return BlocConsumer<TopRestaurantCubit, TopRestaurantState>(
        bloc: context.read<TopRestaurantCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TopRestaurantProgress || state is TopRestaurantInitial) {
            return TopBrandSimmer(width: width!, height: height!, length: 5);
          }
          if (state is TopRestaurantFailure) {
            return Center(
                child: Text(
              state.errorMessage.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final topRestaurantList = (state as TopRestaurantSuccess).topRestaurantList;
          final hasMore = state.hasMore;
          return SizedBox(
            height: height! / 1.1,
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                controller: topRestaurantController,
                physics: const BouncingScrollPhysics(),
                itemCount: topRestaurantList.length,
                itemBuilder: (BuildContext context, index) {
                  return hasMore && index == (topRestaurantList.length - 1)
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ))
                      : InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(Routes.restaurantDetail, arguments: {'restaurant': topRestaurantList[index]});
                          },
                          child: TopBrandContainer(
                              index: index, topRestaurantList: topRestaurantList, height: height!, width: width!, from: "topBrandScreen"),
                        );
                }),
          );
        });
  }

  Future<void> refreshList() async {
    topRestaurantApi();
  }

  @override
  void dispose() {
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
              appBar: DesignConfig.appBar(context, width, UiUtils.getTranslatedLabel(context, topBrandsNearYouLabel),
                  const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                  height: height!,
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  padding: EdgeInsetsDirectional.only(start: width! / 60.0, end: width! / 20.0, top: height! / 99.0),
                  decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                  width: width,
                  child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: Theme.of(context).colorScheme.primary,
                      child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: topBrand()))),
            ),
    );
  }
}
