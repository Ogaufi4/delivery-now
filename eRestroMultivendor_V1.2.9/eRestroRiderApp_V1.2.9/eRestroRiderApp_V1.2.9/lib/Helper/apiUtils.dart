import 'package:project/Helper/Session.dart';
import 'package:project/Helper/String.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    String? jwtToken = await getPrefrence(TOKEN);
    return {"Authorization": 'Bearer $jwtToken'};
  }
}
