import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_request_model.g.dart';

@JsonSerializable()
class GleapNetworkRequest {
  String? payload;
  Map<String, dynamic>? headers;

  GleapNetworkRequest({this.payload, this.headers});

  factory GleapNetworkRequest.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkRequestToJson(this);
}
