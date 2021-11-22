import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_response_model.g.dart';

@JsonSerializable()
class GleapNetworkResponse {
  int? status;
  String? statusText;
  @JsonKey(name: 'responseText', toJson: _prepareResponse)
  String? responseText;

  GleapNetworkResponse({
    this.status,
    this.statusText,
    this.responseText,
  });

  factory GleapNetworkResponse.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkResponseToJson(this);
}

String? _prepareResponse(String? responseText) {
  if (responseText == null) {
    return null;
  }

  List<int> bytes = utf8.encode(responseText);
  if (bytes.length > 1000000) {
    return '<response_too_large>';
  }

  return responseText;
}
