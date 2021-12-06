import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_request_model.g.dart';

@JsonSerializable()
class GleapNetworkRequest {
  @JsonKey(name: 'payload', toJson: _preparePayload)
  dynamic payload;
  Map<String, dynamic>? headers;

  GleapNetworkRequest({this.payload, this.headers});

  factory GleapNetworkRequest.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkRequestToJson(this);
}

String _preparePayload(dynamic responseText) {
  if (responseText == null) {
    return "";
  }

  List<int> bytes = utf8.encode(responseText);
  if (bytes.length > 1000000) {
    return '<payload_too_large>';
  }

  return responseText.toString();
}
