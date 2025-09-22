import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/SimBtn.dart';
import 'Helper/String.dart';
import 'Home.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

String? lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {
  String name = "",
      email = "",
      mobile = "",
      address = "",
      curPass = "",
      newPass = "",
      confPass = "",
      commMethod = '',
      comm = '',
      active = '0',
      balance = '',
      token = '';

  String? profileImageUrl;
  File? _profileImage;

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? nameC,
      emailC,
      mobileC,
      addressC,
      curPassC,
      newPassC,
      confPassC;
  bool isSelected = false, isArea = true;
  bool _isNetworkAvail = true;
  bool _showCurPassword = false, _showPassword = false, _showCmPassword = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  List<String?> statusList = [DEACTIVE_LBL, ACTIVE_LBL];

  @override
  void initState() {
    super.initState();

    mobileC = TextEditingController(text: mobile);
    nameC = TextEditingController();
    emailC = TextEditingController();

    addressC = TextEditingController();
    getUserDetails();
    loadProfileImage();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID) ?? "";
    mobile = await getPrefrence(MOBILE) ?? "";
    name = await getPrefrence(USERNAME) ?? "";
    email = await getPrefrence(EMAIL) ?? "";
    address = await getPrefrence(ADDRESS) ?? "";
    commMethod = await getPrefrence(COMMISSION_METHOD) ?? "";
    comm = await getPrefrence(COMMISSION) ?? "";
    active = await getPrefrence(ACTIVE) ?? "";
    token = await getPrefrence(TOKEN) ?? "";

    balance = await getPrefrence(BALANCE) ?? "";
    mobileC!.text = mobile;
    nameC!.text = name;
    emailC!.text = email;

    addressC!.text = address;

    setState(() {});
  }

  void loadProfileImage() async {
    profileImageUrl = await getPrefrence('profile_image');
    setState(() {
      _profileImage = null;
    });
  }

  Future<void> _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(),
        ],
      );
      if (croppedImage != null) {
        File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(
            path: croppedImage.path);
        setState(() {
          _profileImage = rotatedImage;
        });
        checkNetwork(2, 1, active);
      }
    }
  }

  Future<void> _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(),
        ],
      );
      if (croppedImage != null) {
        File rotatedImage = await FlutterExifRotation.rotateAndSaveImage(
            path: croppedImage.path);
        setState(() {
          _profileImage = rotatedImage;
        });
        checkNetwork(2, 1, active);
      }
    }
  }

  Future<void> _chooseProfileImage(BuildContext context) async {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                getTranslated(context, 'PROFILE_PICTURE') ?? 'Profile Picture',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _getFromGallery();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          child: Icon(
                            Icons.photo_library,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          getTranslated(context, 'GALLERY') ?? 'Gallery',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromCamera();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          child: Icon(
                            Icons.photo_camera,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          getTranslated(context, 'CAMERA') ?? 'Camera',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> checkNetwork(int from, int type, String status) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setUpdateUser(from, type, status);
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _updateState(int position) {
    _isLoading = true;
    active = position.toString();
    checkNetwork(3, 1, position.toString());

    setState(() {});
  }

  Future<void> setUpdateUser(int from, int type, String status) async {
    Map<String, String?> data;
    if (type == 0) {
      data = {
        USER_ID: CUR_USERID,
        USERNAME: name,
        EMAIL: email,
        MOBILE: mobile
      };
      if (newPass != "" && newPass != "") {
        data[NEWPASS] = newPass;
      }
      if (curPass != "" && curPass != "") {
        data[OLDPASS] = curPass;
      }
    } else {
      data = {
        USER_ID: CUR_USERID,
        USERNAME: nameC!.text,
        STATUS: status,
        MOBILE: mobileC!.text,
        ADDRESS: addressC!.text,
        EMAIL: emailC!.text
      };
    }

    if (_profileImage != null) {
      setState(() {
        _isLoading = true;
      });
      apiBaseHelper
          .postMultipartAPICall(
              getUpdateUserApi, data, _profileImage, 'profile', context)
          .then((getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        String? newProfileImageUrl;
        if (getdata["data"] != null && getdata["data"]["image"] != null) {
          newProfileImageUrl = getdata["data"]["image"];
        }
        if (!error) {
          if (newProfileImageUrl != null && newProfileImageUrl.isNotEmpty) {
            setState(() {
              profileImageUrl = newProfileImageUrl;
              _profileImage = null;
              _isLoading = false;
            });
            await setPrefrence('profile_image', newProfileImageUrl);
            setSnackbar(getTranslated(context, 'PROFILE_UPDATE_SUCCESS') ??
                'Profile updated successfully');
            CUR_USERNAME = name;
            mobile = mobileC!.text;
            name = nameC!.text;
            email = emailC!.text;
            address = addressC!.text;
            saveUserDetail(CUR_USERID!, name, email, mobile, address,
                commMethod, comm, status, balance, token);
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setState(() {
          _isLoading = false;
        });
        setSnackbar(error.toString());
      });
    } else {
      apiBaseHelper.postAPICall(getUpdateUserApi, data, context).then(
          (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          if (from == 2) {
            setSnackbar(getTranslated(context, 'RID_DA_UP_SUCC')!);
          } else if (from == 1) {
            setSnackbar(getTranslated(context, 'RID_PASS_UP_SUCC')!);
          } else {
            setSnackbar(getTranslated(context, 'RIDER_STA_SUCC')!);
          }
          setState(() {
            _isLoading = false;
          });
          CUR_USERNAME = name;
          mobile = mobileC!.text;
          name = nameC!.text;
          email = emailC!.text;
          address = addressC!.text;
          saveUserDetail(CUR_USERID!, name, email, mobile, address, commMethod,
              comm, status, balance, token);
        } else {
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setSnackbar(error.toString());
      });
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  setUser() {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(setSvgPath("username"),
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                height: 22,
                width: 22),
            Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'NAME_LBL')!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: darkFontColor, fontWeight: FontWeight.normal),
                    ),
                    name != ""
                        ? Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: darkFontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                )),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: darkFontColor,
              ),
              onPressed: () {
                openChangenameBottomSheet();
              },
            )
          ],
        ));
  }

  setMobileNo() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(setSvgPath("mobilenumber"),
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                height: 22,
                width: 22),
            Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'MOBILEHINT_LBL')!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: darkFontColor, fontWeight: FontWeight.normal),
                    ),
                    mobile != "" && mobile != ""
                        ? Text(
                            mobile,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: darkFontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                )),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: darkFontColor,
              ),
              onPressed: () {
                openChangeMonoBottomSheet();
              },
            )
          ],
        ));
  }

  setComm() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SvgPicture.asset(setSvgPath("commission"),
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                fit: BoxFit.scaleDown,
                height: 22,
                width: 22),
            Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      COMMISSION_METHOD,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: darkFontColor, fontWeight: FontWeight.normal),
                    ),
                    commMethod != "" && commMethod != ""
                        ? Text(
                            commMethod,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: darkFontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 8.0),
                      child: Text(
                        getTranslated(context, 'COMMISSION_LBL')!,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: darkFontColor,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    comm != "" && comm != ""
                        ? Text(
                            comm,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: darkFontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container(),
                  ],
                )),
          ],
        ));
  }

  List<Widget> statusListView() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
              index,
              InkWell(
                onTap: () {
                  _updateState(index);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: int.parse(active) == index
                                  ? const Icon(
                                      Icons.radio_button_checked,
                                      size: 23.0,
                                      color: primary,
                                    )
                                  : const Icon(
                                      Icons.radio_button_off,
                                      size: 23.0,
                                      color: primary,
                                    )),
                          Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 5.0,
                              ),
                              child: Text(
                                statusList[index]!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: darkFontColor),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        )
        .values
        .toList();
  }

  setEmail() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(setSvgPath("email"),
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                height: 22,
                width: 22),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'EMAIL_LBL')!,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: darkFontColor, fontWeight: FontWeight.normal),
                  ),
                  email != "" && email != ""
                      ? Text(
                          email,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: darkFontColor,
                                  fontWeight: FontWeight.bold),
                        )
                      : Container()
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: darkFontColor,
              ),
              onPressed: () {
                openChangeEmailBottomSheet();
              },
            )
          ],
        ));
  }

  setAddress() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(setSvgPath("pin"),
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                height: 22,
                width: 22),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, 'CITY_LBL')!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: darkFontColor, fontWeight: FontWeight.normal),
                    ),
                    address != "" && address != ""
                        ? SizedBox(
                            child: Text(
                              address,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: darkFontColor,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: darkFontColor,
              ),
              onPressed: () {
                openChangeAddrBottomSheet();
              },
            )
          ],
        ));
  }

  changeStatus() {
    return Container(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      width: deviceWidth,
      child: Card(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            side: BorderSide(
              color: black,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(start: 20.0, top: 10.0),
                child: Text(
                  getTranslated(context, 'STA_UPDATE_LBL')!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: darkFontColor, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: statusListView(),
              ),
            ],
          )),
    );
  }

  changePass() {
    return Container(
        height: 60,
        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
        width: deviceWidth,
        child: Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              side: BorderSide(
                color: black,
                width: 0.5,
              ),
            ),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 20.0, top: 15.0, bottom: 15.0),
                child: Text(
                  getTranslated(context, 'CHANGE_PASS_LBL')!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: darkFontColor, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                openChangePassBottomSheet();
              },
            )));
  }

  setName(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
        validator: (value) => validateUserName(value, context),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: nameC,
      ),
    );
  }

  setEma(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
        validator: (value) => validateEmail(value, context),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: emailC,
      ),
    );
  }

  setAdd(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
        validator: (value) => validateField(value, context),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: addressC,
      ),
    );
  }

  setMob(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
        validator: (value) => validateMob(value, context),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: mobileC,
      ),
    );
  }

  void openChangenameBottomSheet() {
    nameC!.text = name;
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bottomsheetLabel(
                                getTranslated(context, 'ADD_NAME_LBL')!,
                                context),
                            setName(setStater),
                            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
                              final form = _formKey.currentState!;
                              if (form.validate()) {
                                form.save();
                                setStater(() {
                                  Navigator.pop(context);
                                });
                                checkNetwork(2, 1, active);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  void openChangeEmailBottomSheet() {
    emailC!.text = email;
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bottomsheetLabel(
                                getTranslated(context, 'ADD_EMAIL_LBL')!,
                                context),
                            setEma(setStater),
                            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
                              final form = _formKey.currentState!;
                              if (form.validate()) {
                                form.save();
                                setStater(() {
                                  Navigator.pop(context);
                                });
                                checkNetwork(2, 1, active);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  void openChangeAddrBottomSheet() {
    addressC!.text = address;
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bottomsheetLabel(
                                getTranslated(context, 'ADD_ADDRESS_LBL')!,
                                context),
                            setAdd(setStater),
                            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
                              final form = _formKey.currentState!;
                              if (form.validate()) {
                                form.save();
                                setStater(() {
                                  Navigator.pop(context);
                                });
                                checkNetwork(2, 1, active);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  void openChangeMonoBottomSheet() {
    mobileC!.text = mobile;
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bottomsheetLabel(
                                getTranslated(context, 'ADD_MBL_LBL')!,
                                context),
                            setMob(setStater),
                            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
                              final form = _formKey.currentState!;
                              if (form.validate()) {
                                form.save();
                                setStater(() {
                                  Navigator.pop(context);
                                });
                                checkNetwork(2, 0, active);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  void openChangePassBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0))),
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Wrap(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        color: white,
                      ),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            bottomsheetLabel(
                                getTranslated(context, 'CHANGE_PASS_LBL')!,
                                context),
                            setCurrentPasswordField(setStater),
                            newPwdField(setStater),
                            confirmPwdField(setStater),
                            saveButton(getTranslated(context, 'SAVE_LBL')!, () {
                              final form = _formKey.currentState!;
                              if (form.validate()) {
                                form.save();
                                setStater(() {
                                  Navigator.pop(context);
                                });
                                checkNetwork(1, 0, active);
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    bottomSheetHandle(context),
                  ],
                ),
              ],
            );
          });
        });
  }

  Widget saveButton(String title, VoidCallback? onBtnSelected) {
    return Padding(
        padding:
            const EdgeInsetsDirectional.only(start: 8.0, end: 8.0, top: 15.0),
        child: SimBtn(
          onBtnSelected: onBtnSelected,
          title: title,
          size: 0.8,
        ));
  }

  Widget setCurrentPasswordField(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            keyboardType: TextInputType.text,
            style: const TextStyle(color: darkFontColor),
            controller: curPassC,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'CUR_PASS_LBL')!,
                    style: const TextStyle(color: darkFontColor)),
                fillColor: white,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(_showCurPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  iconSize: 20,
                  color: lightFontColor,
                  onPressed: () {
                    setStater(() {
                      _showCurPassword = !_showCurPassword;
                    });
                  },
                )),
            obscureText: !_showCurPassword,
            onChanged: (String? value) {
              setStater(() {
                curPass = value!;
              });
            },
            validator: (value) => validatePass(value, context),
          ),
        ),
      ),
    );
  }

  Widget newPwdField(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            keyboardType: TextInputType.text,
            style: const TextStyle(color: darkFontColor),
            controller: newPassC,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'NEW_PASS_LBL')!),
                fillColor: white,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  iconSize: 20,
                  color: lightFontColor,
                  onPressed: () {
                    setStater(() {
                      _showPassword = !_showPassword;
                    });
                  },
                )),
            obscureText: !_showPassword,
            onChanged: (String? value) {
              setStater(() {
                newPass = value!;
              });
            },
            validator: (value) => validatePass(value, context),
          ),
        ),
      ),
    );
  }

  Widget confirmPwdField(StateSetter setStater) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            keyboardType: TextInputType.text,
            style: const TextStyle(color: darkFontColor),
            controller: confPassC,
            obscuringCharacter: "*",
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'CONFIRMPASSHINT_LBL')!),
                fillColor: white,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(_showCmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  iconSize: 20,
                  color: lightFontColor,
                  onPressed: () {
                    setStater(() {
                      _showCmPassword = !_showCmPassword;
                    });
                  },
                )),
            obscureText: !_showCmPassword,
            validator: (value) {
              if (value!.isEmpty) {
                return getTranslated(context, 'CON_PASS_REQUIRED_MSG');
              }
              if (value != newPass) {
                return getTranslated(context, 'CON_PASS_NOT_MATCH_MSG');
              } else {
                return null;
              }
            },
            onChanged: (v) => setStater(() {
              confPass = v;
            }),
          ),
        ),
      ),
    );
  }

  Widget profileImage() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primary,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!) as ImageProvider
                    : null,
            child: (_profileImage == null &&
                    (profileImageUrl == null || profileImageUrl!.isEmpty))
                ? Icon(
                    Icons.account_circle,
                    size: 100,
                    color: darkFontColor.withValues(alpha: 0.7),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: InkWell(
              onTap: () => _chooseProfileImage(context),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getDivider() {
    return const Divider(
      height: 1,
      color: lightFontColor,
    );
  }

  _showContent1() {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Container(
            height: deviceHeight,
            padding: const EdgeInsets.only(top: 10.0),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0)),
                color: white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -9),
                    blurRadius: 10,
                    spreadRadius: 0,
                    color: shadowColor,
                  )
                ]),
            child: SingleChildScrollView(
                child: _isNetworkAvail
                    ? Column(children: <Widget>[
                        profileImage(),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 20, bottom: 5.0, right: 10.0, left: 10.0),
                            child: Container(
                                child: Card(
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                        color: black,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        setUser(),
                                        _getDivider(),
                                        setMobileNo(),
                                        _getDivider(),
                                        setEmail(),
                                        _getDivider(),
                                        setAddress(),
                                        _getDivider(),
                                        setComm(),
                                      ],
                                    )))),
                        changePass(),
                        changeStatus(),
                      ])
                    : noInternet(context))));
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      appBar: getAppBar(getTranslated(context, 'EDIT_PROFILE_LBL')!, context),
      body: Stack(
        children: <Widget>[
          _showContent1(),
          showCircularProgress(_isLoading, primary)
        ],
      ),
    );
  }
}
