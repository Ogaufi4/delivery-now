import 'package:project/data/model/sliderModel.dart';
import 'package:project/data/repositories/home/slider/sliderRemoteDataSource.dart';
import 'package:project/utils/api.dart';

class SliderRepository {
  static final SliderRepository _sliderRepository = SliderRepository._internal();
  late SliderRemoteDataSource _sliderRemoteDataSource;

  factory SliderRepository() {
    _sliderRepository._sliderRemoteDataSource = SliderRemoteDataSource();
    return _sliderRepository;
  }

  SliderRepository._internal();

  Future<List<SliderModel>> getSlider() async {
    try {
      List<SliderModel> result = await _sliderRemoteDataSource.getSlider();
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
