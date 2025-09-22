// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:project/Helper/apiUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import '../Model/Attribute Models/AttributeModel/attributes_model.dart';
import '../Model/Attribute Models/AttributeValueModel/attribute_value.dart';
import 'home.dart';

class AddAttributes extends StatefulWidget {
  const AddAttributes({Key? key}) : super(key: key);

  @override
  _AddAttributesState createState() => _AddAttributesState();
}

class _AddAttributesState extends State<AddAttributes> with TickerProviderStateMixin {
//============================== All Variables =================================

  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool scrollLoadmore = true, scrollGettingData = false, scrollNodata = false;
  int scrollOffset = 0;
  List<AttributeModel> tagList = [];
  List<AttributeModel> tempList = [];
  ScrollController? scrollController;
  TextEditingController attributeNameController = TextEditingController();
  FocusNode? tagsController = FocusNode();
  String? attributeValueText;
  List<String> newattributeValue = [];
  List<AttributeValueModel> attributesValueList = [];
  int number = 1;
  int perPageLoad = 10;
  List<Map<String, dynamic>> AttributeValue = [];
  late StateSetter AttributeState;
  String? newAtrributeValue;

//================================== initState =================================

  @override
  void initState() {
    super.initState();
    scrollOffset = 0;
    getAttribute();
    getAttributesValue();

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    scrollController = ScrollController(keepScrollOffset: true);
    scrollController!.addListener(_transactionscrollListener);

    buttonSqueezeanimation = Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    newattributeValue.add("");
  }

//============================== getAttribute API ==============================

  Future<void> getAttribute() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (scrollLoadmore) {
        if (mounted) {
          setState(
            () {
              scrollLoadmore = false;
              scrollGettingData = true;
              if (scrollOffset == 0) {
                tagList = [];
              }
            },
          );
        }
        try {
          var parameter = {
            LIMIT: perPageLoad.toString(),
            OFFSET: scrollOffset.toString(),
          };
          http.Response response = await http
              .post(
                getAttributesApi,
                body: parameter,
                headers: await ApiUtils.getHeaders(),
              )
              .timeout(
                const Duration(
                  seconds: timeOut,
                ),
              );

          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          scrollGettingData = false;
          if (scrollOffset == 0) scrollNodata = error;
          if (!error) {
            tempList.clear();
            var data = getdata["data"];
            if (data.length != 0) {
              tempList = (data as List).map((data) => AttributeModel.fromJson(data)).toList();
              tagList.addAll(tempList);
              scrollLoadmore = true;
              scrollOffset = scrollOffset + perPageLoad;
            } else {
              scrollLoadmore = false;
            }
          } else {
            if (getdata[statusCode] == "120") {
              reLogin(context);
            }
            scrollLoadmore = false;
          }
          if (mounted) {
            setState(
              () {
                scrollLoadmore = false;
              },
            );
          }
        } on TimeoutException catch (_) {
          setsnackbar(
            getTranslated(context, "somethingMSg")!,
            context,
          );
          setState(
            () {
              scrollLoadmore = false;
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
            scrollLoadmore = false;
          },
        );
      }
    }
  }

//======================== getAttributrValuesApi API ===========================

  getAttributesValue() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response =
            await http.post(getAttributrValuesApi, headers: await ApiUtils.getHeaders()).timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        if (!error) {
          var data = getdata["data"];
          attributesValueList = (data as List)
              .map(
                (data) => AttributeValueModel.fromJson(data),
              )
              .toList();
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          setsnackbar(
            getTranslated(context, "somethingMSg")!,
            context,
          );
        }
        setState(
          () {},
        );
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    }
  }

  _transactionscrollListener() {
    if (scrollController!.offset >= scrollController!.position.maxScrollExtent && !scrollController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            scrollLoadmore = true;
            getAttribute();
          },
        );
      }
    }
  }

//============================== addAttribute API ==============================

  Future<void> addAttributeAPI() async {
    CUR_USERID = await getPrefrence(Id);
    if (attributeValueText == null) {
      setsnackbar(
        getTranslated(context, "enter a Title Value")!,
        context,
      );
      return;
    }
    var parameter = {
      "name": attributeValueText,
      AttributeValues: json.encode(AttributeValue),
    };
    apiBaseHelper.postAPICall(addAttributesAPI, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? message = getdata["message"];
        if (!error) {
          setsnackbar(message!, context);
          tagList = [];
          scrollOffset = 0;
          scrollLoadmore = true;
          AttributeValue.clear();
          attributeValueText = null;
          attributeNameController.text = "";
          number = 1;
          getAttribute();
        } else {
          setsnackbar(message!, context);
          AttributeValue.clear();
          attributeValueText = null;
          attributeNameController.text = "";
          number = 1;
          setState(
            () {},
          );
        }
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
  }

//============================== editAttributeAPI ==============================

  Future<void> editAttributeAPI(String attributeID, List<AttributeValueModel> newAtrributeValue, String AttributeName, [String? value]) async {
    String? attributeValueIds;
    String? attributeValueName;
    for (var element in newAtrributeValue) {
      if (attributeValueIds != null) {
        attributeValueIds = "$attributeValueIds,${element.id!}";
      } else {
        attributeValueIds = element.id!;
      }
      if (attributeValueName != null) {
        attributeValueName = "$attributeValueName,${element.value!}";
      } else {
        attributeValueName = element.value!;
      }
    }
    if (value != null) {
      attributeValueIds = "$attributeValueIds,0";
      attributeValueName = "$attributeValueName,$value";
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          "edit_attribute_id": attributeID,
          "attribute_value_ids": attributeValueIds,
          "name": AttributeName,
          "value_name": attributeValueName,
        };
        apiBaseHelper.postAPICall(editAttributesAPI, parameter, context).then(
          (getdata) async {
            bool error = getdata["error"];
            String? msg = getdata["message"];

            if (!error) {
              tempList.clear();
              setsnackbar(msg!, context);
              attributesValueList.clear();
              getAttributesValue();
              scrollLoadmore = true;
              getAttribute();
              tagList = [];
              scrollOffset = 0;
              scrollLoadmore = true;
              setState(
                () {},
              );
            } else {
              setsnackbar(msg!, context);
            }
            if (mounted) {
              setState(
                () {},
              );
            }
          },
          onError: (error) {
            setsnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    } else if (mounted) {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
      return;
    }
  }

//================================ Build Method ================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, "Attributes")!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

//================================ _showContent Method =========================

  _showContent() {
    return scrollNodata
        ? SingleChildScrollView(
            child: Column(
              children: [
                uploadAttribute(),
                getNoItem(context),
              ],
            ),
          )
        : NotificationListener<ScrollNotification>(
            child: Column(
              children: [
                uploadAttribute(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.only(
                      bottom: 5,
                      start: 10,
                      end: 10,
                    ),
                    itemCount: tagList.length,
                    itemBuilder: (context, index) {
                      AttributeModel? item;

                      item = tagList.isEmpty ? null : tagList[index];

                      return item == null ? Container() : getAttributeItem(index);
                    },
                  ),
                ),
                scrollGettingData
                    ? const Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            ),
          );
  }

//================================ uploadAttribute =============================

  uploadAttribute() {
    return Padding(
      padding: const EdgeInsetsDirectional.all(10),
      child: Card(
        elevation: 1,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(tagsController);
                },
                controller: attributeNameController,
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: white, fontSize: 0),
                  hintText: getTranslated(context, "Enter New Atrribute")!,
                  icon: Icon(Icons.edit_attributes_outlined),
                  iconColor: primary,
                  labelStyle: TextStyle(
                    color: black,
                    fontSize: 17.0,
                  ),
                  hintStyle: TextStyle(
                    color: black,
                    fontSize: 17.0,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                keyboardType: TextInputType.text,
                focusNode: tagsController,
                onSaved: (String? value) {
                  attributeValueText = value;
                },
                onChanged: (String? value) {
                  attributeValueText = value;
                },
                style: const TextStyle(
                  color: black,
                  fontSize: 18.0,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    right: 8,
                    left: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, "Add Atribute Value")!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          number = number + 1;
                          newattributeValue.add("");
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          height: 30,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 6,
                                right: 6,
                              ),
                              child: Text(
                                getTranslated(context, "Add Value")!,
                                style: TextStyle(
                                  color: white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(
                  height: number > 1 ? height * 0.12 : height * 0.075,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < number; i++)
                          Container(
                            width: width * 0.7,
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              onFieldSubmitted: (v) {},
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                              textInputAction: TextInputAction.next,
                              onSaved: (String? value) {
                                setState(() {
                                  newattributeValue[i] = value ?? "";
                                });
                              },
                              onChanged: (String? value) {
                                setState(() {
                                  newattributeValue[i] = value ?? "";
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: lightWhite,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: fontColor),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(color: lightWhite),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        number > 1
                            ? InkWell(
                                onTap: () {
                                  newattributeValue.removeLast();
                                  number = number - 1;
                                  setState(
                                    () {},
                                  );
                                },
                                child: Container(
                                  color: red,
                                  child: Icon(
                                    Icons.close,
                                    size: 28,
                                    color: white,
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
            ),
            InkWell(
              onTap: () {
                for (int i = 0; i < number; i++) {
                  Map<String, dynamic> singleAddon = {
                    "value": newattributeValue[i],
                  };
                  AttributeValue.add(singleAddon);
                }
                addAttributeAPI();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: black,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 120,
                height: 40,
                child: Center(
                  child: Text(
                    getTranslated(context, "Add Attribute")!,
                    style: TextStyle(
                      color: white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
          ],
        ),
      ),
    );
  }

//================================== getAppBar =================================

  getAppBar(String title, BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: white,
      elevation: 1,
      leading: Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: shadow(),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: primary,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: primary,
        ),
      ),
    );
  }

//================================== noInternet ================================

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, "NO_INTERNET")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => super.widget)).then(
                        (value) {
                          setState(
                            () {},
                          );
                        },
                      );
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                          () {},
                        );
                      }
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> changeAttributeStatus(
    String type,
    String id,
    bool value,
  ) async {
    var parameter = {
      "type": type,
      "type_id": id,
      "status": value == true ? "1" : "0",
    };
    apiBaseHelper.postAPICall(updateAttributeStatusAPI, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setsnackbar(msg!, context);
          attributesValueList.clear();
          getAttributesValue();
          scrollLoadmore = true;
          getAttribute();
          tagList = [];
          scrollOffset = 0;
          scrollLoadmore = true;

          setState(
            () {},
          );
        } else {
          setsnackbar(msg!, context);

          setState(
            () {},
          );
        }
      },
      onError: (error) {
        setsnackbar(
          error.toString(),
          context,
        );
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  editAttributeDialog(
    String Id,
    String name,
    List<AttributeValueModel> attributeValues,
  ) async {
    var attributeValue = attributeValues;
    String attributename = name;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            AttributeState = setStater;
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: width * 0.6,
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: false,
                            onFieldSubmitted: (v) {},
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              if (value != "") {
                                attributename = value;
                              }
                            },
                            onSaved: (value) {
                              if (value != null) {
                                if (value != "") {
                                  attributename = value;
                                }
                              }
                            },
                            keyboardType: TextInputType.text,
                            style: const TextStyle(
                              color: fontColor,
                              fontWeight: FontWeight.normal,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: attributename,
                              hintStyle: TextStyle(color: black),
                              filled: true,
                              fillColor: lightWhite,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: fontColor),
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: const BorderSide(color: lightWhite),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: black),
                    for (int i = 0; i < attributeValues.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.6,
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                readOnly: false,
                                onFieldSubmitted: (v) {},
                                onChanged: (value) {
                                  if (value != "") {
                                    attributeValues[i].value = value;
                                  }
                                },
                                onSaved: (value) {
                                  if (value != null) {
                                    if (value != "") {
                                      attributeValues[i].value = value;
                                    }
                                  }
                                },
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(
                                  color: fontColor,
                                  fontWeight: FontWeight.normal,
                                ),
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: attributeValues[i].value!,
                                  filled: true,
                                  fillColor: lightWhite,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 40, maxHeight: 20),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: fontColor),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(color: lightWhite),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              editAttributeAPI(
                                Id,
                                attributeValue,
                                attributename,
                                newAtrributeValue,
                              );
                              newAtrributeValue = null;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 120,
                              height: 40,
                              child: Center(
                                child: Text(
                                  getTranslated(context, "Upload")!,
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  getAttributeItem(int index) {
    final attributeValues = attributesValueList.where((element) => element.attributeId == tagList[index].id).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(tagList[index].name!),
              ),
              Row(
                children: [
                  Switch(
                    value: tagList[index].status == "0" ? false : true,
                    onChanged: (value) {
                      changeAttributeStatus(
                        "attributes",
                        tagList[index].id!,
                        value,
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      editAttributeDialog(
                        tagList[index].id!,
                        tagList[index].name!,
                        attributeValues,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 30,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            right: 6,
                          ),
                          child: Text(
                            getTranslated(context, "Edit")!,
                            style: TextStyle(
                              color: white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: <Widget>[
            Column(
              children: [
                for (int i = 0; i < attributeValues.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: lightBlack,
                              width: 1,
                            ),
                          ),
                          width: width * 0.6,
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              attributeValues[i].value!,
                            ),
                          ),
                        ),
                        Switch(
                          value: attributeValues[i].status == "0" ? false : true,
                          onChanged: (value) {
                            changeAttributeStatus(
                              "attribute_values",
                              attributeValues[i].id!,
                              value,
                            );
                          },
                        )
                      ],
                    ),
                  ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.normal,
                    ),
                    onChanged: (String? value) {
                      newAtrributeValue = value;
                    },
                    textInputAction: TextInputAction.next,
                    validator: (val) => validateMob(val!, context),
                    onSaved: (String? value) {
                      newAtrributeValue = value;
                    },
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(color: primary),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      hintText: getTranslated(context, "Add New Attribute Value")!,
                      hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: lightBlack2,
                            fontWeight: FontWeight.normal,
                          ),
                      filled: true,
                      fillColor: white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        maxHeight: 20,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(color: lightBlack2),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      if (newAtrributeValue != null) {
                        editAttributeAPI(
                          tagList[index].id!,
                          attributeValues,
                          tagList[index].name!,
                          newAtrributeValue,
                        );
                        newAtrributeValue = null;
                      } else {
                        setsnackbar(getTranslated(context, "Please Add Value")!, context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: black,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 120,
                      height: 40,
                      child: Center(
                        child: Text(
                          getTranslated(context, "Upload")!,
                          style: TextStyle(
                            color: white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
