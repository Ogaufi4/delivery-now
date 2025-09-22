import 'package:flutter/cupertino.dart';

import 'color.dart';

// ignore: must_be_immutable
class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? size;

  SimBtn({Key? key, this.title, this.onBtnSelected, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * size!;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      child: Container(
        width: size,
        height: 35,
        alignment: FractionalOffset.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary],
            stops: [0, 1],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}
