import 'package:flutter/material.dart';

const MaterialColor primaryApp = MaterialColor(
  0xFF00A8B5, // ← Updated from 0xffdd4a48
  <int, Color>{
    50: primary,
    100: primary,
    200: primary,
    300: primary,
    400: primary,
    500: primary,
    600: primary,
    700: primary,
    800: primary,
    900: primary,
  },
);

const Color primary = Color(0xFF00A8B5); // ← Updated from 0xffdd4a48
const Color fontColor = Color(0xff212212);
const Color red = Color(0xffFF4D4D);
const Color grey = Color(0xff808080);
const Color grey1 = Color(0x80ffffff);
const Color lightBlack = Color(0xff52575C);
const Color backgroun1 = Color(0xfff6f6f6);
const Color backgroun2 = Color(0xffcccccc);

const Color lightBlack2 = Color(0xff999999);
const Color lightWhite = Color(0xffeeeeee);

const Color white = Color(0xffFFFFFF);
const Color black = Color(0xFF000000);

const Color offWhite = Color(0xfff5f5f5);
const Color backgroundDark = Color(0xff2c272e);
const Color lightFont = Color(0xffa5a5a5);
const Color textFieldBackground = Color(0xffECF2F7);
const Color textFieldBorder = Color.fromARGB(255, 221, 230, 237);
const Color greayLightColor = Color(0xff4f4f4f);
const Color commentBoxBorderColor = Color(0xffd7d7d7);
const Color cardColor = const Color(0xffDCDCDC);

//order status wish color code

const Color outForDeliveryOrderColor = const Color(0xff00C7E7); // ← Updated to match brand tone
const Color preparingOrderColor = const Color(0xffFFC107);
const Color deliveredOrderColor = const Color(0xff198754);
const Color cancelledOrderColor = const Color(0xffDC3545);
const Color processedOrderColor = const Color(0xff00A79F); // ← Updated to secondary brand color
const Color awaitingOrderColor = Colors.black; // ← Not changed (you said: don’t edit names or non-brand colors unless necessary)
const Color defaultOrderColor = const Color(0xff0D6EFD);