// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_network_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapNetworkRequest _$GleapNetworkRequestFromJson(Map<String, dynamic> json) =>
    GleapNetworkRequest(
      payload: json['payload'] as String?,
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GleapNetworkRequestToJson(
        GleapNetworkRequest instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'headers': instance.headers,
    };
