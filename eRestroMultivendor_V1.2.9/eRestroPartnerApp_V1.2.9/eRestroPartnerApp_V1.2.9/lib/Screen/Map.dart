import 'dart:async';
import 'dart:math';
import 'package:project/Screen/profile.dart' as profile;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Helper/Color.dart';
import '../Helper/session.dart';
import 'Authentication/restorentRegistration.dart' as register;
import '../Model/LocationModel/search_location_model.dart';
import '../Helper/string.dart';
import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../Model/LocationModel/location_details_model.dart';
import '../Helper/api_base_helper.dart';

class MapScreen extends StatefulWidget {
  final double? latitude, longitude;
  final bool? from;

  const MapScreen({Key? key, this.latitude, this.longitude, this.from})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool fromRegistration = false;
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  final Set<Marker> _markers = {};

  // Add for search location
  final TextEditingController _searchController = TextEditingController();
  List<SuggestionItem> _suggestions = [];
  bool _isSearching = false;
  bool _selectingSuggestion = false;

  final ApiBaseHelper _apiHelper = ApiBaseHelper();

  // Store the last selected mainText
  String? _lastSelectedMainText;

  // Named search listener
  void _onSearchChanged() async {
    if (_selectingSuggestion) {
      _selectingSuggestion = false;
      return;
    }
    final text = _searchController.text;
    if (text.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      try {
        final model = await searchLocation(text);
        setState(() {
          _suggestions = model.data.suggestions;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future getCurrentLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      widget.latitude!,
      widget.longitude!,
    );

    if (mounted) {
      setState(
        () {
          latlong = LatLng(widget.latitude!, widget.longitude!);

          _cameraPosition =
              CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
          if (_controller != null) {
            _controller!
                .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }

          var address;
          address = placemark[0].name;
          address = address + ',' + placemark[0].subLocality;
          address = address + ',' + placemark[0].locality;
          address = address + ',' + placemark[0].administrativeArea;
          address = address + ',' + placemark[0].country;
          address = address + ',' + placemark[0].postalCode;

          locationController.text = address;
          _markers.add(
            Marker(
              markerId: const MarkerId('Marker'),
              position: LatLng(widget.latitude!, widget.longitude!),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    fromRegistration = widget.from ?? false;
    super.initState();

    // Use a sensible default if widget.latitude/longitude are null
    double initialLat = widget.latitude ?? 28.6139; // New Delhi
    double initialLng = widget.longitude ?? 77.2090;
    _cameraPosition =
        CameraPosition(target: LatLng(initialLat, initialLng), zoom: 10.0);
    getCurrentLocation();

    _searchController.addListener(_onSearchChanged);
  }

  Future<Map<String, dynamic>> resToJson(res) async {
    return res is Map<String, dynamic>
        ? res
        : Map<String, dynamic>.from(
            await Future.value(res.body != null ? jsonDecode(res.body) : {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
    } else {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      var position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      callback();

      latlong = LatLng(position.latitude, position.longitude);

      _cameraPosition =
          CameraPosition(target: latlong!, zoom: 14.4746, bearing: 0);
      if (_controller != null) {
        _controller!
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      }
    }
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        getTranslated(context, "Choose Location")!,
        context,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search location',
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _suggestions = [];
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  if (_isSearching)
                    Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      height: 120,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: primary),
                    ),
                  if (!_isSearching && _suggestions.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxHeight: height / 3.4),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: ListView.builder(
                        shrinkWrap: false,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final place = suggestion.placePrediction;

                          return Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _suggestions = [];
                                      _isSearching = false;
                                    });
                                    _selectingSuggestion = true;
                                    _searchController
                                        .removeListener(_onSearchChanged);
                                    _searchController.text = place
                                            .structuredFormat
                                            .mainText
                                            .text
                                            .isNotEmpty
                                        ? place.structuredFormat.mainText.text
                                        : place.place;
                                    _lastSelectedMainText =
                                        _searchController.text;
                                    _searchController
                                        .addListener(_onSearchChanged);
                                    try {
                                      final details =
                                          await locationDetails(place.placeId);
                                      if (details.location != null &&
                                          details.location!.latitude != null &&
                                          details.location!.longitude != null) {
                                        latlong = LatLng(
                                            details.location!.latitude!,
                                            details.location!.longitude!);
                                        _cameraPosition = CameraPosition(
                                            target: latlong!,
                                            zoom: 15.0,
                                            bearing: 0);
                                        if (_controller != null) {
                                          _controller!.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  _cameraPosition));
                                        }
                                        locationController.text =
                                            details.formattedAddress ?? '';
                                        _markers.clear();
                                        _markers.add(
                                          Marker(
                                            markerId: const MarkerId('Marker'),
                                            position: latlong!,
                                          ),
                                        );
                                        setState(() {});
                                      }
                                    } catch (e) {
                                      // handle error if needed
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            color: grey, size: 20),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                place.structuredFormat.mainText
                                                        .text.isNotEmpty
                                                    ? place.structuredFormat
                                                        .mainText.text
                                                    : place.place,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: fontColor),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (place
                                                  .structuredFormat
                                                  .secondaryText
                                                  .text
                                                  .isNotEmpty)
                                                Text(
                                                  place.structuredFormat
                                                      .secondaryText.text,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: greayLightColor),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  (latlong != null)
                      ? GoogleMap(
                          initialCameraPosition: _cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = (controller);
                            _controller!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                _cameraPosition,
                              ),
                            );
                          },
                          markers: myMarker(),
                          onTap: (latLng) {
                            if (mounted) {
                              setState(
                                () {
                                  latlong = latLng;
                                  getLocation();
                                },
                              );
                            }
                          },
                        )
                      : Container(),
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    end: width / 90.0,
                    top: height / 80.6,
                    child: InkWell(
                      onTap: () => _checkPermission(() async {}, context),
                      child: Container(
                        padding: const EdgeInsetsDirectional.all(5.0),
                        margin: const EdgeInsetsDirectional.only(end: 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface),
                        child: const Icon(
                          Icons.my_location,
                          color: lightBlack,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            TextField(
              cursorColor: black,
              controller: locationController,
              readOnly: true,
              style: const TextStyle(
                color: fontColor,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                icon: Container(
                  margin: const EdgeInsetsDirectional.only(
                    start: 20,
                    top: 0,
                  ),
                  width: 10,
                  height: 10,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
                hintText: 'pick up',
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
              ),
            ),
            ElevatedButton(
              child: Text(
                getTranslated(context, "Update Location")!,
              ),
              onPressed: () {
                double latitude = latlong!.latitude;
                double longitude = latlong!.longitude;
                String maintext = '';
                if (_lastSelectedMainText != null &&
                    _lastSelectedMainText!.isNotEmpty) {
                  maintext = _lastSelectedMainText!;
                } else if (locationController.text.isNotEmpty) {
                  maintext = locationController.text.split(',')[0];
                }
                if (fromRegistration) {
                  register.latitutute = latitude.toString();
                  register.longitude = longitude.toString();
                } else {
                  profile.latitutute = latitude.toString();
                  profile.longitude = longitude.toString();
                }
                Navigator.pop(context, {
                  'latitude': latitude,
                  'longitude': longitude,
                  'maintext': maintext,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> myMarker() {
    _markers.clear();

    _markers.add(
      Marker(
        markerId: MarkerId(Random().nextInt(10000).toString()),
        position: LatLng(latlong!.latitude, latlong!.longitude),
      ),
    );

    // getLocation();

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);

    var address;
    address = placemark[0].name;
    address = address + ',' + placemark[0].subLocality;
    address = address + ',' + placemark[0].locality;
    address = address + ',' + placemark[0].administrativeArea;
    address = address + ',' + placemark[0].country;
    address = address + ',' + placemark[0].postalCode;
    locationController.text = address;
    if (mounted) {
      setState(
        () {},
      );
    }
  }

  Future<SearchLocationModel> searchLocation(String? search) async {
    try {
      final body = {SEARCH: search};
      final result =
          await _apiHelper.postAPICall(searchLocationUrl, body, context);
      // Check for error in the response
      if (result != null && result is Map<String, dynamic>) {
        if (result['error'] == true) {
          // Handle token expiration
          if (result['status_code'] == "102" || result['status_code'] == 102) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result['message'] ??
                      "Session expired. Please login again")),
            );
            throw Exception(result['message'] ?? "Session expired");
          }
          throw Exception(result['message'] ?? "Error in API response");
        }
        return SearchLocationModel.fromJson(Map<String, dynamic>.from(result));
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Search error: ${e.toString()}")),
        );
      }
      // Create an empty model instead of throwing exception
      return SearchLocationModel.empty();
    }
  }

  Future<LocationDetailsModel> locationDetails(String? placeId) async {
    try {
      final body = {PLACE_ID: placeId};
      final result =
          await _apiHelper.postAPICall(getLocationDetailsUrl, body, context);
      if (result != null && result is Map<String, dynamic>) {
        // Check for error in the response
        if (result['error'] == true) {
          // Handle token expiration
          if (result['status_code'] == "102" || result['status_code'] == 102) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(result['message'] ??
                        "Session expired. Please login again")),
              );
            }
            throw Exception(result['message'] ?? "Session expired");
          }
          throw Exception(result['message'] ?? "Error in API response");
        }

        if (result['data'] != null) {
          return LocationDetailsModel.fromJson(result['data']);
        } else {
          throw Exception("No data found in response");
        }
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location details error: ${e.toString()}")),
        );
      }
      // Return an empty model with default values
      return LocationDetailsModel.empty();
    }
  }
}
