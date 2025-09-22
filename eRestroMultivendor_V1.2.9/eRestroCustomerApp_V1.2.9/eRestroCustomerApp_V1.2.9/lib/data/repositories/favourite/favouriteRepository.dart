import 'package:project/data/repositories/favourite/favouriteDataSource.dart';
import 'package:project/data/model/restaurantModel.dart';
import 'package:project/data/model/sectionsModel.dart';
import 'package:project/utils/api.dart';

class FavouriteRepository {
  static final FavouriteRepository _favouriteRepository = FavouriteRepository._internal();
  late FavouriteRemoteDataSource _favouriteRemoteDataSource;

  factory FavouriteRepository() {
    _favouriteRepository._favouriteRemoteDataSource = FavouriteRemoteDataSource();
    return _favouriteRepository;
  }

  FavouriteRepository._internal();

  Future<List<RestaurantModel>> getFavourite(String? userId, String? type) async {
    try {
      List<RestaurantModel> result = await _favouriteRemoteDataSource.getFavouriteRestaurants(userId: userId, type: type);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getFavouriteAdd(String? userId, String? type, String? typeId) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, typeId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future getFavouriteRemove(String? userId, String? type, String? typeId) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, typeId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<List<RestaurantModel>> getFavoriteRestaurants(String? userId, String? type) async {
    try {
      List<RestaurantModel> result = await _favouriteRemoteDataSource.getFavouriteRestaurants(userId: userId, type: type);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future favoriteRestaurant({required String userId, required String type, required String restaurantId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, restaurantId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future unFavoriteRestaurant({required String userId, required String type, required String restaurantId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, restaurantId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<List<ProductDetails>> getFavoriteProducts(String? userId, String? type) async {
    try {
      List<ProductDetails> result = await _favouriteRemoteDataSource.getFavouriteProducts(userId: userId, type: type);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future favoriteProduct({required String userId, required String type, required String productId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, productId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future unFavoriteProduct({required String userId, required String type, required String productId}) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, productId);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
