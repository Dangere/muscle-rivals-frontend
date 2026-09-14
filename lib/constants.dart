import 'package:flutter/foundation.dart';

class Constants {
  // using `10.0.2.2` as the IP address because AVD uses 10.0.2.2 as an alias to your host loopback interface (i.e) localhost
  /// The base URL of the API
  /// http://10.0.2.2:5000/api

  static String BASE_URL = kDebugMode
      ? "http:///192.168.1.28:5000"
      : "https://musclerivals.runasp.net";

  /// The base URL of the API
  static String BASE_API_URL = "$BASE_URL/api";

  /// The base URL of the SignalR hub
  static String BASE_HUB_URL = "$BASE_URL/hubs";
}
