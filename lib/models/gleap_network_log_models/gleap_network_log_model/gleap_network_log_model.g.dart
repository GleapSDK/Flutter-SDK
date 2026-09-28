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

Map<String, dynamic> _$GleapNetworkLogToJson(GleapNetworkLog instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', _prepareType(instance.type));
  writeNotNull('url', instance.url);
  writeNotNull('date', _prepareDate(instance.date));
  writeNotNull('request', instance.request?.toJson());
  val['duration'] = _prepareDuration(instance.duration);
  writeNotNull('success', instance.success);
  writeNotNull('response', instance.response?.toJson());
  return val;
}
