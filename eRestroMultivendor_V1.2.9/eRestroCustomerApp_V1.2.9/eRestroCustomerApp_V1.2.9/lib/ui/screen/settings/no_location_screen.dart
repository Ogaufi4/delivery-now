import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:project/app/routes.dart';
import 'package:project/cubit/address/getLocationDetailCubit.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project/data/model/addressModel.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/widgets/locationDialog.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/ui/styles/color.dart';
import 'package:project/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geolocator/geolocator.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:project/utils/internetConnectivity.dart';
import 'package:project/cubit/address/searchLocationCubit.dart';
import 'package:project/data/repositories/address/addressRepository.dart';
import 'package:project/cubit/address/cityDeliverableCubit.dart';

class NoLocationScreen extends StatefulWidget {
  const NoLocationScreen({Key? key}) : super(key: key);

  @override
  NoLocationScreenState createState() => NoLocationScreenState();
}

class NoLocationScreenState extends State<NoLocationScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  double? width, height;
  TextEditingController locationSearchController = TextEditingController(
    text: "",
  );
  Timer? _debounce;
  String? currentAddress = "";
  late LocatitonGeocoder geocoder;
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
    geocoder = LocatitonGeocoder(
      decodeBase64(context.read<SystemConfigCubit>().appReference()),
    );

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
    locationSearchController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  locationEnableDialog() async {
    if (context.read<SettingsCubit>().state.settingsModel!.city.toString() ==
            "" &&
        context.read<SettingsCubit>().state.settingsModel!.city.toString() ==
            "null") {
      getUserLocation();
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return LocationDialog(width: width, height: height);
        },
      );
    }
  }

  getUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        getUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        locationEnableDialog();
      } else {
        getUserLocation();
      }
    } else {
      try {
        if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
          demoModeAddressDefault(context, "0");
          context.read<SettingsCubit>().changeShowSkip();
          Navigator.of(context).pushReplacementNamed(Routes.home);
        } else {
          final LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
          );
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          );
          final placemarks = await geocoder.findAddressesFromCoordinates(
            Coordinates(position.latitude, position.longitude),
          );
          String? location =
              "${placemarks.first.addressLine},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.postalCode},${placemarks.first.countryName}";

          if (await Permission.location.serviceStatus.isEnabled) {
            if (mounted) {
              setState(() async {
                if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
                  demoModeAddressDefault(context, "0");
                } else {
                  setAddressForDisplayData(
                    context,
                    "0",
                    placemarks.first.locality ??
                        placemarks.first.subAdminArea!.toString(),
                    position.latitude.toString(),
                    position.longitude.toString(),
                    location.toString().replaceAll(",,", ","),
                  );
                }
                if (context
                            .read<SettingsCubit>()
                            .state
                            .settingsModel!
                            .city
                            .toString() !=
                        "" &&
                    context
                            .read<SettingsCubit>()
                            .state
                            .settingsModel!
                            .city
                            .toString() !=
                        "null") {
                  if (await Permission.location.serviceStatus.isEnabled) {
                    context.read<SettingsCubit>().changeShowSkip();
                    Navigator.of(context).pushReplacementNamed(Routes.home);
                  } else {
                    getUserLocation();
                  }
                } else {
                  getUserLocation();
                }
              });
            }
          } else {
            getUserLocation();
          }
        }
      } catch (e) {
        getUserLocation();
      }
    }
  }

  getCurrentUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        getCurrentUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        locationEnableDialog();
      } else {
        getCurrentUserLocation();
      }
    } else {
      try {
        if (await Permission.location.serviceStatus.isEnabled) {
          if (mounted) {
            Navigator.of(context).pushNamed(
              Routes.address,
              arguments: {'from': 'location', 'addressModel': AddressModel()},
            );
          }
        } else {
          getCurrentUserLocation();
        }
      } catch (e) {
        getCurrentUserLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child:
          _connectionStatus == connectivityCheck
              ? const NoInternetScreen()
              : Scaffold(
                body: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsetsDirectional.only(
                    start: width! / 10.0,
                    end: width! / 10.0,
                  ),
                  width: width,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          DesignConfig.setSvgPath("location"),
                          height: height! / 3.0,
                          width: height! / 3.0,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(height: height! / 20.0),
                        Text(
                          UiUtils.getTranslatedLabel(context, whoopsLabel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          UiUtils.getTranslatedLabel(
                            context,
                            noLocationSubTitleLabel,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            getUserLocation();
                          },
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                              top: height! / 10.0,
                            ),
                            padding: EdgeInsetsDirectional.only(
                              top: height! / 70.0,
                              bottom: 10.0,
                              start: width! / 20.0,
                              end: width! / 20.0,
                            ),
                            decoration: DesignConfig.boxDecorationContainer(
                              Theme.of(context).colorScheme.primary,
                              10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.gps_fixed,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                SizedBox(width: width! / 99.0),
                                Text(
                                  UiUtils.getTranslatedLabel(
                                    context,
                                    enableDeviceLocationLabel,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            bottomModelSheetShowLocation();
                          },
                          child: Container(
                            margin: EdgeInsetsDirectional.only(
                              top: height! / 40.0,
                            ),
                            padding: EdgeInsetsDirectional.only(
                              top: height! / 70.0,
                              bottom: 10.0,
                              start: width! / 20.0,
                              end: width! / 20.0,
                            ),
                            decoration:
                                DesignConfig.boxDecorationContainerBorder(
                                  Theme.of(context).colorScheme.primary,
                                  white,
                                  10.0,
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  UiUtils.getTranslatedLabel(
                                    context,
                                    enterLocationAreaCityEtcLabel,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  bottomModelSheetShowLocation() {
    showModalBottomSheet(
      isDismissible: false,
      backgroundColor: Colors.transparent,
      shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: (MediaQuery.of(context).size.height) / 1.14,
              padding: EdgeInsets.only(top: height! / 15.0),
              child: Container(
                decoration: DesignConfig.boxDecorationContainerRoundHalf(
                  white,
                  25,
                  0,
                  25,
                  0,
                ),
                child: Container(
                  padding: EdgeInsets.only(
                    left: width! / 15.0,
                    right: width! / 15.0,
                    top: height! / 25.0,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          UiUtils.getTranslatedLabel(
                            context,
                            selectALocationLabel,
                          ),
                          style: TextStyle(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        placesAutoCompleteTextField(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SvgPicture.asset(
                DesignConfig.setSvgPath("cancel_icon"),
                width: 32,
                height: 32,
              ),
            ),
          ],
        );
      },
    );
  }

  placesAutoCompleteTextField() {
    return BlocProvider(
      create: (context) => SearchLocationCubit(AddressRepository()),
      child: BlocConsumer<SearchLocationCubit, SearchLocationState>(
        listener: (context, state) {},
        builder: (context, searchState) {
          return Column(
            children: [
              // Search input
              Container(
                width: width,
                margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: locationSearchController,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  cursorHeight: 20,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width! / 25.0,
                      vertical: height! / 60.0,
                    ),
                    hintText: UiUtils.getTranslatedLabel(
                      context,
                      enterLocationAreaCityEtcLabel,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withValues(alpha: 0.7),
                      size: 24,
                    ),
                    suffixIcon:
                        locationSearchController.text.isNotEmpty
                            ? Container(
                              margin: EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary
                                      .withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                onPressed: () {
                                  locationSearchController.clear();
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<SearchLocationCubit>()
                                      .clearResults();
                                  setState(() {});
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 600), () {
                      debugPrint("Search input changed: $value");
                      if (value.isNotEmpty && value.length > 0) {
                        debugPrint(
                          "Triggering fetchSearchLocation for: $value",
                        );
                        context.read<SearchLocationCubit>().fetchSearchLocation(
                          value,
                        );
                      } else {
                        debugPrint("Clearing search results");
                        context.read<SearchLocationCubit>().clearResults();
                      }
                    });
                  },
                ),
              ),
              SizedBox(height: height! / 100.0),
              ListTile(
                visualDensity: const VisualDensity(vertical: -2),
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                leading: Padding(
                  padding: EdgeInsetsDirectional.only(start: 10),
                  child: Icon(
                    Icons.gps_fixed,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 18.0,
                ),
                title: Text(
                  UiUtils.getTranslatedLabel(context, useCurrentLocationLabel),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  getCurrentUserLocation();
                },
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: height! / 120.0),
                child: const Divider(color: textFieldBorder, height: 10.0),
              ),
              // Loading indicator
              if (searchState is SearchLocationLoading)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

              // Suggestion list
              if (searchState is SearchLocationSuccess &&
                  searchState.locations.isNotEmpty)
                Center(
                  child: Container(
                    width: width,
                    padding: EdgeInsetsDirectional.only(
                      top: height! / 80,
                      bottom: height! / 80,
                      start: width! / 40,
                      end: width! / 40,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    constraints: BoxConstraints(maxHeight: height! / 3),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: searchState.locations.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                      itemBuilder: (context, index) {
                        final location = searchState.locations[index];
                        debugPrint(
                          "Building ListTile for: ${location.placePrediction.structuredFormat.mainText.text}",
                        );

                        return ListTile(
                          horizontalTitleGap: 0,
                          dense: true,
                          visualDensity: const VisualDensity(
                            vertical: -4,
                            horizontal: -4,
                          ),
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.location_on,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondary.withValues(alpha: 0.7),
                            size: 20.0,
                          ),
                          title: Text(
                            location
                                .placePrediction
                                .structuredFormat
                                .mainText
                                .text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            location
                                .placePrediction
                                .structuredFormat
                                .secondaryText
                                .text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondary.withValues(alpha: 0.7),
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            debugPrint(
                              "Tapped on: " +
                                  location
                                      .placePrediction
                                      .structuredFormat
                                      .mainText
                                      .text,
                            );

                            String mainText =
                                location
                                    .placePrediction
                                    .structuredFormat
                                    .mainText
                                    .text;
                            String displayAddress = mainText;
                            if (location
                                .placePrediction
                                .structuredFormat
                                .secondaryText
                                .text
                                .isNotEmpty) {
                              displayAddress +=
                                  ", ${location.placePrediction.structuredFormat.secondaryText.text}";
                            }

                            locationSearchController.text = displayAddress;

                            context
                                .read<GetLoactionDetailCubit>()
                                .fetchLocationDetail(
                                  location.placePrediction.placeId,
                                );

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return BlocListener<
                                  GetLoactionDetailCubit,
                                  GetLocationDetailState
                                >(
                                  listener: (context, state) {
                                    if (state is GetLocationDetailSuccess) {
                                      Navigator.of(context).pop();

                                      final locationDetails =
                                          state.locationDetailsModel;
                                      String infoAddress = "";

                                      if (locationDetails.addressComponents !=
                                          null) {
                                        for (var component
                                            in locationDetails
                                                .addressComponents!) {
                                          if (component.types != null &&
                                              component.types!.isNotEmpty) {
                                            if (infoAddress.trim().isEmpty &&
                                                component.types!.contains(
                                                  'locality',
                                                ) &&
                                                component.longText != null &&
                                                component.longText!
                                                    .trim()
                                                    .isNotEmpty) {
                                              infoAddress =
                                                  component.longText!.trim();
                                              break;
                                            }
                                            if (infoAddress.trim().isEmpty &&
                                                component.types!.contains(
                                                  'administrative_area_level_1',
                                                ) &&
                                                component.longText != null &&
                                                component.longText!
                                                    .trim()
                                                    .isNotEmpty) {
                                              infoAddress =
                                                  component.longText!.trim();
                                              break;
                                            }
                                            if (infoAddress.trim().isEmpty &&
                                                component.types!.contains(
                                                  'administrative_area_level_2',
                                                ) &&
                                                component.longText != null &&
                                                component.longText!
                                                    .trim()
                                                    .isNotEmpty) {
                                              infoAddress =
                                                  component.longText!.trim();
                                              break;
                                            }
                                          }
                                        }
                                      }

                                      if (infoAddress.isEmpty &&
                                          locationDetails.name != null) {
                                        infoAddress = locationDetails.name!;
                                      }
                                      // Fallback: if infoAddress is empty or looks like a placeId, use mainText
                                      if (infoAddress.isEmpty ||
                                          infoAddress.startsWith('places/')) {
                                        infoAddress = mainText;
                                      }

                                      // Always set location data directly regardless of demo mode
                                      context
                                          .read<CityDeliverableCubit>()
                                          .fetchCityDeliverable(infoAddress);
                                      context.read<SettingsCubit>().setCity(
                                        infoAddress,
                                      );

                                      if (locationDetails.location != null) {
                                        context
                                            .read<SettingsCubit>()
                                            .setLatitude(
                                              locationDetails.location!.latitude
                                                  .toString(),
                                            );
                                        context
                                            .read<SettingsCubit>()
                                            .setLongitude(
                                              locationDetails
                                                  .location!
                                                  .longitude
                                                  .toString(),
                                            );
                                      }

                                      if (locationDetails.formattedAddress !=
                                          null) {
                                        context
                                            .read<SettingsCubit>()
                                            .setAddress(
                                              locationDetails.formattedAddress!,
                                            );
                                      }

                                      context
                                          .read<SettingsCubit>()
                                          .changeShowSkip();

                                      Future.delayed(Duration.zero, () {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed(Routes.home);
                                      });
                                    } else if (state
                                        is GetLocationDetailFailure) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error: ${state.errorMessage}",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            );

                            context.read<SearchLocationCubit>().clearResults();
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
