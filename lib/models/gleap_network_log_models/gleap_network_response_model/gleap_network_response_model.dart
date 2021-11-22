import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_response_model.g.dart';

@JsonSerializable()
class GleapNetworkResponse {
  int? status;
  String? statusText;
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
