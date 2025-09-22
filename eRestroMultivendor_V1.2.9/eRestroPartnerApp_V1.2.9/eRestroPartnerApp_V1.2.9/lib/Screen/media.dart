import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:project/Helper/apiUtils.dart';
import 'package:project/Screen/manage_promocode.dart';
import 'package:project/Screen/profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../Helper/app_button.dart';
import '../Helper/color.dart';
import '../Helper/constant.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import '../Model/MediaModel/media_model.dart';
import 'add_product.dart' as add;
import 'editProduct.dart' as edit;
import 'package:http_parser/http_parser.dart';

class Media extends StatefulWidget {
  final from, pos, type;
  const Media({Key? key, this.from, this.pos, this.type}) : super(key: key);
  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool scrollLoadmore = true, scrollGettingData = false, scrollNodata = false;
  int scrollOffset = 0;
  List<MediaModel> mediaList = [];
  List<MediaModel> tempList = [];
  List<MediaModel> selectedList = [];
  ScrollController? scrollController;
  late List<String> variantImgList = [];
  late List<String> variantImgUrlList = [];
  late List<String> otherImgList = [];
  late List<String> otherImgUrlList = [];
  var selectedImageFromGellery;
  File? videoFromGellery;
  String? uploadedVideoName;
  @override
  void initState() {
    super.initState();
    scrollOffset = 0;
    getMedia();

    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
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
            getMedia();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'Media')!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  _showContent() {
    return scrollNodata
        ? Column(
            children: [
              uploadImage(),
              getNoItem(context),
            ],
          )
        : NotificationListener<ScrollNotification>(
            child: Column(
              children: [
                uploadImage(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsetsDirectional.only(bottom: 5, start: 10, end: 10),
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      MediaModel? item;

                      item = mediaList.isEmpty ? null : mediaList[index];

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

  Future<void> uploadMediaAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", uploadMediaApi);
        request.headers.addAll(await ApiUtils.getHeaders());
        request.fields[resturantId] = CUR_USERID!;
        if (selectedImageFromGellery != null) {
          http.MultipartFile image;
          final mainImagepPath = lookupMimeType(selectedImageFromGellery.path);
          var extension = mainImagepPath!.split("/");
          image = await http.MultipartFile.fromPath(
            "documents[]",
            selectedImageFromGellery.path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
          );
          request.files.add(image);
        }
        if (videoFromGellery != null) {
          final mainImagepPath = lookupMimeType(videoFromGellery!.path);

          var extension = mainImagepPath!.split("/");

          var video = await http.MultipartFile.fromPath(
            "documents[]",
            videoFromGellery!.path,
            contentType: MediaType(
              'video',
              extension[1],
            ),
          );
          request.files.add(video);
        }
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String msg = getdata['message'];
        if (!error) {
          setsnackbar(msg, context);
          setState(
            () {
              scrollOffset = 0;
              getMedia();
            },
          );
        } else {
          if (getdata[statusCode] == "102") {
            reLogin(context);
          }
          setsnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, 'somethingMSg')!,
          context,
        );
      }
    } else if (mounted) {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
        },
      );
    }
  }

  uploadImage() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10, bottom: 5, start: 10, end: 10),
      child: Card(
        child: InkWell(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, "Upload media from Gellery")!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              InkWell(
                onTap: () {
                  if (widget.from == "video") {
                    videoFromGallery();
                  } else {
                    imageFromGallery();
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
                      getTranslated(context, "Select File")!,
                      style: const TextStyle(
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
              selectedImageFromGellery == null
                  ? Container()
                  : const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              uploadedVideoName == null
                  ? Container()
                  : const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              selectedImageFromGellery == null
                  ? Container()
                  : SizedBox(
                      child: Image.file(
                        selectedImageFromGellery!,
                        height: 200,
                        width: 200,
                      ),
                    ),
              uploadedVideoName == null
                  ? Container()
                  : SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Text(
                                uploadedVideoName!,
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
              selectedImageFromGellery == null
                  ? Container()
                  : const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              uploadedVideoName == null
                  ? Container()
                  : const SizedBox(
                      height: 10,
                      width: double.infinity,
                    ),
              selectedImageFromGellery == null
                  ? Container()
                  : InkWell(
                      onTap: () {
                        uploadMediaAPI();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120,
                        height: 40,
                        child: Center(
                          child: Text(
                            getTranslated(context, "Upload")!,
                            style: const TextStyle(
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
              uploadedVideoName == null
                  ? Container()
                  : InkWell(
                      onTap: () {
                        uploadMediaAPI();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120,
                        height: 40,
                        child: Center(
                          child: Text(
                            getTranslated(context, "Upload")!,
                            style: const TextStyle(
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  videoFromGallery() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', '3gp', 'avchd', 'avi', 'flv', 'mkv', 'mov', 'webm', 'wmv', 'mpg', 'mpeg', 'ogg'],
    );
    if (result != null) {
      File video = File(result.files.single.path!);
      setState(
        () {
          videoFromGellery = video;
          result.names[0] == null
              ? setsnackbar(getTranslated(context, "Error in video uploading please try again...!")!, context)
              : () {
                  uploadedVideoName = result.names[0]!;
                }();
        },
      );

      if (mounted) setState(() {});
    } else {}
  }

  imageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      File image = File(result.files.single.path!);
      setState(
        () {
          selectedImageFromGellery = image;
        },
      );
    } else {}
  }

  getAppBar(String title, BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: white,
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
      actions: [
        (widget.from == "profile")
            ? TextButton(
                onPressed: () {
                  if (widget.from == "profile") {
                    profileImage.addAll(otherImgUrlList);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  getTranslated(context, "Done")!,
                ),
              )
            : Container()
      ],
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

  Future<void> getMedia() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (scrollLoadmore) {
        if (mounted) {
          setState(
            () {
              scrollLoadmore = false;
              scrollGettingData = true;
              if (scrollOffset == 0) {
                mediaList = [];
              }
            },
          );
        }
        try {
          var parameter = {
            LIMIT: perPage.toString(),
            OFFSET: scrollOffset.toString(),
          };

          if (widget.from == "video") {
            parameter["type"] = "video";
          }

          http.Response response = await http.post(getMediaApi, body: parameter, headers: await ApiUtils.getHeaders()).timeout(
                const Duration(
                  seconds: timeOut,
                ),
              );
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          scrollGettingData = false;
          if (scrollOffset == 0) {
            scrollNodata = error;
          }
          if (!error) {
            tempList.clear();
            var data = getdata["data"];
            if (data.length != 0) {
              tempList = (data as List)
                  .map(
                    (data) => MediaModel.fromJson(data),
                  )
                  .toList();

              mediaList.addAll(tempList);
              scrollLoadmore = true;
              scrollOffset = scrollOffset + perPage;
            } else {
              scrollLoadmore = false;
            }
          } else {
            if (getdata[statusCode] == "120") {
              reLogin(context);
            }
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
        } on TimeoutException catch (_) {
          setsnackbar(getTranslated(context, "somethingMSg")!, context);
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
        onTap: () {
          setState(
            () {
              mediaList[index].isSelected = !mediaList[index].isSelected;

              if (widget.from == "main") {
                if (widget.type == "add") {
                  add.productImage = "${mediaList[index].subDic!}${mediaList[index].name!}";
                  add.productImageUrl = mediaList[index].image!;
                }
                if (widget.type == "edit") {
                  edit.productImage = "${mediaList[index].subDic!}${mediaList[index].name!}";
                  edit.productImageUrl = mediaList[index].image!;
                  edit.productImageRelativePath = mediaList[index].path!;
                }
                Navigator.pop(context);
              } else if (widget.from == "profile") {
                if (mediaList[index].isSelected) {
                  otherImgList.add("${mediaList[index].subDic!}${mediaList[index].name!}");
                  otherImgUrlList.add(mediaList[index].image!);
                } else {
                  otherImgList.remove("${mediaList[index].subDic!}${mediaList[index].name!}");
                  otherImgUrlList.remove(mediaList[index].image!);
                }
              } else if (widget.from == 'variant') {
                if (mediaList[index].isSelected) {
                  variantImgList.add("${mediaList[index].subDic!}${mediaList[index].name!}");
                  variantImgUrlList.add(mediaList[index].image!);
                } else {
                  variantImgList.remove("${mediaList[index].subDic!}${mediaList[index].name!}");
                  variantImgUrlList.remove(mediaList[index].image!);
                }
              } else if (widget.from == "promocode") {
                promocodeImage = "${mediaList[index].path!}";
                promocodeImageUrl = mediaList[index].image!;
                Navigator.of(context).pop();
              }
            },
          );
        },
        child: Stack(
          children: [
            Row(
              children: [
                Image.network(
                  mediaList[index].image!,
                  height: 200,
                  width: 200,
                  errorBuilder: (context, error, stackTrace) => erroWidget(160),
                  color: Colors.black.withValues(alpha: mediaList[index].isSelected ? 1 : 0),
                  colorBlendMode: BlendMode.color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getTranslated(context, "Name")!} : ${mediaList[index].name!}',
                        ),
                        Text(
                          '${getTranslated(context, "Sub Directory")!} : ${mediaList[index].subDic!}',
                        ),
                        Text('${getTranslated(context, "Size")!} : ${mediaList[index].size!}'),
                        Text('${getTranslated(context, "Extension")!} : ${mediaList[index].extention!}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.black.withValues(alpha: mediaList[index].isSelected ? 0.1 : 0),
            ),
            mediaList[index].isSelected
                ? const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: primary,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
