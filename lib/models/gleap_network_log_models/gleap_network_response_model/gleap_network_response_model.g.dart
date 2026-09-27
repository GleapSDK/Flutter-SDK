// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_network_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapNetworkResponse _$GleapNetworkResponseFromJson(
        Map<String, dynamic> json) =>
    GleapNetworkResponse(
      status: (json['status'] as num?)?.toInt(),
      statusText: json['statusText'] as String?,
      responseText: json['responseText'] as String?,
      headers: json['headers'] as Map<String, dynamic>?,
      errorText: json['errorText'] as String?,
    );

Map<String, dynamic> _$GleapNetworkResponseToJson(
    GleapNetworkResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('statusText', instance.statusText);
  writeNotNull('headers', _prepareHeaders(instance.headers));
  writeNotNull('responseText', _prepareResponse(instance.responseText));
  writeNotNull('errorText', instance.errorText);
  return val;
}
