library analyticsdart.analytics;
import 'dart:async';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Analytics {

  static Analytics _singleton;
  static String endpoint = "https://api.segment.io/v1";
  static String writeKey;
  static AnalyticsClient client = new AnalyticsClient(new Client());

  factory Analytics({String apiKey}){
    if (_singleton == null) {
      _singleton = new Analytics._internal(apiKey);
      return _singleton;
    } else {
      return _singleton;
    }
  }

  Analytics._internal(String segmentApiKey){
    writeKey = "Basic ${CryptoUtils.bytesToBase64(UTF8.encode("$segmentApiKey"))}";
  }

  Future<String> identify(String userID, Map properties) async{
    Map payload = {
      "type":"identify",
      "traits":properties,
      "userId":userID,
      "context":defaultContext()
    };
    Response response = await client.post("$endpoint/identify", body:JSON.encode(payload));
    return response.body;
  }

  Future<String> trackRevenue(String userId, double value, String eventName) async{
    Map properties = {
      "revenue":value
    };
    return await track(userId, eventName, properties:properties);
  }

  Future<String> track(String userId, String event, {Map properties, Map context}) async{
    if (properties == null) {
      properties = new Map();
    }

    if (context == null) {
      context = defaultContext();
    } else {
      context.addAll(defaultContext());
    }

    Map payload = {
      "userId":userId,
      "context":context,
      "event":event,
      "properties":properties
    };
    Response response = await client.post("$endpoint/track", body:JSON.encode(payload));
    return response.body;
  }

  Map defaultContext() {
    return {
      "library":"analytics-dart",
      "version":"0.1"
    };
  }


}

class AnalyticsClient extends BaseClient {
  String userAgent;
  Client _inner;

  AnalyticsClient(this._inner);

  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['Content-Type'] = "application/json";
    request.headers["Authorization"] = Analytics.writeKey;
    return _inner.send(request);
  }
}
