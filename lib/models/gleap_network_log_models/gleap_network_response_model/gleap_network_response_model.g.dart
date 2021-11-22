// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_network_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapNetworkResponse _$GleapNetworkResponseFromJson(
        Map<String, dynamic> json) =>
    GleapNetworkResponse(
      status: json['status'] as int?,
      statusText: json['statusText'] as String?,
      responseText: json['responseText'] as String?,
    );

Map<String, dynamic> _$GleapNetworkResponseToJson(
        GleapNetworkResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'statusText': instance.statusText,
      'responseText': instance.responseText,
    };
