import 'dart:convert';

import 'package:muscle_rivals/enums/signaling_type.dart';

class SignalingMessage {
  final SignalingType type;
  final Object data;
  SignalingMessage(this.type, this.data);

  factory SignalingMessage.fromJsonEncoded(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return SignalingMessage(SignalingType.values[json['type']], json['data']);
  }

  String toEncodedJson() {
    return jsonEncode({'type': type.index, 'data': data});
  }

  @override
  String toString() {
    return "SignalingMessage{type: $type, data: $data}";
  }
}
