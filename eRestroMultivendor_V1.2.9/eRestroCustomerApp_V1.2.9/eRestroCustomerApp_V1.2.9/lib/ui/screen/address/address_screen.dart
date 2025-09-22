import 'dart:async';
import 'dart:io';
//import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:project/app/routes.dart';
import 'package:project/cubit/address/getLocationDetailCubit.dart';
import 'package:project/cubit/address/searchLocationCubit.dart';
import 'package:project/cubit/address/updateAddressCubit.dart';
import 'package:project/cubit/address/addAddressCubit.dart';
import 'package:project/cubit/address/addressCubit.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project/data/model/addressModel.dart';
import 'package:project/data/repositories/address/addressRepository.dart';
import 'package:project/ui/screen/home/home_screen.dart';
import 'package:project/ui/styles/design.dart';
import 'package:project/ui/styles/color.dart';
import 'package:project/ui/widgets/buttomContainer.dart';
import 'package:project/ui/widgets/keyboardOverlay.dart';
import 'package:project/ui/widgets/pinAnimation.dart';
//import 'package:project/ui/widgets/simmer/mapLoadSimmer.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/labelKeys.dart';
import 'package:project/utils/string.dart';
import 'package:project/ui/screen/settings/no_internet_screen.dart';
import 'package:project/ui/widgets/locationDialog.dart';
import 'package:project/utils/internetConnectivity.dart';
import 'package:project/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:ui' as ui;
import 'package:location_geocoder/location_geocoder.dart';

class AddressScreen extends StatefulWidget {
  final AddressModel? addressModel;
  final String? from;
  const AddressScreen({Key? key, this.addressModel, this.from}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();

  static Route<AddressScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<AddAddressCubit>(
            create: (_) => AddAddressCubit(AddressRepository()),
          ),
          BlocProvider<UpdateAddressCubit>(
            create: (_) => UpdateAddressCubit(AddressRepository()),
          ),
        ],
        child: AddressScreen(
          addressModel: arguments['addressModel'],
          from: arguments['from'],
        ),
      ),
    );
  }
}

class _AddressScreenState extends State<AddressScreen> {
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  final Set<Marker> _markers = {};
  double? width, height;
  String? locationStatus = officeKey;
  late Position position;
  TextEditingController areaRoadApartmentNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController alternateMobileNumberController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  Timer? _debounce;
  TextEditingController locationSearchController = TextEditingController();
  String? states, country, pincode, latitude, longitude, address, city, area;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? countryCode = defaulCountryCode, alternetNumbercountryCode = defaulCountryCode;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  FocusNode alternetNumberFocusNode = FocusNode();
  FocusNode alternetNumberFocusNodeAndroid = FocusNode();
  late LocatitonGeocoder geocoder;

  @override
  void initState() {
    super.initState();
    // Initialize default location
    latlong = LatLng(double.parse(defaultLatitude), double.parse(defaultLongitude));
    _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);

    // Initialize connectivity
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _connectionStatus = results.isNotEmpty ? results : [ConnectivityResult.none];
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted && results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          if (mounted) {
            setState(() {
              _connectionStatus = value;
            });
          }
        });
      }
    });

    // Initialize geocoder
    try {
      geocoder = LocatitonGeocoder(decodeBase64(context.read<SystemConfigCubit>().appReference()));
    } catch (e) {
      UiUtils.setSnackBar("Error", "Failed to initialize geocoder: $e", context, false, type: "2");
    }

    // Initialize controllers and location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cityController.clear();
      if (widget.from == "updateAddress" && widget.addressModel != null) {
        locationStatus = widget.addressModel!.type;
        alternateMobileNumberController.text = widget.addressModel!.alternateMobile ?? "";
        phoneNumberController.text = widget.addressModel!.mobile ?? "";
        countryCode = widget.addressModel!.countryCode;
        areaRoadApartmentNameController.text = widget.addressModel!.area ?? "";
        addressController.text = widget.addressModel!.address ?? "";
        cityController.text = widget.addressModel!.city ?? "";
        landmarkController.text = widget.addressModel!.landmark ?? "";
        pinCodeController.text = widget.addressModel!.pincode ?? "";
      } else {
        phoneNumberController.text = context.read<AuthCubit>().getMobile();
        if (context.read<SettingsCubit>().state.settingsModel!.latitude.isNotEmpty &&
            context.read<SettingsCubit>().state.settingsModel!.longitude.isNotEmpty) {
          latlong = LatLng(
            double.parse(context.read<SettingsCubit>().state.settingsModel!.latitude),
            double.parse(context.read<SettingsCubit>().state.settingsModel!.longitude),
          );
          _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);
          city = context.read<SettingsCubit>().state.settingsModel!.city;
          addressController.text = context.read<SettingsCubit>().state.settingsModel!.address;
        }
      }
      getUserLocation();
    });

    // Focus listeners for keyboard overlay
    numberFocusNode.addListener(() {
      if (numberFocusNode.hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    alternetNumberFocusNode.addListener(() {
      if (alternetNumberFocusNode.hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });

    loadSearchAddressData();
  }

  Future<void> updateLocationFromCoordinates(LatLng coordinates) async {
    try {
      final placemarks = await geocoder.findAddressesFromCoordinates(Coordinates(coordinates.latitude, coordinates.longitude));
      if (mounted) {
        setState(() {
          states = placemarks.first.adminArea ?? "";
          country = placemarks.first.countryName ?? "";
          pincode = placemarks.first.postalCode ?? "";
          latitude = coordinates.latitude.toString();
          longitude = coordinates.longitude.toString();
          area = placemarks.first.subLocality ?? "";
          areaRoadApartmentNameController.text = placemarks.first.subLocality ?? "";
          address = placemarks.first.addressLine ?? "";
          addressController.text = placemarks.first.addressLine.toString();
          city = placemarks.first.locality ?? placemarks.first.subAdminArea!;
          cityController.text = placemarks.first.locality ?? placemarks.first.subAdminArea!;
          locationController.text = placemarks.first.addressLine.toString();
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId("Marker"),
            position: coordinates,
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        UiUtils.setSnackBar("Location", "Failed to fetch address: $e", context, false, type: "2");
      }
    }
  }

  Future<void> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        UiUtils.setSnackBar("Location", "Please enable location services in settings", context, false, type: "2");
        await defaultLocation();
        return;
      }
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        await defaultLocation();
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => LocationDialog(width: width, height: height),
        );
        return;
      }
    }

    try {
      final LocationSettings locationSettings = const LocationSettings(accuracy: LocationAccuracy.high);
      position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      if (mounted) {
        if (widget.from == "updateAddress" && widget.addressModel != null) {
          setState(() {
            latlong = LatLng(
              double.parse(widget.addressModel!.latitude!),
              double.parse(widget.addressModel!.longitude!),
            );
            _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);
            if (_controller != null) {
              _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
            }
            states = widget.addressModel!.state;
            country = widget.addressModel!.country;
            pincode = widget.addressModel!.pincode;
            latitude = widget.addressModel!.latitude;
            longitude = widget.addressModel!.longitude;
            area = widget.addressModel!.area;
            areaRoadApartmentNameController.text = widget.addressModel!.area ?? "";
            cityController.text = widget.addressModel!.city ?? "";
            addressController.text = widget.addressModel!.address ?? "";
            city = widget.addressModel!.city;
            locationController.text =
            "${widget.addressModel!.address},${widget.addressModel!.area},${widget.addressModel!.city},${widget.addressModel!.state},${widget.addressModel!.pincode}";
            _markers.clear();
            _markers.add(Marker(
              markerId: const MarkerId("Marker"),
              position: latlong!,
            ));
          });
        } else {
          await updateLocationFromCoordinates(LatLng(position.latitude, position.longitude));
          if (_controller != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        UiUtils.setSnackBar("Location", "Failed to get location: $e", context, false, type: "2");
        await defaultLocation();
      }
    }
  }

  Future<void> defaultLocation() async {
    latlong = LatLng(
      double.parse(context.read<SettingsCubit>().getSettings().latitude.isNotEmpty
          ? context.read<SettingsCubit>().getSettings().latitude
          : defaultLatitude),
      double.parse(context.read<SettingsCubit>().getSettings().longitude.isNotEmpty
          ? context.read<SettingsCubit>().getSettings().longitude
          : defaultLongitude),
    );
    _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);
    await updateLocationFromCoordinates(latlong!);
    if (_controller != null) {
      _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    }
  }

  void loadSearchAddressData() {
    final data = searchAddressBoxData.keys.map((key) {
      final value = searchAddressBoxData.get(key);
      return {
        "key": key,
        "city": value["city"],
        "latitude": value['latitude'],
        "longitude": value['longitude'],
        "address": value['address'],
      };
    }).toList();
    if (mounted) {
      setState(() {
        searchAddressData = data.reversed.toList();
      });
    }
  }

  Future<void> addSearchAddress(Map<String, dynamic> newItem) async {
    await searchAddressBoxData.add(newItem);
    loadSearchAddressData();
  }

  void completeAddressShow() {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setState) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: EdgeInsets.only(top: height! / 15.0),
                  child: Container(
                    margin: EdgeInsets.only(top: height! / 15.0),
                    decoration: DesignConfig.boxDecorationContainerRoundHalf(
                      Theme.of(context).colorScheme.onSurface,
                      25,
                      0,
                      25,
                      0,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: height! / 25.0),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            addressField(),
                            areaRoadApartmentNameField(),
                            mobileNumberField(),
                            alternateMobileNumberField(),
                            landmarkField(),
                            cityField(),
                            if (pincode == "") pinCodeField(),
                            Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                              child: Text(
                                UiUtils.getTranslatedLabel(context, tagThisLocationForLaterLabel),
                                style: const TextStyle(fontSize: 14.0, color: greayLightColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                            tagLocation(setState),
                            widget.from == "updateAddress"
                                ? BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                              bloc: context.read<UpdateAddressCubit>(),
                              listener: (context, state) {
                                if (state is UpdateAddressSuccess) {
                                  context.read<AddressCubit>().editAddress(state.addressModel);
                                  Navigator.pop(context);
                                  Future.delayed(const Duration(milliseconds: 100)).then((value) {
                                    Navigator.pop(context);
                                  });
                                } else if (state is UpdateAddressFailure) {
                                  if (state.errorStatusCode.toString() == "102") {
                                    reLogin(context);
                                  }
                                  Navigator.pop(context);
                                  UiUtils.setSnackBar(
                                    UiUtils.getTranslatedLabel(context, addressLabel),
                                    state.errorMessage,
                                    context,
                                    false,
                                    type: "2",
                                  );
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: width!,
                                  child: ButtonContainer(
                                    color: Theme.of(context).colorScheme.secondary,
                                    height: height,
                                    width: width,
                                    text: state is UpdateAddressProgress
                                        ? UiUtils.getTranslatedLabel(context, updateIngLocationLabel)
                                        : UiUtils.getTranslatedLabel(context, updateLocationLabel),
                                    start: width! / 40.0,
                                    end: width! / 40.0,
                                    bottom: height! / 55.0,
                                    top: 0,
                                    status: false,
                                    borderColor: Theme.of(context).colorScheme.secondary,
                                    textColor: white,
                                    onPressed: () {
                                      context.read<UpdateAddressCubit>().fetchUpdateAddress(
                                        widget.addressModel!.id!,
                                        context.read<AuthCubit>().getId(),
                                        phoneNumberController.text,
                                        addressController.text,
                                        cityController.text,
                                        latitude ?? "",
                                        longitude ?? "",
                                        areaRoadApartmentNameController.text,
                                        locationStatus,
                                        context.read<AuthCubit>().getName(),
                                        countryCode.toString().replaceAll("+", ""),
                                        alternetNumbercountryCode.toString().replaceAll("+", ""),
                                        alternateMobileNumberController.text,
                                        landmarkController.text,
                                        pincode == "" ? pinCodeController.text : pincode!,
                                        states ?? "",
                                        country ?? "",
                                        "0",
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                                : BlocConsumer<AddAddressCubit, AddAddressState>(
                              bloc: context.read<AddAddressCubit>(),
                              listener: (context, state) {
                                if (state is AddAddressSuccess) {
                                  context.read<AddressCubit>().addAddress(state.addressModel);
                                  if (widget.from == "login") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(milliseconds: 100)).then((value) {
                                      Navigator.pop(context);
                                    });
                                  }
                                } else if (state is AddAddressFailure) {
                                  if (state.errorStatusCode.toString() == "102") {
                                    reLogin(context);
                                  }
                                  Navigator.pop(context);
                                  UiUtils.setSnackBar(
                                    UiUtils.getTranslatedLabel(context, addressLabel),
                                    state.errorMessage,
                                    context,
                                    false,
                                    type: "2",
                                  );
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: width!,
                                  child: ButtonContainer(
                                    color: Theme.of(context).colorScheme.secondary,
                                    height: height,
                                    width: width,
                                    text: state is AddAddressProgress
                                        ? UiUtils.getTranslatedLabel(context, addingLocationLabel)
                                        : UiUtils.getTranslatedLabel(context, confirmLocationLabel),
                                    start: width! / 40.0,
                                    end: width! / 40.0,
                                    bottom: height! / 55.0,
                                    top: 0,
                                    status: false,
                                    borderColor: Theme.of(context).colorScheme.secondary,
                                    textColor: white,
                                    onPressed: () {
                                      context.read<AddAddressCubit>().fetchAddAddress(
                                        context.read<AuthCubit>().getId(),
                                        phoneNumberController.text,
                                        addressController.text,
                                        cityController.text,
                                        latitude ?? "",
                                        longitude ?? "",
                                        areaRoadApartmentNameController.text,
                                        locationStatus,
                                        context.read<AuthCubit>().getName(),
                                        countryCode.toString(),
                                        alternetNumbercountryCode.toString(),
                                        alternateMobileNumberController.text,
                                        landmarkController.text,
                                        pincode == "" ? pinCodeController.text : pincode!,
                                        states ?? "",
                                        country ?? "",
                                        widget.from == "login" ? "1" : "0",
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _connectivitySubscription.cancel();
    _controller?.dispose();
    locationController.dispose();
    areaRoadApartmentNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    alternateMobileNumberController.dispose();
    pinCodeController.dispose();
    landmarkController.dispose();
    numberFocusNode.dispose();
    numberFocusNodeAndroid.dispose();
    alternetNumberFocusNode.dispose();
    alternetNumberFocusNodeAndroid.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget cityField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 40.0, end: width! / 20.0),
      child: TextFormField(
        controller: cityController,
        cursorColor: lightFont,
        decoration: DesignConfig.inputDecorationextField(
          UiUtils.getTranslatedLabel(context, cityLabel),
          UiUtils.getTranslatedLabel(context, enterCityLabel),
          width!,
          context,
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget pinCodeField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 40.0, end: width! / 20.0),
      child: TextFormField(
        controller: pinCodeController,
        cursorColor: lightFont,
        textInputAction: TextInputAction.done,
        decoration: DesignConfig.inputDecorationextField(
          UiUtils.getTranslatedLabel(context, pinCodeLabel),
          UiUtils.getTranslatedLabel(context, enterpinCodeLabel),
          width!,
          context,
        ),
        keyboardType: TextInputType.number,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget addressField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 40.0, end: width! / 20.0),
      child: TextField(
        controller: addressController,
        cursorColor: greayLightColor,
        decoration: DesignConfig.inputDecorationextField(
          UiUtils.getTranslatedLabel(context, addressLabel),
          UiUtils.getTranslatedLabel(context, enterAddressLabel),
          width!,
          context,
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget areaRoadApartmentNameField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 40.0, end: width! / 20.0),
      child: TextField(
        controller: areaRoadApartmentNameController,
        cursorColor: greayLightColor,
        decoration: DesignConfig.inputDecorationextField(
          UiUtils.getTranslatedLabel(context, areaRoadApartmentNameLabel),
          UiUtils.getTranslatedLabel(context, enterAreaRoadApartmentNameLabel),
          width!,
          context,
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget alternateMobileNumberField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 80.0, end: width! / 20.0),
      child: IntlPhoneField(
        controller: alternateMobileNumberController,
        textInputAction: TextInputAction.done,
        dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: greayLightColor)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.primary)),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.primary)),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: greayLightColor)),
          focusColor: white,
          counterStyle: const TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, enterAlternateMobileNumberLabel),
          labelStyle: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
          hintStyle: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
        ),
        flagsButtonMargin: EdgeInsets.all(width! / 40.0),
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        focusNode: Platform.isIOS ? alternetNumberFocusNode : alternetNumberFocusNodeAndroid,
        dropdownIconPosition: IconPosition.trailing,
        initialCountryCode: defaulIsoCountryCode,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
        textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
        onChanged: (phone) {
          if (mounted) {
            setState(() {
              alternetNumbercountryCode = phone.countryCode;
            });
          }
        },
      ),
    );
  }

  Widget mobileNumberField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 80.0, end: width! / 20.0),
      child: IntlPhoneField(
        controller: phoneNumberController,
        textInputAction: TextInputAction.done,
        dropdownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: greayLightColor)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.primary)),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: Theme.of(context).colorScheme.primary)),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.0, color: greayLightColor)),
          focusColor: white,
          counterStyle: const TextStyle(color: white, fontSize: 0),
          border: InputBorder.none,
          hintText: UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
          labelStyle: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
          hintStyle: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
        ),
        flagsButtonMargin: EdgeInsets.all(width! / 40.0),
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
        dropdownIconPosition: IconPosition.trailing,
        initialCountryCode: defaulIsoCountryCode,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
        textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
        onChanged: (phone) {
          if (mounted) {
            setState(() {
              countryCode = phone.countryCode;
            });
          }
        },
      ),
    );
  }

  Widget landmarkField() {
    return Container(
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 99.0),
      margin: EdgeInsetsDirectional.only(bottom: height! / 40.0, end: width! / 20.0),
      child: TextField(
        controller: landmarkController,
        cursorColor: greayLightColor,
        decoration: DesignConfig.inputDecorationextField(
          UiUtils.getTranslatedLabel(context, landmarkLabel),
          UiUtils.getTranslatedLabel(context, enterLandmarkLabel),
          width!,
          context,
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(color: greayLightColor, fontSize: 14.0, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget tagLocation(StateSetter setState) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: width! / 40.0, top: height! / 99.0, start: width! / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
              onPressed: () => setState(() => locationStatus = homeKey),
              child: Container(
                width: width,
                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                decoration: locationStatus == homeKey
                    ? DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 5.0)
                    : DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                child: Text(
                  UiUtils.getTranslatedLabel(context, homeLabel),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(color: locationStatus == homeKey ? white : lightFont, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
              onPressed: () => setState(() => locationStatus = officeKey),
              child: Container(
                width: width!,
                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                decoration: locationStatus == officeKey
                    ? DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 5.0)
                    : DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                child: Text(
                  UiUtils.getTranslatedLabel(context, officeLabel),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(color: locationStatus == officeKey ? white : lightFont, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
              onPressed: () => setState(() => locationStatus = otherKey),
              child: Container(
                width: width!,
                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                decoration: locationStatus == otherKey
                    ? DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 5.0)
                    : DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 5.0),
                child: Text(
                  UiUtils.getTranslatedLabel(context, otherLabel),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(color: locationStatus == otherKey ? white : lightFont, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget locationChange() {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 10.0),
      padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
          SizedBox(width: height! / 99.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.toString(),
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                ),
                Text(
                  addressController.text,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget placesAutoCompleteTextField() {
    return BlocProvider(
      create: (context) => SearchLocationCubit(AddressRepository()),
      child: BlocConsumer<SearchLocationCubit, SearchLocationState>(
        listener: (context, state) {},
        builder: (context, searchState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(top: height! / 40.0, bottom: height! / 45.0, start: width! / 40.0, end: width! / 25.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 24, height: 24, fit: BoxFit.scaleDown),
                    ),
                    const SizedBox(width: 5.0),
                    Expanded(
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.2), width: 1),
                        ),
                        child: TextField(
                          controller: locationSearchController,
                          style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w400),
                          cursorColor: Theme.of(context).colorScheme.primary,
                          cursorHeight: 20,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: width! / 25.0, vertical: height! / 60.0),
                            hintText: UiUtils.getTranslatedLabel(context, enterLocationAreaCityEtcLabel),
                            hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7), size: 24),
                            suffixIcon: locationSearchController.text.isNotEmpty
                                ? Container(
                              margin: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7), size: 20),
                                onPressed: () {
                                  locationSearchController.clear();
                                  FocusScope.of(context).unfocus();
                                  context.read<SearchLocationCubit>().clearResults();
                                  if (mounted) setState(() {});
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              ),
                            )
                                : null,
                          ),
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false) _debounce!.cancel();
                            _debounce = Timer(const Duration(milliseconds: 600), () {
                              if (value.isNotEmpty) {
                                context.read<SearchLocationCubit>().fetchSearchLocation(value);
                              } else {
                                context.read<SearchLocationCubit>().clearResults();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (searchState is SearchLocationLoading)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                ),
              if (searchState is SearchLocationSuccess && searchState.locations.isNotEmpty && locationSearchController.text.isNotEmpty)
                Container(
                  width: width,
                  margin: EdgeInsetsDirectional.only(start: width! / 20, end: width! / 20),
                  padding: EdgeInsetsDirectional.only(bottom: height! / 80, start: width! / 40, end: width! / 40),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.1), width: 1),
                  ),
                  constraints: BoxConstraints(maxHeight: height! / 2),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: searchState.locations.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).colorScheme.surface),
                    itemBuilder: (context, index) {
                      final location = searchState.locations[index];
                      final mainText = location.placePrediction.structuredFormat.mainText.text;
                      final secondaryText = location.placePrediction.structuredFormat.secondaryText.text;
                      return Column(
                        children: [
                          ListTile(
                            horizontalTitleGap: 0,
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7), size: 20.0),
                            title: Text(
                              mainText,
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                secondaryText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              context.read<SearchLocationCubit>().clearResults();
                              FocusManager.instance.primaryFocus?.unfocus();
                              String displayAddress = mainText;
                              if (secondaryText.isNotEmpty) {
                                displayAddress += ", $secondaryText";
                              }
                              locationSearchController.text = displayAddress;
                              context.read<GetLoactionDetailCubit>().fetchLocationDetail(location.placePrediction.placeId);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return BlocListener<GetLoactionDetailCubit, GetLocationDetailState>(
                                    listener: (context, state) {
                                      if (state is GetLocationDetailSuccess) {
                                        Navigator.of(context).pop();
                                        final details = state.locationDetailsModel;
                                        address = details.formattedAddress;
                                        addressController.text = details.formattedAddress ?? '';
                                        locationController.text = details.formattedAddress ?? '';
                                        if (details.location != null) {
                                          latitude = details.location!.latitude.toString();
                                          longitude = details.location!.longitude.toString();
                                          latlong = LatLng(details.location!.latitude!, details.location!.longitude!);
                                          _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);
                                          if (_controller != null) {
                                            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                                          }
                                          if (details.addressComponents != null) {
                                            for (var component in details.addressComponents!) {
                                              if (component.types != null &&
                                                  component.types!.isNotEmpty &&
                                                  component.types!.contains('locality') &&
                                                  component.longText != null &&
                                                  component.longText!.trim().isNotEmpty) {
                                                city = component.longText!.trim();
                                                break;
                                              }
                                            }
                                          }
                                          if (city == null || city!.isEmpty) {
                                            city = mainText;
                                          }
                                        }
                                        if (mounted) setState(() {});
                                      } else if (state is GetLocationDetailFailure) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: ${state.errorMessage}")),
                                        );
                                      }
                                    },
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                },
                              );
                            },
                          ),
                          Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 16.0, endIndent: 16.0),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _checkPermission(Function callback) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationDialog(width: width, height: height),
      );
    } else {
      await callback();
      if (mounted) {
        setState(() {
          latlong = LatLng(position.latitude, position.longitude);
          _cameraPosition = CameraPosition(target: latlong!, zoom: 14.4746);
          if (_controller != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : PopScope(
      canPop: false,
      onPopInvokedWithResult: (value, dynamic) {
        Future.delayed(const Duration(milliseconds: 100)).then((value) => Navigator.pop(context));
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: latlong == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            SizedBox(
              height: height! / 1.27,
              child: Stack(
                children: [
                  SafeArea(
                    child: GoogleMap(
                      markers: _markers,
                      onCameraMove: (position) => _cameraPosition = position,
                      onCameraIdle: () {
                        if (latlong != _cameraPosition.target) {
                          latlong = _cameraPosition.target;
                          updateLocationFromCoordinates(latlong!);
                        }
                      },
                      zoomControlsEnabled: false,
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      compassEnabled: false,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: _cameraPosition,
                      gestureRecognizers: {
                        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                        Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                      },
                      onTap: (latLng) {
                        _controller?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                      },
                    ),
                  ),
                  PinAnimation(color: Theme.of(context).colorScheme.primary),
                  Center(child: SvgPicture.asset(DesignConfig.setSvgPath('other_address'), width: 35, height: 35)),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: width! / 90.0,
                    top: height! / 1.6,
                    child: InkWell(
                      onTap: () => _checkPermission(() async => await getUserLocation()),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        decoration: DesignConfig.boxDecorationContainerBorder(lightFont, Theme.of(context).colorScheme.onSurface, 10.0),
                        child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary, size: 35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 1.45),
                decoration: DesignConfig.boxCurveShadow(Theme.of(context).colorScheme.onSurface),
                width: width,
                child: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                          child: Text(
                            UiUtils.getTranslatedLabel(context, selectDeliveryLocationLabel),
                            style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 60.0, bottom: height! / 40.0),
                          child: Divider(color: lightFont.withValues(alpha: 0.10), height: 0.2, thickness: 0.2, endIndent: width! / 20.0, indent: width! / 20.0),
                        ),
                        locationChange(),
                        Padding(
                          padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 40.0),
                          child: Divider(color: lightFont.withValues(alpha: 0.10), height: 0.2, thickness: 0.2, endIndent: width! / 20.0, indent: width! / 20.0),
                        ),
                        SizedBox(
                          width: width!,
                          child: ButtonContainer(
                            color: Theme.of(context).colorScheme.secondary,
                            height: height,
                            width: width,
                            text: (widget.from == "location" || widget.from == "change")
                                ? UiUtils.getTranslatedLabel(context, confirmLocationLabel)
                                : UiUtils.getTranslatedLabel(context, enterCompleteAddressLocationLabel),
                            start: width! / 40.0,
                            end: width! / 40.0,
                            bottom: height! / 55.0,
                            top: 0,
                            status: false,
                            borderColor: Theme.of(context).colorScheme.secondary,
                            textColor: white,
                            onPressed: () {
                              if (widget.from == "location" || widget.from == "change") {
                                if (city == null || city!.isEmpty) {
                                  UiUtils.setSnackBar(
                                    UiUtils.getTranslatedLabel(context, addressLabel),
                                    StringsRes.sorryWeAreNotDeliveryFoodOnCurrentLocation,
                                    context,
                                    false,
                                    type: "2",
                                  );
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      if (context.read<SystemConfigCubit>().getDemoMode() == "0") {
                                        demoModeAddressDefault(context, "1");
                                      } else {
                                        setAddressForDisplayData(context, "1", city.toString(), latitude!, longitude!, address.toString());
                                      }
                                      addSearchAddress({
                                        "city": city.toString(),
                                        "latitude": latitude.toString(),
                                        "longitude": longitude.toString(),
                                        "address": address.toString(),
                                      }).then((value) {
                                        if (widget.from == "location") {
                                          context.read<SettingsCubit>().changeShowSkip();
                                          Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
                                        } else if (widget.from == "change") {
                                          Navigator.of(context).pop();
                                          Future.delayed(const Duration(milliseconds: 300), () {
                                            Navigator.of(context).pushReplacementNamed(Routes.home);
                                          });
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      });
                                    });
                                  }
                                }
                              } else {
                                completeAddressShow();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: height! / 99.0,
              start: 0,
              end: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Expanded(child: placesAutoCompleteTextField())],
              ),
            ),
          ],
        ),
      ),
    );
  }
}