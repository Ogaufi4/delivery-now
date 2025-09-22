import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/data/model/getLocationDetailsModel.dart';
import 'package:project/data/repositories/address/addressRepository.dart';
import 'package:project/utils/api.dart';

abstract class GetLocationDetailState {}

class GetLocationDetailInitial extends GetLocationDetailState {}

class GetLocationDetailProgress extends GetLocationDetailState {}

class GetLocationDetailSuccess extends GetLocationDetailState {
  final LocationDetailsModel locationDetailsModel;

  GetLocationDetailSuccess({required this.locationDetailsModel});
}

class GetLocationDetailFailure extends GetLocationDetailState {
  final String errorStatusCode, errorMessage;
  GetLocationDetailFailure(this.errorMessage, this.errorStatusCode);
}

class GetLoactionDetailCubit extends Cubit<GetLocationDetailState> {
  final AddressRepository _addressRepository;

  GetLoactionDetailCubit(this._addressRepository)
      : super(GetLocationDetailInitial());

  fetchLocationDetail(String? placeId) {
    if (placeId == null || placeId.isEmpty) {
      emit(GetLocationDetailFailure("Place ID cannot be empty", "400"));
      return;
    }

    emit(GetLocationDetailProgress());
    _addressRepository.getlocationDetails(placeId).then((value) {
      emit(GetLocationDetailSuccess(locationDetailsModel: value));
    }).catchError((e) {
      if (e is ApiMessageAndCodeException) {
        emit(GetLocationDetailFailure(
            e.errorMessage, e.errorStatusCode ?? "500"));
      } else {
        emit(GetLocationDetailFailure(e.toString(), "500"));
      }
    });
  }
}
