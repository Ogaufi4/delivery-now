import 'dart:convert';

import 'package:project/app/routes.dart';
import 'package:project/cubit/address/addressCubit.dart';
import 'package:project/cubit/address/cityDeliverableCubit.dart';
import 'package:project/cubit/auth/authCubit.dart';
import 'package:project/cubit/cart/getCartCubit.dart';
import 'package:project/cubit/favourite/favouriteProductsCubit.dart';
import 'package:project/cubit/favourite/favouriteRestaurantCubit.dart';
import 'package:project/cubit/home/restaurants/restaurantCubit.dart';
import 'package:project/cubit/home/restaurants/topRestaurantCubit.dart';
import 'package:project/cubit/home/sections/sectionsCubit.dart';
import 'package:project/cubit/order/activeOrderCubit.dart';
import 'package:project/cubit/settings/settingsCubit.dart';
import 'package:project/cubit/systemConfig/systemConfigCubit.dart';
import 'package:project/ui/screen/cart/cart_screen.dart';
import 'package:project/ui/screen/settings/maintenance_screen.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../cubit/order/orderCubit.dart';

const String appName = "eKonnect";
const String packageName = "com.konnect.erestro";
const String androidLink = 'https://play.google.com/store/apps/details?id=';

const String iosPackage = 'com.konnect.erestro';
const String iosLink = 'https://apps.apple.com/id';
const String iosAppId = '1617039216';

//Database related constants

//Add your admin panel url here
const String databaseUrl = 'https://flowbasetech.co.bw/konnect/app/v1/api/'; //demo url

const String baseUrl = '$databaseUrl';
const String perPage = "10";
const String defaulIsoCountryCode = 'BW';
const String defaulCountryCode = '+267';
const String reLoginStatusCode = "102";

const String googleAPiKeyAndroid = "AIzaSyDcu33j0cX-ywEHZntUev4fXQjAplcceYM";
const String googleAPiKeyIos = "PLACE_YOUR_IOS_API_KEY_HERE";

const String defaultErrorMessage = "Something went wrong!!";
const String connectivityCheck = "ConnectivityResult.none";
const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

//by default language of the app
const String defaultLanguageCode = "en";

const String defaultLatitude = "-24.6541";
const String defaultLongitude = "25.9309";
const String defaultCity = "Gaborone";
const String defaultAddress = "University of Botswana, Gaborone, Botswana";

// Default max length for phone number input
const int defaultPhoneNumberMaxLength = 8;

getUserLocation() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();

    getUserLocation();
  } else if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      await Geolocator.openLocationSettings();

      getUserLocation();
    } else {
      getUserLocation();
    }
  } else {}
}

appDataRefresh(BuildContext context) async {
  Future.delayed(Duration.zero, () async {
    await context.read<FavoriteRestaurantsCubit>().getFavoriteRestaurants(
      context.read<AuthCubit>().getId(),
      partnersKey,
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<FavoriteProductsCubit>().getFavoriteProducts(
      context.read<AuthCubit>().getId(),
      productsKey,
    );
  });
  Future.delayed(Duration.zero, () async {
    context.read<SystemConfigCubit>().getSystemConfig(
      context.read<AuthCubit>().getId(),
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<RestaurantCubit>().fetchRestaurant(
      perPage,
      "0",
      context.read<CityDeliverableCubit>().getCityId(),
      context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
      context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
      context.read<AuthCubit>().getId(),
      "",
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<TopRestaurantCubit>().fetchTopRestaurant(
      perPage,
      "1",
      context.read<CityDeliverableCubit>().getCityId(),
      context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
      context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
      context.read<AuthCubit>().getId(),
      "",
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<SectionsCubit>().fetchSections(
      perPage,
      context.read<AuthCubit>().getId(),
      context.read<SettingsCubit>().state.settingsModel!.latitude.toString(),
      context.read<SettingsCubit>().state.settingsModel!.longitude.toString(),
      context.read<CityDeliverableCubit>().getCityId(),
      "",
    );
  });

  Future.delayed(Duration.zero, () async {
    await context.read<GetCartCubit>().getCartUser(
      userId: context.read<AuthCubit>().getId(),
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<AddressCubit>().fetchAddress(
      context.read<AuthCubit>().getId(),
    );
  });
  Future.delayed(Duration.zero, () async {
    await context.read<SystemConfigCubit>().getSystemConfig(
      context.read<AuthCubit>().getId(),
    );
  });
  Future.delayed(Duration.zero, () async {
    context.read<OrderCubit>().fetchOrder(
      perPage,
      context.read<AuthCubit>().getId(),
      "",
      deliveredKey,
    );
    context.read<ActiveOrderCubit>().fetchActiveOrder(
      perPage,
      context.read<AuthCubit>().getId(),
      "",
      "$outForDeliveryKey,$preparingKey",
      "0",
    );
  });
}

isMaintenance(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => const MaintenanceScreen(),
    ),
  );
}

//Clear OfflineCart Data
clearOffLineCart(BuildContext context) {
  context.read<SettingsCubit>().setCartCount("0");
  context.read<SettingsCubit>().setCartTotal("0");
  context.read<SettingsCubit>().setRestaurantId("");
}

//Predefined reason of order cancel
List<String> reasonList = ["Delay in delivery", "Order by mistake", "Other"];

//When jwt key expire reLogin
reLogin(BuildContext context) {
  if (context.read<AuthCubit>().getType() == "google") {
    context.read<AuthCubit>().signOut(AuthProviders.google);
  } else if (context.read<AuthCubit>().getType() == "facebook") {
    context.read<AuthCubit>().signOut(AuthProviders.facebook);
  } else {
    context.read<AuthCubit>().signOut(AuthProviders.apple);
  }
  Navigator.of(context).pushNamedAndRemoveUntil(
    Routes.login,
    (Route<dynamic> route) => false,
    arguments: {'from': 'logout'},
  );
}

clearAll() {
  taxPercentage = 0;
  deliveryCharge = 10;
  deliveryTip = 0;
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

  promoAmt = 0;
  remWalBal = 0;
  walletBalanceUsed = 0;
  paymentMethod = '';
  promoCode = '';
  isPromoValid = false;
  isUseWallet = false;
  isPayLayShow = true;
  selectedMethod = null;
  orderTypeIndex = 0;
}

bool getStoreOpenStatus(String openTime, String closeTime) {
  bool result = false;

  DateTime now = DateTime.now();
  int nowHour = now.hour;
  int nowMin = now.minute;

  print('Now: H$nowHour M$nowMin $now');

  var openTimes = openTime.split(":");
  int openHour = int.parse(openTimes[0]);
  int openMin = int.parse(openTimes[1]);

  print('OpenTimes: H$openHour M$openMin $openTime');

  var closeTimes = closeTime.split(":");
  int closeHour = int.parse(closeTimes[0]);
  int closeMin = int.parse(closeTimes[1]);

  print('CloseTimes: H$closeHour M$closeMin $closeTime');

  TimeOfDay nowTime = TimeOfDay.now(); // or DateTime object
  TimeOfDay openingTime = TimeOfDay(
    hour: openHour,
    minute: openMin,
  ); // or leave as DateTime object
  TimeOfDay closingTime = TimeOfDay(
    hour: closeHour,
    minute: closeMin,
  ); // or leave as DateTime object

  int shopOpenTimeInSeconds = openingTime.hour * 60 + openingTime.minute;
  int shopCloseTimeInSeconds = closingTime.hour * 60 + closingTime.minute;
  int timeNowInSeconds = nowTime.hour * 60 + nowTime.minute;

  if (shopOpenTimeInSeconds <= timeNowInSeconds &&
      timeNowInSeconds <= shopCloseTimeInSeconds) {
    // OPEN;
    result = true;
  } else {
    // CLOSED;
    result = false;
  }

  print('time: $result');

  return result;
}

String? convertToAgo(BuildContext context, DateTime input, int from) {
  Duration diff = DateTime.now().difference(input);

  bool isNegative = diff.isNegative;
  if (diff.inDays >= 1 || (isNegative && diff.inDays < 1)) {
    if (from == 0) {
      var newFormat = DateFormat("MMM dd, yyyy");
      final newsDate1 = newFormat.format(input);
      return newsDate1;
    } else if (from == 1) {
      return "${diff.inDays} ${'days'} ${'ago'}";
    } else if (from == 2) {
      var newFormat = DateFormat("dd MMMM yyyy HH:mm:ss");
      final newsDate1 = newFormat.format(input);
      return newsDate1;
    }
  } else if (diff.inHours >= 1 || (isNegative && diff.inMinutes < 1)) {
    if (input.minute == 00) {
      return "${diff.inHours} ${'hours'} ${'ago'}";
    } else {
      if (from == 2) {
        return "${'about'} ${diff.inHours} ${'hours'} ${input.minute} ${'minutes'} ${'ago'}";
      } else {
        return "${diff.inHours} ${'hours'} ${input.minute} ${'minutes'} ${'ago'}";
      }
    }
  } else if (diff.inMinutes >= 1 || (isNegative && diff.inMinutes < 1)) {
    return "${diff.inMinutes} ${'minutes'} ${'ago'}";
  } else if (diff.inSeconds >= 1) {
    return "${diff.inSeconds} ${'seconds'} ${'ago'}";
  } else {
    return 'justNow';
  }
  return null;
}

demoModeAddressDefault(BuildContext context, String ifDelivery) {
  if (ifDelivery == "1") {
    context.read<CityDeliverableCubit>().fetchCityDeliverable("gaborone");
  }
context.read<SettingsCubit>().setCity("Gaborone");
context.read<SettingsCubit>().setLatitude("-24.6541");
context.read<SettingsCubit>().setLongitude("25.9087");
context.read<SettingsCubit>().setAddress("University of Botswana, Gaborone, Botswana");

}

setAddressForDisplayData(
  BuildContext context,
  String ifDelivery,
  String city,
  String latitude,
  String longitude,
  String address,
) {
  if (ifDelivery == "1") {
    context.read<CityDeliverableCubit>().fetchCityDeliverable(city.toString());
  }
  context.read<SettingsCubit>().setCity(city.toString());
  context.read<SettingsCubit>().setLatitude(latitude.toString());
  context.read<SettingsCubit>().setLongitude(longitude.toString());
  context.read<SettingsCubit>().setAddress(address.toString());
}

String extractAppId(String url) {
  final uri = Uri.parse(url);
  final pathSegments = uri.pathSegments;

  // Find the app ID in the last segment
  for (var segment in pathSegments) {
    if (segment.startsWith('id')) {
      return segment.substring(2); // Extract the number after 'id'
    }
  }
  return iosAppId;
}

String extractPackageName(String url) {
  final uri = Uri.parse(url);
  return uri.queryParameters['id'] ?? packageName;
}

// < 600 px mobile phone
// >=600 px tablet
extension DeviceTypeExtension on BuildContext {
  bool isDevicePhone() => MediaQuery.of(this).size.width < 600;
}

String decodeBase64(String base64String) {
  try {
    return utf8.decode(base64Decode(base64String));
  } catch (e) {
    return "Error decoding string: $e";
  }
}
