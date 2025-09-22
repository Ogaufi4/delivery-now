import 'package:project/data/model/settingModel.dart';
import 'package:project/utils/api.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';


class SystemConfigRemoteDataSource {
  Future<SettingModel> getSystemConfing(String? userId) async {
    try {
      final body = {};
      if(userId!="")
      {
        body[userIdKey]= userId;
      }
      final result = await Api.post(body: body, url:Api.getSettingsUrl, token: true, errorCode: false);
      return SettingModel.fromJson(result);
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {};
      final result = await Api.post(body: body, url:Api.getSettingsUrl, token: true, errorCode: false);
      return result['data'][type][0].toString();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
