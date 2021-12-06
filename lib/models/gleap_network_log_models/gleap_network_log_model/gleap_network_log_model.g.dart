// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_network_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapNetworkLog _$GleapNetworkLogFromJson(Map<String, dynamic> json) =>
    GleapNetworkLog(
      type: json['type'] as String?,
      url: json['url'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      request: json['request'] == null
          ? null
          : GleapNetworkRequest.fromJson(
              json['request'] as Map<String, dynamic>),
      duration: (json['duration'] as num?)?.toDouble(),
      success: json['success'] as bool?,
      response: json['response'] == null
          ? null
          : GleapNetworkResponse.fromJson(
              json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GleapNetworkLogToJson(GleapNetworkLog instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'date': instance.date?.toIso8601String(),
      'request': instance.request?.toJson(),
      'duration': _prepareDuration(instance.duration),
      'success': instance.success,
      'response': instance.response?.toJson(),
    };
