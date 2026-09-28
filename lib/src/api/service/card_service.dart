import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_paystack/src/api/model/transaction_api_response.dart';
import 'package:flutter_paystack/src/api/service/base_service.dart';
import 'package:flutter_paystack/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack/src/common/exceptions.dart';
import 'package:flutter_paystack/src/common/my_strings.dart';
import 'package:flutter_paystack/src/common/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CardService with BaseApiService implements CardServiceContract {
  @override
  Future<TransactionApiResponse> chargeCard(Map<String, String?> fields) async {
    var url = '$baseUrl/charge/mobile_charge';

    if (kDebugMode) debugPrint('[Paystack] POST $url ...');
    final sw = Stopwatch()..start();
    http.Response response =
        await http.post(url.toUri(), body: fields, headers: headers);
    var body = response.body;

    var statusCode = response.statusCode;
    if (kDebugMode) debugPrint('[Paystack] chargeCard ${sw.elapsedMilliseconds}ms status=$statusCode body=$body');

    switch (statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> responseBody = json.decode(body);
        return TransactionApiResponse.fromMap(responseBody);
      case HttpStatus.gatewayTimeout:
        throw ChargeException('Gateway timeout error');
      default:
        throw ChargeException(Strings.unKnownResponse);
    }
  }

  @override
  Future<TransactionApiResponse> validateCharge(
      Map<String, String?> fields) async {
    var url = '$baseUrl/charge/validate';

    if (kDebugMode) debugPrint('[Paystack] POST $url ...');
    http.Response response =
        await http.post(url.toUri(), body: fields, headers: headers);
    var body = response.body;

    var statusCode = response.statusCode;
    if (kDebugMode) debugPrint('[Paystack] validateCharge status=$statusCode body=$body');
    if (statusCode == HttpStatus.ok) {
      Map<String, dynamic> responseBody = json.decode(body);
      return TransactionApiResponse.fromMap(responseBody);
    } else {
      throw CardException('validate charge transaction failed with '
          'status code: $statusCode and response: $body');
    }
  }

  Future<TransactionApiResponse> reQueryTransaction(String? trans) async {
    var url = '$baseUrl/requery/$trans';

    if (kDebugMode) debugPrint('[Paystack] GET $url ...');
    http.Response response = await http.get(url.toUri(), headers: headers);
    var body = response.body;
    var statusCode = response.statusCode;
    if (kDebugMode) debugPrint('[Paystack] requery status=$statusCode body=$body');
    if (statusCode == HttpStatus.ok) {
      Map<String, dynamic> responseBody = json.decode(body);
      return TransactionApiResponse.fromMap(responseBody);
    } else {
      throw ChargeException('requery transaction failed with status code: '
          '$statusCode and response: $body');
    }
  }
}
