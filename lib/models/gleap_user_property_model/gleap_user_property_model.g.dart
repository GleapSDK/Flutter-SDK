// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_user_property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapUserProperty _$GleapUserPropertyFromJson(Map<String, dynamic> json) =>
    GleapUserProperty(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      value: (json['value'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GleapUserPropertyToJson(GleapUserProperty instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'value': instance.value,
    };
