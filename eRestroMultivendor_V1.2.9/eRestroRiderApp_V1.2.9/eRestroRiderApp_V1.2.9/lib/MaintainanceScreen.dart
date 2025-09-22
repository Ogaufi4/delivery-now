import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/Helper/Session.dart';

import 'Helper/Color.dart';

// ignore: must_be_immutable
class MaintainanceScreen extends StatelessWidget {
  MaintainanceScreen({Key? key}) : super(key: key);

  bool canPopNow = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPopNow,
      onPopInvokedWithResult: (popScope, dynamic) async {
        canPopNow = popScope;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  setSvgPath("maintenance"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    getTranslated(context, 'UNDER_MAINTAIN_LBL')!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Text(
                  getTranslated(context, 'UNDER_MAINTAIN_SUB_LBL')!,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: darkFontColor, fontWeight: FontWeight.w600, fontSize: 15),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
