import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:project/Helper/Constant.dart';
import 'package:project/Helper/String.dart';
import 'dart:ui' as ui;
import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Home.dart';

class MapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? orderId;
  final bool? isDel;

  const MapScreen({
    Key? key,
    this.latitude,
    this.longitude,
    this.orderId,
    this.isDel,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  GoogleMapController? mapController;

  double? _originLatitude, _originLongitude;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  late PolylineId polylineId;
  Timer? timer;
  BitmapDescriptor? driverIcon, restaurantsIcon, destinationIcon;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool popScope = false;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String

    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    double width = 10 * devicePixelRatio;
    double height = 10 * devicePixelRatio;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.scale(width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    final ui.Picture scaledPicture = recorder.endRecording();

    final image = await scaledPicture.toImage(width.toInt(), height.toInt());

    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();

    _launchMap();
  }

  @override
  void dispose() {
    timer!.cancel();
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  _launchMap() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    _originLatitude = position.latitude;
    _originLongitude = position.longitude;

    /// origin marker
    _addMarker(LatLng(position.latitude, position.longitude), "origin");

    /// destination marker
    _addMarker(LatLng(widget.latitude!, widget.longitude!), "destination");

    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      _originLatitude = position.latitude;
      _originLongitude = position.longitude;
      if (widget.isDel!) {
        manageLiveData(OUT_FOR_DELIVERY, _originLatitude.toString(), _originLongitude.toString());
      }
      updateMarker(
        LatLng(_originLatitude!, _originLongitude!),
        "origin",
      );
      _getPolyline();
    });

    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
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

    setState(() {});
  }

  Future<void> manageLiveData(String? status, String lat, String long) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {ORDERID: widget.orderId, ORDER_STATUS: status, LATITUDE: lat, LONGITUDE: long};
        apiBaseHelper.postAPICall(manageLiveTrackApi, parameter, context).then((getdata) {
          bool error = getdata["error"];

          if (!error) {}
        }, onError: (error) {
          setSnackbar(error.toString());
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: popScope,
      onPopInvokedWithResult: (popScope, dynamic) async {
        latitude = _originLatitude;
        longitude = _originLongitude;
        popScope = true;
      },
      child: Scaffold(
          body: _isNetworkAvail
              ? Stack(
                  children: [
                    _originLatitude != null || _originLongitude != null
                        ? GoogleMap(
                            initialCameraPosition: CameraPosition(target: LatLng(_originLatitude!, _originLongitude!), zoom: 13),
                            myLocationEnabled: true,
                            tiltGesturesEnabled: true,
                            compassEnabled: true,
                            scrollGesturesEnabled: true,
                            zoomGesturesEnabled: true,
                            onMapCreated: _onMapCreated,
                            markers: Set<Marker>.of(markers.values),
                            polylines: Set<Polyline>.of(polylines.values),
                          )
                        : const Center(child: CircularProgressIndicator(color: darkFontColor)),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 15.0, top: 31.0),
                      child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: InkWell(
                            child: const CircleAvatar(
                              radius: 14.5,
                              backgroundColor: darkFontColor,
                              child: Center(
                                child: Icon(
                                  Icons.keyboard_arrow_left,
                                  color: white,
                                  size: 28,
                                ),
                              ),
                            ),
                            onTap: () {
                              latitude = _originLatitude;
                              longitude = _originLongitude;
                              Navigator.of(context).pop();
                            },
                          )),
                    )
                  ],
                )
              : noInternet(context)),
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
                  Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context) => super.widget));
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

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    _addPolyLine();
  }

  _addMarker(LatLng position, String id) async {
    MarkerId markerId = MarkerId(id);

    BitmapDescriptor? icon, defaultIcon;
    if (id == "origin") {
      driverIcon = await bitmapDescriptorFromSvgAsset(context, setSvgPath("delivery_boy"));
      defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      icon = driverIcon;
    }
    if (widget.isDel!) {
      if (id == "destination") {
        restaurantsIcon = await bitmapDescriptorFromSvgAsset(context, setSvgPath("map_pin"));
        defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
        icon = restaurantsIcon;
      }
    } else {
      if (id == "destination") {
        destinationIcon = await bitmapDescriptorFromSvgAsset(context, setSvgPath("address_icon"));
        defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        icon = destinationIcon;
      }
    }

    Marker marker = Marker(
      markerId: markerId,
      icon: icon ?? defaultIcon!,
      position: position,
    );
    markers[markerId] = marker;
  }

  updateMarker(LatLng latLng, String id) async {
    BitmapDescriptor? icon, defaultIcon;
    MarkerId markerId = MarkerId(id);
    driverIcon = await bitmapDescriptorFromSvgAsset(context, setSvgPath("delivery_boy"));
    defaultIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    icon = driverIcon;
    Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: icon ?? defaultIcon,
    );
    if (mounted) {
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId(widget.orderId!);
    Polyline polyline = Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());

      poly.add(p);
    }
    return poly;
  }

  Future<List<LatLng>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    List<LatLng> latlnglist = [];
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": 'driving',
      "key": Platform.isAndroid ? AND_GOOGLE_API_KEY : IOS_GOOGLE_API_KEY,
    };

    Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);

      if (parsedJson["status"]?.toLowerCase() == 'ok' && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        latlnglist = decodeEncodedPolyline(parsedJson["routes"][0]["overview_polyline"]["points"]);
      }
    }
    return latlnglist;
  }

  _getPolyline() async {
    List<LatLng> mainroute = [];
    mainroute = await getRouteBetweenCoordinates(LatLng(_originLatitude!, _originLongitude!), LatLng(widget.latitude!, widget.longitude!));

    if (mainroute.isEmpty) {
      mainroute = [];
      mainroute.add(LatLng(_originLatitude!, _originLongitude!));
      mainroute.add(LatLng(widget.latitude!, widget.longitude!));
    }

    polylineId = PolylineId(widget.orderId!);
    Polyline polyline = Polyline(
        polylineId: polylineId,
        visible: true,
        points: mainroute,
        color: Colors.red,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        width: 8);
    polylines[polylineId] = polyline;

    if (mounted) {
      setState(() {});
    }
  }
}
