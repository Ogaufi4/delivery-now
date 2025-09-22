import 'dart:async';
import 'package:project/Model/Tags/tags.dart';
import 'package:flutter/material.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import 'home.dart';

class AddTags extends StatefulWidget {
  const AddTags({Key? key}) : super(key: key);

  @override
  _AddTagsState createState() => _AddTagsState();
}

class _AddTagsState extends State<AddTags> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool scrollLoadmore = true, scrollGettingData = false, scrollNodata = false;
  int scrollOffset = 0;
  List<TagsModel> tagList = [];
  List<TagsModel> tempList = [];
  List<TagsModel> selectedList = [];
  ScrollController? scrollController;
  TextEditingController mobilenumberController = TextEditingController();
  FocusNode? tagsController = FocusNode();
  String? tagvalue;
  int perPageLoad = 10;
  @override
  void initState() {
    super.initState();
    scrollOffset = 0;
    getTags();

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
  }

  _transactionscrollListener() {
    if (scrollController!.offset >= scrollController!.position.maxScrollExtent && !scrollController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            scrollLoadmore = true;
            getTags();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, "Tags")!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  _showContent() {
    return scrollNodata
        ? Column(
            children: [
              uploadTags(),
              getNoItem(context),
            ],
          )
        : NotificationListener<ScrollNotification>(
            child: Column(
              children: [
                uploadTags(),
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
                      TagsModel? item;

                      item = tagList.isEmpty ? null : tagList[index];

                      return item == null ? Container() : getMediaItem(index);
                    },
                  ),
                ),
                scrollGettingData
                    ? const Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: 5,
                          bottom: 5,
                        ),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            ),
          );
  }

  Future<void> addTagAPI() async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      resturantId: CUR_USERID,
      tItle: tagvalue,
    };
    apiBaseHelper.postAPICall(addTags, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setsnackbar(msg!, context);
          tagvalue = null;
          mobilenumberController.text = "";
          setState(() {});
        } else {
          setsnackbar(msg!, context);
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

  Future<void> deleteTagsAPI(String? id) async {
    CUR_USERID = await getPrefrence(Id);
    var parameter = {
      resturantId: CUR_USERID,
      tagId: id,
    };
    apiBaseHelper.postAPICall(deleteTagAPI, parameter, context).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setsnackbar(msg!, context);
          tagList.clear();
          scrollLoadmore = true;
        } else {
          setsnackbar(msg!, context);
        }
      },
      onError: (error) {
        setsnackbar(error.toString(), context);
      },
    );
  }

  uploadTags() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10,
        bottom: 10,
        start: 10,
        end: 10,
      ),
      child: Card(
        elevation: 10,
        child: InkWell(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(tagsController);
                  },
                  controller: mobilenumberController,
                  decoration: InputDecoration(
                    counterStyle: const TextStyle(color: white, fontSize: 0),
                    hintText: getTranslated(context, "Enter New Tag")!,
                    icon: const Icon(Icons.style_outlined),
                    iconColor: primary,
                    labelStyle: const TextStyle(
                      color: black,
                      fontSize: 17.0,
                    ),
                    hintStyle: const TextStyle(
                      color: black,
                      fontSize: 17.0,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  keyboardType: TextInputType.text,
                  focusNode: tagsController,
                  onSaved: (String? value) {
                    tagvalue = value;
                  },
                  onChanged: (String? value) {
                    tagvalue = value;
                  },
                  style: const TextStyle(
                    color: black,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  tagList.clear();
                  scrollLoadmore = true;
                  addTagAPI();
                  Future.delayed(const Duration(seconds: 2)).then(
                    (_) async {
                      scrollLoadmore = true;
                      scrollOffset = 0;
                      getTags();
                      setState(
                        () {},
                      );
                    },
                  );
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
                      getTranslated(context, "Add Tag")!,
                      style: const TextStyle(
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
      ),
    );
  }

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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      ).then(
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

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> getTags() async {
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
            resturantId: CUR_USERID,
            LIMIT: perPageLoad.toString(),
            OFFSET: scrollOffset.toString(),
          };

          apiBaseHelper.postAPICall(getTagsApi, parameter, context).then(
            (getdata) async {
              bool error = getdata["error"];
              String? msg = getdata["message"];
              scrollGettingData = false;
              if (scrollOffset == 0) scrollNodata = error;

              if (!error) {
                tempList.clear();
                var data = getdata["data"];
                if (data.length != 0) {
                  tempList = (data as List)
                      .map(
                        (data) => TagsModel.fromJson(data),
                      )
                      .toList();

                  tagList.addAll(tempList);
                  scrollLoadmore = true;
                  scrollOffset = scrollOffset + perPageLoad;
                } else {
                  scrollLoadmore = false;
                }
              } else {
                setsnackbar(msg!, context);
                scrollLoadmore = false;
              }
              if (mounted) {
                setState(
                  () {
                    scrollLoadmore = false;
                  },
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

  getMediaItem(int index) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 15.0),
                          child: Icon(
                            Icons.radio_button_checked_outlined,
                            color: primary,
                          ),
                        ),
                        Text(
                          tagList[index].title!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      deleteTagsAPI(tagList[index].id);
                      Future.delayed(const Duration(seconds: 2)).then(
                        (_) async {
                          scrollLoadmore = true;
                          scrollOffset = 0;
                          getTags();
                          setState(
                            () {},
                          );
                        },
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.delete,
                        color: primary,
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
  }
}
