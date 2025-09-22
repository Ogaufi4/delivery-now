import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/app/routes.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project/ui/styles/design.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/screen/settings/no_location_screen.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:project/ui/styles/color.dart';

import 'package:project/utils/internetConnectivity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  late double width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  @override
  initState() {
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
            apicall();
          });
        });
      }
    });

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  apicall() {
    context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
  }

  void navigateToNextScreen() async {
    //Reading from settingsCubit means we are just reading current value of settingsCubit
    //if settingsCubit will change in future it will not rebuild it's child
    final currentSettings = context.read<SettingsCubit>().state.settingsModel;

    if (currentSettings!.showIntroSlider) {
      Navigator.of(context).pushReplacementNamed(Routes.introSlider);
    } else {
      if (currentSettings.skip) {
        Navigator.of(context).pushReplacementNamed(Routes.login, arguments: {'from': "splash"});
      } else {
        if (currentSettings.city.toString() != "" && currentSettings.city.toString() != "null") {
          Navigator.of(context).pushReplacementNamed(Routes.home);
        } else {
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => const NoLocationScreen(),
              ),
              (Route<dynamic> route) => false);
        }
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : BlocConsumer<SystemConfigCubit, SystemConfigState>(
              bloc: context.read<SystemConfigCubit>(),
              listener: (context, state) {
                if (state is SystemConfigFetchSuccess) {
                  navigateToNextScreen();
                }
                if (state is SystemConfigFetchFailure) {
                  print(state.errorCode);
                }
              },
              builder: (context, state) {
                if (state is SystemConfigFetchFailure) {
                  const SizedBox.shrink();
                }

                return Scaffold(
                    backgroundColor: splasBackgroundColor,
                    bottomNavigationBar: Container(
                      height: height / 9.0,
                      alignment: Alignment.center,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(UiUtils.getTranslatedLabel(context, madeByLabel),
                              style: const TextStyle(color: lightFontColor, fontSize: 10.0, fontWeight: FontWeight.w800)),
                          SizedBox(height: height / 60.0),
                          SvgPicture.asset(DesignConfig.setSvgPath("made_by")),
                        ],
                      )),
                    ),
                    body: Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: SvgPicture.asset(DesignConfig.setSvgPath("app_logo")),
                      ),
                    ));
              }),
    );
  }
}
