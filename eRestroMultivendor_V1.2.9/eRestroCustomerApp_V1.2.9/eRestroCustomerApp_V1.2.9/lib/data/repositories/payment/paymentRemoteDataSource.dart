import 'package:project/utils/api.dart';
import 'package:project/utils/apiBodyParameterLabels.dart';

class PaymentRemoteDataSource {
  Future<dynamic> getPayment(String? userId, String? orderId, String? amount) async {
    try {
      final body = {userIdKey: userId, orderIdKey: orderId, amountKey: amount};
      final result = await Api.post(body: body, url: Api.getPaypalLinkUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  Future<dynamic> sendWalletRequest(String? userId, String? amount, String? paymentAddress) async {
    try {
      final body = {userIdKey: userId, amountKey: amount, paymentAddressKey: paymentAddressKey};
      final result = await Api.post(body: body, url: Api.sendWithdrawRequestUrl, token: true, errorCode: true);
      return result['data'];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
