import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:project/Helper/AppBtn.dart';
import 'package:project/Helper/Color.dart';
import 'package:project/Helper/Session.dart';
import 'package:project/Helper/String.dart';

import 'package:project/Helper/keyboardOverlay.dart';
import 'package:project/Home.dart';
import 'package:project/Model/cityModel.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const RegistrationScreen());
  }
}

class RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController confirmPasswordController =
      TextEditingController(text: "");
  TextEditingController serviceableCityController =
      TextEditingController(text: "");
  Timer? _debounce;
  bool status = false, obscure = true, confirmObscure = true;
  final formKey = GlobalKey<FormState>();
  File? image;
  List<CityModel> serviceableCityList = [];
  List<CityModel> cityList = [];
  List<String> finalServiceableCityList = [];
  final ValueNotifier<double?> optionsViewWidthNotifier = ValueNotifier(null);
  String searchText = '';
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  // get image File camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        /* aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ], */
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    setState(() {
      image = rotatedImage;
    });
  }

//get image file from library
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        /* aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ], */
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    setState(() {
      image = rotatedImage;
    });
  }

  OutlineInputBorder testFieldBorderStype() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(width: 1.0, color: black.withValues(alpha: 0.5)),
    );
  }

  Widget passwordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: obscure,
          controller: passwordController,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          validator: (value) => validatePass(value, context),
          //maxLines: null,
          decoration: InputDecoration(
              errorMaxLines: 3,
              border: InputBorder.none,
              contentPadding: EdgeInsetsDirectional.all(16),
              enabledBorder: testFieldBorderStype(),
              focusedBorder: testFieldBorderStype(),
              focusedErrorBorder: testFieldBorderStype(),
              errorBorder: testFieldBorderStype(),
              disabledBorder: testFieldBorderStype(),
              label: Text(getTranslated(context, 'PASSHINT_LBL')!),
              labelStyle: TextStyle(color: black),
              hintText: getTranslated(context, 'PASSHINT_LBL'),
              suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (obscure == true) {
                        obscure = false;
                      } else {
                        obscure = true;
                      }
                    });
                  },
                  child: Icon(
                      obscure == true ? Icons.visibility_off : Icons.visibility,
                      color: black.withValues(alpha: 0.5)))),
        ));
  }

  Widget confirmPasswordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: confirmObscure,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          controller: confirmPasswordController,
          validator: (value) {
            if (value!.isEmpty)
              return getTranslated(context, 'CON_PASS_REQUIRED_MSG');
            if (value != passwordController.text) {
              return getTranslated(context, 'CON_PASS_NOT_MATCH_MSG');
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsetsDirectional.all(16),
              enabledBorder: testFieldBorderStype(),
              focusedBorder: testFieldBorderStype(),
              focusedErrorBorder: testFieldBorderStype(),
              errorBorder: testFieldBorderStype(),
              disabledBorder: testFieldBorderStype(),
              label: Text(getTranslated(context, 'CONFIRMPASSHINT_LBL')!),
              labelStyle: TextStyle(color: black),
              hintText: getTranslated(context, 'CONFIRMPASSHINT_LBL'),
              suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (confirmObscure == true) {
                        confirmObscure = false;
                      } else {
                        confirmObscure = true;
                      }
                    });
                  },
                  child: Icon(
                      confirmObscure == true
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: black.withValues(alpha: 0.5)))),
        ));
  }

  Future chooseProfile(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                  top: height! / 80.0,
                  bottom: height! / 80.0,
                  end: width! / 20.0,
                  start: width! / 20.0),
              child: Text(
                getTranslated(context, 'PROFILE_PICTURE')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
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
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.photo_library,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            getTranslated(context, 'GALLERY')!,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w500),
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
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
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
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            getTranslated(context, 'CAMERA')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: "");
    emailController = TextEditingController(text: "");
    phoneNumberController = TextEditingController(text: "");
    addressController = TextEditingController(text: "");

    serviceableCityController = TextEditingController();
    _debounce = Timer(const Duration(milliseconds: 0), () {});

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.8,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    numberFocusNodeAndroid.addListener(() {
      bool hasFocus = numberFocusNodeAndroid.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _onSearchChanged(String query) {
    if (_debounce!.isActive) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        getCities();
      }
    });
  }

  @override
  void dispose() {
    _debounce!.cancel();
    buttonController!.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget nameField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            label: Text(getTranslated(context, 'NAME_LBL')!),
            labelStyle: TextStyle(color: black),
            fillColor: white,
            border: InputBorder.none,
            contentPadding: EdgeInsetsDirectional.all(16),
            enabledBorder: testFieldBorderStype(),
            focusedBorder: testFieldBorderStype(),
            focusedErrorBorder: testFieldBorderStype(),
            errorBorder: testFieldBorderStype(),
            disabledBorder: testFieldBorderStype(),
          ),
          validator: (value) => validateUserName(value, context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: nameController,
        ));
  }

  Widget addressField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            label: Text(getTranslated(context, 'ADDRESS_LBL')!),
            labelStyle: TextStyle(color: black),
            fillColor: white,
            border: InputBorder.none,
            contentPadding: EdgeInsetsDirectional.all(16),
            enabledBorder: testFieldBorderStype(),
            focusedBorder: testFieldBorderStype(),
            focusedErrorBorder: testFieldBorderStype(),
            errorBorder: testFieldBorderStype(),
            disabledBorder: testFieldBorderStype(),
          ),
          validator: (value) => validateField(value, context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: addressController,
        ));
  }

  Widget phoneNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 40.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.number,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            label: Text(getTranslated(context, 'MOBILEHINT_LBL')!),
            labelStyle: TextStyle(color: black),
            fillColor: white,
            border: InputBorder.none,
            contentPadding: EdgeInsetsDirectional.all(16),
            enabledBorder: testFieldBorderStype(),
            focusedBorder: testFieldBorderStype(),
            focusedErrorBorder: testFieldBorderStype(),
            errorBorder: testFieldBorderStype(),
            disabledBorder: testFieldBorderStype(),
          ),
          validator: (value) => validateMob(value, context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: phoneNumberController,
        ));
  }

  Widget emailField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          keyboardType: TextInputType.text,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: darkFontColor, fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            label: Text(getTranslated(context, 'EMAIL_LBL')!),
            labelStyle: TextStyle(color: black),
            fillColor: white,
            border: InputBorder.none,
            contentPadding: EdgeInsetsDirectional.all(16),
            enabledBorder: testFieldBorderStype(),
            focusedBorder: testFieldBorderStype(),
            focusedErrorBorder: testFieldBorderStype(),
            errorBorder: testFieldBorderStype(),
            disabledBorder: testFieldBorderStype(),
          ),
          validator: (value) => validateEmail(value, context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: emailController,
        ));
  }

  void addUniqueServiceableCityValue(CityModel selection) {
    if (!finalServiceableCityList.contains(selection.id)) {
      serviceableCityList.add(selection);
      finalServiceableCityList.add(selection.id!);
      print('$selection added');
    } else {
      print('$selection is already in the list');
    }
  }

  Widget serviceableCityField() {
    return Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Autocomplete<CityModel>(
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          if (serviceableCityController != textEditingController) {
            serviceableCityController = textEditingController;
            serviceableCityController.addListener(() {
              _onSearchChanged(serviceableCityController.text);
            });
          }
          return TextFormField(
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'SELECT_SERVICEABLE_CITY')!),
              labelStyle: TextStyle(color: black),
              fillColor: white,
              border: InputBorder.none,
              contentPadding: EdgeInsetsDirectional.all(16),
              enabledBorder: testFieldBorderStype(),
              focusedBorder: testFieldBorderStype(),
              focusedErrorBorder: testFieldBorderStype(),
              errorBorder: testFieldBorderStype(),
              disabledBorder: testFieldBorderStype(),
            ),
            controller: serviceableCityController,
            focusNode: focusNode,
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<CityModel> onSelected,
            Iterable<CityModel> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CityModel option = options.elementAt(index);
                      return ListTile(
                        title: Text('${option.name}'),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<CityModel>.empty();
          }
          if (cityList.isNotEmpty) {
            return cityList.where((CityModel option) {
              return option.name!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          } else {
            return const Iterable<CityModel>.empty();
          }
        },
        onSelected: (CityModel selection) {
          addUniqueServiceableCityValue(selection);
          setState(() {});
          serviceableCityController.clear();
          debugPrint('Selected city: ${selection.name}');
        },
        displayStringForOption: (CityModel city) => city.name!,
      ),
    );
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

  Future<void> getCities() async {
    try {
      apiBaseHelper.postAPICall(getCitiesApi, {}, context).then(
          (getdata) async {
        print("getdata*****$getdata");
        var data = getdata["data"];
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          cityList =
              (data as List).map((data) => CityModel.fromJson(data)).toList();
        } else {
          setSnackbar(msg!);
        }
      }, onError: (error) {
        setSnackbar(error.toString());
      });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }
  }

  Future<void> riderRegistration() async {
    Map<String, String> data = {
      NAME: nameController.text.trim(),
      EMAIL: emailController.text.trim(),
      MOBILE: phoneNumberController.text.trim(),
      PASSWORD: confirmPasswordController.text,
      ADDRESS: addressController.text.trim(),
      SERVICEABLECITY: finalServiceableCityList.join(",").toString(),
      DEVICETYPE: Platform.isAndroid ? "android" : "ios"
    };

    try {
      MultipartRequest request = MultipartRequest('POST', registerRiderApi);
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      if (image != null) {
        request.files.add(await MultipartFile.fromPath(
          PROFILE,
          image!.path,
          filename: image!.path.split('/').last,
        ));
      }

      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && !responseData["error"]) {
        await buttonController!.reverse();
        String? message = responseData["message"];
        setSnackbar(message ?? "Registration successful!");
        Navigator.pop(context);
      } else {
        await buttonController!.reverse();
        String? errorMessage =
            responseData["message"] ?? getTranslated(context, 'somethingMSg')!;
        setSnackbar(errorMessage!);
      }
    } catch (e) {
      await buttonController!.reverse();
      setSnackbar(e.toString());
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      riderRegistration();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        setState(() {
          _isNetworkAvail = false;
        });
      });
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState!;
    form.save();
    if (form.validate()) {
      if (serviceableCityList.isEmpty) {
        setSnackbar(getTranslated(context, 'PLEAS_ENTER_SERVICEABLE_CITY')!);
        return false;
      }
      return true;
    }
    return false;
  }

  submitBtn() {
    return AppBtn(
      title: getTranslated(context, 'SUBMIT'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: getAppBar(getTranslated(context, 'REGISTRATION')!, context),
        bottomNavigationBar: submitBtn(),
        body: Padding(
          padding: EdgeInsetsDirectional.only(
              start: width! / 15.0, top: height! / 80.0, end: width! / 15.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: width! / 10.0,
                          end: width! / 10.0,
                          bottom: height! / 25.0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: white.withValues(alpha: 0.50),
                              child: Container(
                                alignment: Alignment.center,
                                child: ClipOval(
                                    child: image != null
                                        ? Image.file(
                                            image!,
                                            height: 85,
                                            width: 85,
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.account_circle,
                                              size: 95,
                                              color: darkFontColor.withValues(
                                                  alpha: 0.7),
                                            ),
                                          )),
                              ),
                            ),
                          ),
                          Positioned.directional(
                            textDirection: Directionality.of(context),
                            top: height! / 14.0,
                            start: width! / 2.7,
                            child: GestureDetector(
                              onTap: () {
                                chooseProfile(context);
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: white,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Icon(Icons.edit_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    nameField(),
                    emailField(),
                    phoneNumberField(),
                    passwordField(),
                    confirmPasswordField(),
                    addressField(),
                    serviceableCityField(),
                    serviceableCityList.isNotEmpty
                        ? Wrap(
                            children: List.generate(
                                serviceableCityList.length,
                                (index) => Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        end: 8.0,
                                        top: height! / 80.0,
                                      ),
                                      child: Chip(
                                        side: BorderSide(
                                            color:
                                                black.withValues(alpha: 0.5)),
                                        backgroundColor: textFieldBackground,
                                        deleteIconColor:
                                            black.withValues(alpha: 0.5),
                                        labelStyle: TextStyle(
                                            color:
                                                black.withValues(alpha: 0.5)),
                                        label: Text(
                                            serviceableCityList[index].name!,
                                            style: TextStyle(
                                                color: black.withValues(
                                                    alpha: 0.5))),
                                        onDeleted: () {
                                          setState(() {
                                            serviceableCityList.removeAt(index);
                                            finalServiceableCityList
                                                .removeAt(index);
                                          });
                                        },
                                        deleteIcon: Icon(Icons.close,
                                            color:
                                                black.withValues(alpha: 0.5)),
                                      ),
                                    )))
                        : Container(),
                    SizedBox(height: height! / 15.0)
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
