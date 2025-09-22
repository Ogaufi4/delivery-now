import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/styles/dotted_border.dart';
import 'package:project/ui/widgets/buttomContainer.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/ui/styles/color.dart';
import 'package:project/ui/styles/design.dart';
import 'package:project/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:project/utils/internetConnectivity.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  ReferAndEarnScreenState createState() => ReferAndEarnScreenState();
}

class ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
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

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child:
          _connectionStatus == connectivityCheck
              ? const NoInternetScreen()
              : Scaffold(
                appBar: DesignConfig.appBar(
                  context,
                  width,
                  UiUtils.getTranslatedLabel(context, referralAndEarnCodeLabel),
                  const PreferredSize(
                    preferredSize: Size.zero,
                    child: SizedBox(),
                  ),
                ),
                bottomNavigationBar:
                    context.read<SystemConfigCubit>().getReferCode().isEmpty
                        ? const SizedBox()
                        : ButtonContainer(
                          color: Theme.of(context).colorScheme.secondary,
                          height: height,
                          width: width,
                          text: UiUtils.getTranslatedLabel(
                            context,
                            shareAppLabel,
                          ),
                          start: width / 40.0,
                          end: width / 40.0,
                          bottom: height / 55.0,
                          top: 0,
                          status: false,
                          borderColor: Theme.of(context).colorScheme.secondary,
                          textColor: white,
                          onPressed: () {
                            // Use screen dimensions to position the share dialog at the bottom
                            final Size screenSize = MediaQuery.of(context).size;
                            var str =
                                "$appName\nRefer Code:${context.read<SystemConfigCubit>().getReferCode()}\n${Platform.isAndroid ? UiUtils.getTranslatedLabel(context, appFindLabel) : UiUtils.getTranslatedLabel(context, iosLabel)}${context.read<SystemConfigCubit>().getAppLink()}\n";
                            SharePlus.instance.share(
                              ShareParams(
                                text: str,
                                sharePositionOrigin: Rect.fromLTWH(
                                  0, // x: Left edge of the screen
                                  screenSize.height -
                                      10, // y: Slightly above the screen height
                                  screenSize
                                      .width, // Width of the entire screen
                                  10, // Non-zero height (small positive value)
                                ),
                              ),
                            );
                          },
                        ),
                body: Container(
                  margin: EdgeInsetsDirectional.only(top: height / 80.0),
                  decoration: DesignConfig.boxDecorationContainerHalf(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                  width: width,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsetsDirectional.only(
                      start: width / 20.0,
                      end: width / 20.0,
                      top: height / 99.0,
                    ),
                    width: width,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DesignConfig.setSvgPath("refer_and_earn"),
                            height: height / 3.0,
                            width: height / 3.0,
                            fit: BoxFit.scaleDown,
                          ),
                          SizedBox(height: height / 25.0),
                          Text(
                            UiUtils.getTranslatedLabel(
                              context,
                              referralAndEarnCodeLabel,
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.39,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            UiUtils.getTranslatedLabel(
                              context,
                              referralAndEarnCodeSubTitleLabel,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.39,
                            ),
                          ),
                          SizedBox(height: height / 55.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, yourCodeLabel),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 14,
                              letterSpacing: -0.21,
                            ),
                          ),
                          context
                                  .read<SystemConfigCubit>()
                                  .getReferCode()
                                  .isEmpty
                              ? const SizedBox()
                              : InkWell(
                                child: Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.10),
                                  margin: EdgeInsetsDirectional.only(
                                    start: width / 60.0,
                                    top: height / 80.0,
                                  ),
                                  child: DottedBorder(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    dashPattern: const [8, 4],
                                    padding: const EdgeInsets.all(8),
                                    strokeWidth: 1,
                                    strokeCap: StrokeCap.round,
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(5.0),
                                    child: Text(
                                      context
                                          .read<SystemConfigCubit>()
                                          .getReferCode(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge!.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          context
                                              .read<SystemConfigCubit>()
                                              .getReferCode(),
                                    ),
                                  );
                                  UiUtils.setSnackBar(
                                    UiUtils.getTranslatedLabel(
                                      context,
                                      referralCodeLabel,
                                    ),
                                    StringsRes.refercodeCopiedToClipboard,
                                    context,
                                    false,
                                    type: "1",
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
