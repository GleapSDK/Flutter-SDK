// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_user_property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapUserProperty _$GleapUserPropertyFromJson(Map<String, dynamic> json) =>
    GleapUserProperty(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      plan: json['plan'] as String?,
      companyName: json['companyName'] as String?,
      companyId: json['companyId'] as String?,
      sla: (json['sla'] as num?)?.toDouble(),
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GleapUserPropertyToJson(GleapUserProperty instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'plan': instance.plan,
      'companyName': instance.companyName,
      'companyId': instance.companyId,
      'value': instance.value,
      'sla': instance.sla,
      'customData': instance.customData,
    };
