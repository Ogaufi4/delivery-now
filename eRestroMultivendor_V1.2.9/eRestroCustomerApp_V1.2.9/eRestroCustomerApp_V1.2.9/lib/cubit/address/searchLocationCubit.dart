import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:project/data/model/search_location_model.dart';
import 'package:project/data/repositories/address/addressRepository.dart';

abstract class SearchLocationState extends Equatable {
  const SearchLocationState();

  @override
  List<Object?> get props => [];
}

class SearchLocationInitial extends SearchLocationState {}

class SearchLocationLoading extends SearchLocationState {}

class SearchLocationSuccess extends SearchLocationState {
  final List<SuggestionItem> locations;

  const SearchLocationSuccess(this.locations);

  @override
  List<Object?> get props => [locations];
}

class SearchLocationFailure extends SearchLocationState {
  final String errorMessage;

  const SearchLocationFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class SearchLocationSelected extends SearchLocationState {
  final SuggestionItem selectedLocation;

  const SearchLocationSelected(this.selectedLocation);

  @override
  List<Object?> get props => [selectedLocation];
}

class SearchLocationCubit extends Cubit<SearchLocationState> {
  final AddressRepository _locationRepository;

  SearchLocationCubit(this._locationRepository)
      : super(SearchLocationInitial());

  Future<void> fetchSearchLocation(String query) async {
    if (query.isEmpty) {
      emit(SearchLocationInitial());
      return;
    }

    emit(SearchLocationLoading());
    try {
      final searchResults = await _locationRepository.getSearchLocation(query);
      emit(SearchLocationSuccess(searchResults.data.suggestions));
    } catch (e) {
      emit(SearchLocationFailure(e.toString()));
    }
  }

  void clearResults() {
    emit(SearchLocationInitial());
  }

  void selectLocation(SuggestionItem location) {
    emit(SearchLocationSelected(location));
  }
}
