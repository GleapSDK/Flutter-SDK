// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_network_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapNetworkRequest _$GleapNetworkRequestFromJson(Map<String, dynamic> json) =>
    GleapNetworkRequest(
      payload: json['payload'],
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GleapNetworkRequestToJson(GleapNetworkRequest instance) {
  final val = <String, dynamic>{
    'payload': _preparePayload(instance.payload),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('headers', _prepareHeaders(instance.headers));
  return val;
}
