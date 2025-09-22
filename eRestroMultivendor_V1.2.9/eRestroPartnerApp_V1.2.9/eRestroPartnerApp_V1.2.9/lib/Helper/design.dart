import 'package:project/Helper/color.dart';
import 'package:flutter/widgets.dart';

class Design {
  static textField() {
    return BoxDecoration(color: textFieldBackground, border: Border.all(color: textFieldBorder), borderRadius: BorderRadius.circular(10));
  }

  static BoxDecoration circle(Color color) {
    return BoxDecoration(shape: BoxShape.circle, color: color);
  }

  static BoxDecoration boxDecorationContainerRoundHalf(Color color, double bradius1, double bradius2, double bradius3, double bradius4) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
    );
  }
}
