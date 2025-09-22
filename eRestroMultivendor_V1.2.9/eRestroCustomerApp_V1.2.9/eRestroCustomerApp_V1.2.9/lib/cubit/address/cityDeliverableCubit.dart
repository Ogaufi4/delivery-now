import 'package:project/data/repositories/address/addressRepository.dart';
import 'package:project/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CityDeliverableState {}

class CityDeliverableInitial extends CityDeliverableState {}

class CityDeliverableProgress extends CityDeliverableState {}

class CityDeliverableSuccess extends CityDeliverableState {
  final String? name, cityId;

  CityDeliverableSuccess(this.name, this.cityId);
}

class CityDeliverableFailure extends CityDeliverableState {
  final String errorStatusCode, errorMessage;
  CityDeliverableFailure(this.errorMessage, this.errorStatusCode);
}

class CityDeliverableCubit extends Cubit<CityDeliverableState> {
  final AddressRepository _addressRepository;

  CityDeliverableCubit(this._addressRepository) : super(CityDeliverableInitial());

  fetchCityDeliverable(String? name) {
    emit(CityDeliverableProgress());
    _addressRepository.getCityDeliverable(name).then((value) => emit(CityDeliverableSuccess(name, value))).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;

      emit(CityDeliverableFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }

  String getCityId() {
    if (state is CityDeliverableSuccess) {
      return (state as CityDeliverableSuccess).cityId!;
    } else if (state is CityDeliverableFailure) {}
    return "";
  }
}
