import 'package:project/data/model/addressModel.dart';
import 'package:project/data/model/getLocationDetailsModel.dart';
import 'package:project/data/model/search_location_model.dart';
import 'package:project/utils/api.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';
import 'package:project/utils/hiveBoxKey.dart';

class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddress(String? userId) async {
    try {
      final body = {userIdKey: userId};
      final result = await Api.post(
          body: body, url: Api.getAddressUrl, token: true, errorCode: true);
      return (result['data'] as List)
          .map((e) => AddressModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future addAddress(
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final body = {
        userIdKey: userId,
        mobileKey: mobile,
        addressKey: address,
        cityKey: city,
        latitudeKey: latitude,
        longitudeKey: longitude,
        areaKey: area ?? "",
        typeKey: type,
        nameKey: name,
        countryCodeKey: countryCode,
        alternateCountryCodeKey: alternateCountryCode,
        alternateMobileKey: alternateMobile,
        landmarkKey: landmark,
        pinCodeKey: pincode,
        stateKey: state,
        countryKey: country,
        isDefaultKey: isDefault
      };
      final result = await Api.post(
          body: body, url: Api.addAddressUrl, token: true, errorCode: true);
      return (result['data'] as List).first;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future updateAddress(
      String? id,
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateCountryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final body = {
        idKey: id,
        userIdKey: userId,
        mobileKey: mobile,
        addressKey: address,
        cityKey: city ?? "",
        latitudeKey: latitude,
        longitudeKey: longitude,
        areaKey: area ?? "",
        typeKey: type ?? "",
        nameKey: name,
        countryCodeKey: countryCode,
        alternateCountryCodeKey: alternateCountryCode,
        alternateMobileKey: alternateMobile,
        landmarkKey: landmark ?? "",
        pinCodeKey: pincode,
        stateKey: state,
        countryKey: country,
        isDefaultKey: isDefault
      };
      final result = await Api.post(
          body: body, url: Api.updateAddressUrl, token: true, errorCode: true);
      return (result['data'] as List).first;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future deleteAddress(String? id) async {
    try {
      final body = {idKey: id};
      final result = await Api.post(
          body: body, url: Api.deleteAddressUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future checkCityDeliverable(String? name) async {
    try {
      final body = {nameKey: name};
      final result = await Api.post(
          body: body,
          url: Api.isCityDeliverableUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future checkIsOrderDeliverable(String? partnerId, String? latitude,
      String? longitude, String? addressId) async {
    try {
      final body = {
        partnerIdKey: partnerId,
        latitudeKey: latitude,
        longitudeKey: longitude,
        addressIdKey: addressId
      };
      final result = await Api.post(
          body: body,
          url: Api.isOrderDeliverableUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future checkDeliveryChargeCubit(
      String? userId, String? addressId, String? finalTotal) async {
    try {
      final body = {
        userIdKey: userId,
        addressIdKey: addressId,
        finalTotalKey: finalTotal
      };
      final result = await Api.post(
          body: body,
          url: Api.getDeliveryChargesUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  Future<SearchLocationModel> searchLocation(String? search) async {
    try {
      final body = {searchKey: search};
      print("Searching location with query: $search");
      print("Request body: $body");
      final result = await Api.post(
          body: body, url: Api.searchLocationUrl, token: true, errorCode: true);

      print("Search location API response: $result");

      if (result != null) {
        return SearchLocationModel.fromJson(Map<String, dynamic>.from(result));
      } else {
        throw Exception(
            "Invalid API response: Expected a Map but got ${result.runtimeType}");
      }
    } catch (e) {
      print("Error searching location: $e");
      if (e is ApiMessageAndCodeException) {
        throw ApiMessageAndCodeException(
          errorMessage: e.errorMessage,
          errorStatusCode: e.errorStatusCode,
        );
      } else {
        throw Exception("An unexpected error occurred: $e");
      }
    }
  }

  Future<LocationDetailsModel> locationDetails(String? placeId) async {
    try {
      final body = {placeIdKey: placeId};

      final result = await Api.post(
        body: body,
        url: Api.getLocationDetailsUrl,
        token: true,
        errorCode: true,
      );

      if (result != null && result['data'] != null) {
        return LocationDetailsModel.fromJson(result['data']);
      } else {
        throw Exception(
            "Invalid API response: Expected a Map but got ${result.runtimeType}");
      }
    } catch (e) {
      if (e is ApiMessageAndCodeException) {
        throw ApiMessageAndCodeException(
          errorMessage: e.errorMessage,
          errorStatusCode: e.errorStatusCode,
        );
      } else {
        throw Exception("An unexpected error occurred: $e");
      }
    }
  }
}
